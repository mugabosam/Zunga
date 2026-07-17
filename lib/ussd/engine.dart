import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models.dart';

/// States of a running USSD session.
enum UssdSessionState { idle, dialing, awaitingStep, awaitingUserPin, success, failed, timedOut }

class UssdSessionUpdate {
  const UssdSessionUpdate(this.state, {this.screenText, this.stepIndex, this.error, this.verifiedName});

  final UssdSessionState state;
  final String? screenText;
  final int? stepIndex;
  final String? error;

  /// Registered name parsed from the carrier's own confirmation screen.
  final String? verifiedName;
}

class SimAccount {
  const SimAccount({required this.subscriptionId, required this.slot, required this.carrier});

  final int subscriptionId;
  final int slot;
  final String carrier;
}

/// The USSD engine — a thin Dart facade over the Kotlin service.
///
/// Invariants (§3.2):
///  - one session at a time (global lock);
///  - 30 s step timeout, then cancel with a user-readable error;
///  - carrier/bank PINs pass through in memory only and are zeroed after
///    injection — NEVER logged, persisted, or sent to analytics. A CI grep
///    gate fails the build if a logger call appears in this package.
class UssdEngine {
  UssdEngine({@visibleForTesting MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('rw.zunga/ussd');

  final MethodChannel _channel;
  static const stepTimeout = Duration(seconds: 30);

  bool _sessionActive = false;
  bool get sessionActive => _sessionActive;

  /// Dual-SIM enumeration — MTN + Airtel in one device is the norm.
  Future<List<SimAccount>> getSimAccounts() async {
    try {
      final raw = await _channel.invokeListMethod<Map>('getSimSubscriptions');
      return (raw ?? const [])
          .map((m) => SimAccount(
                subscriptionId: m['subscriptionId'] as int,
                slot: m['slot'] as int,
                carrier: m['carrier'] as String? ?? 'Unknown',
              ))
          .toList();
    } on MissingPluginException {
      return const [];
    }
  }

  /// Single-step request via TelephonyManager.sendUssdRequest (API 26+).
  Future<String> runSingleStep(String code, {int? subscriptionId}) async {
    if (_sessionActive) {
      throw StateError('A USSD session is already in progress');
    }
    _sessionActive = true;
    try {
      final reply = await _channel.invokeMethod<String>('runUssd', {
        'code': code,
        'subscriptionId': subscriptionId,
      }).timeout(stepTimeout);
      return reply ?? '';
    } finally {
      _sessionActive = false;
    }
  }

  /// Manual fallback — ALWAYS available. Opens the dialer with the raw
  /// code so a broken tree never blocks the user.
  Future<void> dialManually(String code) =>
      _channel.invokeMethod<void>('dialUssd', {'code': code});

  /// Runs the USSD session directly: the carrier's own dialog (menu or
  /// "Enter PIN") pops up over the app. Returns false when CALL_PHONE is
  /// not granted yet (the system permission dialog is shown instead).
  Future<bool> callUssd(String code) async {
    try {
      return await _channel.invokeMethod<bool>('callUssd', {'code': code}) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// One entry point for every pay/dial action: run the session directly
  /// so the user only types their PIN; fall back to the prefilled dialer
  /// when the permission is missing or the direct call fails.
  Future<void> launchUssd(String code) async {
    if (!await callUssd(code)) {
      await dialManually(code);
    }
  }

  /// On-device contact lookup so the send screen shows who the number
  /// belongs to before paying. Returns null when unknown or the contacts
  /// permission is not granted.
  Future<String?> lookupContactName(String number) async {
    try {
      return await _channel
          .invokeMethod<String>('lookupContactName', {'number': number});
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Runs a multi-step flow through the Accessibility-driven native
  /// session. Yields an update per carrier screen. Treat every automated
  /// menu as a scraper: any mismatch cancels the session fail-closed.
  Stream<UssdSessionUpdate> runFlow(
    UssdFlow flow, {
    required Map<StepInputType, String> inputs,
    int? subscriptionId,
  }) async* {
    if (flow.requiresFieldVerification) {
      yield const UssdSessionUpdate(
        UssdSessionState.failed,
        error: 'flow_not_field_verified',
      );
      return;
    }
    if (_sessionActive) {
      yield const UssdSessionUpdate(UssdSessionState.failed, error: 'session_locked');
      return;
    }
    _sessionActive = true;
    try {
      yield const UssdSessionUpdate(UssdSessionState.dialing);
      final events = EventChannel('rw.zunga/ussd_session')
          .receiveBroadcastStream({
        'root': flow.root,
        'subscriptionId': subscriptionId,
      }).timeout(stepTimeout);

      var stepIndex = 0;
      await for (final event in events) {
        final screen = (event as Map)['text'] as String? ?? '';
        if (flow.isSuccess(screen)) {
          yield UssdSessionUpdate(UssdSessionState.success, screenText: screen);
          return;
        }
        if (stepIndex >= flow.steps.length) break;
        final step = flow.steps[stepIndex];
        if (!step.matches(screen)) {
          // Menu drifted from the signed tree: report a hash-only telemetry
          // event upstream (no user data) and fail closed.
          await _channel.invokeMethod('cancelSession');
          yield UssdSessionUpdate(
            UssdSessionState.failed,
            stepIndex: stepIndex,
            error: 'menu_mismatch',
          );
          return;
        }
        String? verifiedName;
        if (flow.nameCheckStep == stepIndex) {
          verifiedName = _extractRegisteredName(screen);
          if (verifiedName == null) {
            // Name confirmation failed to parse → block by default (§6.8).
            await _channel.invokeMethod('cancelSession');
            yield UssdSessionUpdate(
              UssdSessionState.failed,
              stepIndex: stepIndex,
              error: 'name_parse_failed',
            );
            return;
          }
        }
        final input = switch (step.inputType) {
          StepInputType.fixed => step.input ?? '',
          StepInputType.userPin => inputs[StepInputType.userPin] ?? '',
          _ => inputs[step.inputType] ?? '',
        };
        if (step.inputType == StepInputType.userPin && input.isEmpty) {
          // Preferred path: the user types their PIN into the carrier's
          // own dialog. The engine just waits.
          yield UssdSessionUpdate(
            UssdSessionState.awaitingUserPin,
            stepIndex: stepIndex,
            screenText: screen,
            verifiedName: verifiedName,
          );
        } else {
          await _channel.invokeMethod('sendReply', {'input': input});
          yield UssdSessionUpdate(
            UssdSessionState.awaitingStep,
            stepIndex: stepIndex,
            verifiedName: verifiedName,
          );
        }
        stepIndex++;
      }
      yield const UssdSessionUpdate(UssdSessionState.failed, error: 'session_ended');
    } on TimeoutException {
      await _channel.invokeMethod('cancelSession');
      yield const UssdSessionUpdate(UssdSessionState.timedOut, error: 'step_timeout');
    } on MissingPluginException {
      yield const UssdSessionUpdate(UssdSessionState.failed, error: 'platform_unavailable');
    } finally {
      _sessionActive = false;
    }
  }

  /// Pulls the registered name out of a carrier confirmation screen, e.g.
  /// "Kohereza 12500 RWF kuri UWASE Marie Claire (0788412903). Emeza: 1".
  String? _extractRegisteredName(String screen) {
    final patterns = [
      RegExp(r'(?:kuri|to|à|a)\s+([A-ZÀ-Ü][A-Za-zÀ-ü\.\-\x27]+(?:\s+[A-ZÀ-Ü][A-Za-zÀ-ü\.\-\x27]+){1,3})'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(screen);
      if (m != null) return m.group(1)?.trim();
    }
    return null;
  }
}
