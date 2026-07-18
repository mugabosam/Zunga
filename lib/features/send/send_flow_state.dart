import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/profile.dart';
import '../../core/data/sample_data.dart';
import '../../ussd/providers.dart';

/// Smart destination routing: one universal input, the route detected
/// as the user types, always overridable, never a guess when ambiguous.
///
/// Codes (verified, July 2026):
///  - MTN → MTN:            *182*1*1*number*amount#  (only the PIN left)
///  - Cross-network (eKash): *182*1*2#   — works from ANY network
///  - MoMo Pay merchant:     *182*8*1*code#
///  - Airtel → Airtel:       *500#  (Airtel Money menu)
///  - Bank via eKash:        the bank's own access code (bank picker)
enum PayRoute { mtnNumber, airtelNumber, momoPay, meter, bank, incomplete }

enum SimNetwork { mtn, airtel }

/// What the raw input most likely is. 5–6 digits → merchant code;
/// 10 digits starting 078/079/072/073 → phone; other digit runs → meter
/// or bank account by length.
PayRoute detectRoute(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  final normalized =
      digits.startsWith('250') ? '0${digits.substring(3)}' : digits;
  if (normalized.length >= 5 && normalized.length <= 6) return PayRoute.momoPay;
  if (normalized.length == 10 &&
      (normalized.startsWith('078') || normalized.startsWith('079'))) {
    return PayRoute.mtnNumber;
  }
  if (normalized.length == 10 &&
      (normalized.startsWith('072') || normalized.startsWith('073'))) {
    return PayRoute.airtelNumber;
  }
  if (normalized.length >= 10 &&
      normalized.length <= 11 &&
      !normalized.startsWith('07')) {
    return PayRoute.meter;
  }
  if (normalized.length >= 12) return PayRoute.bank;
  return PayRoute.incomplete;
}

String routeLabelOf(PayRoute route) => switch (route) {
      PayRoute.mtnNumber => 'MTN number',
      PayRoute.airtelNumber => 'Airtel number',
      PayRoute.momoPay => 'MoMo Pay merchant',
      PayRoute.meter => 'EUCL meter',
      PayRoute.bank => 'Bank account',
      PayRoute.incomplete => '',
    };

class SendFlowState {
  const SendFlowState({
    this.amount = 0,
    this.input = '',
    this.routeOverride,
    this.bankCode,
    this.simNetworks = const {SimNetwork.mtn},
  });

  final int amount;

  /// The universal destination input — number, code, meter or account.
  final String input;

  /// User tapped "Change" on the detection chip.
  final PayRoute? routeOverride;

  /// eKash access code of the bank chosen in the picker (bank route).
  final String? bankCode;

  /// Networks of the registered number / SIMs — never asked.
  final Set<SimNetwork> simNetworks;

  PayRoute get route => routeOverride ?? detectRoute(input);

  String get digits {
    final d = input.replaceAll(RegExp(r'\D'), '');
    return d.startsWith('250') ? '0${d.substring(3)}' : d;
  }

  bool get isCrossNetwork => switch (route) {
        PayRoute.mtnNumber => !simNetworks.contains(SimNetwork.mtn),
        PayRoute.airtelNumber => !simNetworks.contains(SimNetwork.airtel),
        _ => false,
      };

  bool get readyToPay => switch (route) {
        PayRoute.mtnNumber || PayRoute.airtelNumber => digits.length == 10,
        PayRoute.momoPay => digits.length >= 5,
        PayRoute.meter => digits.length >= 10,
        PayRoute.bank => bankCode != null,
        PayRoute.incomplete => false,
      };

  /// The session string. Never shown — buttons run it.
  String get dialCode => switch (route) {
        PayRoute.momoPay => '*182*8*1*$digits#',
        PayRoute.mtnNumber when isCrossNetwork => '*182*1*2#',
        PayRoute.mtnNumber =>
          amount > 0 ? '*182*1*1*$digits*$amount#' : '*182*1*1#',
        PayRoute.airtelNumber when isCrossNetwork => '*182*1*2#',
        PayRoute.airtelNumber => '*500#',
        // EUCL deep path ships via the signed config once verified on a
        // live SIM; until then the MoMo menu carries the token purchase.
        PayRoute.meter => mtnMenuRoot,
        PayRoute.bank => bankCode ?? '*182*1*2#',
        PayRoute.incomplete => mtnMenuRoot,
      };

  SendFlowState copyWith({
    int? amount,
    String? input,
    PayRoute? routeOverride,
    bool clearOverride = false,
    String? bankCode,
    Set<SimNetwork>? simNetworks,
  }) {
    return SendFlowState(
      amount: amount ?? this.amount,
      input: input ?? this.input,
      routeOverride: clearOverride ? null : routeOverride ?? this.routeOverride,
      bankCode: bankCode ?? this.bankCode,
      simNetworks: simNetworks ?? this.simNetworks,
    );
  }
}

class SendFlowNotifier extends Notifier<SendFlowState> {
  @override
  SendFlowState build() {
    // The active wallet (home top-bar badge, defaulting to the
    // registered number's network) decides where money leaves from.
    final wallet = ref.watch(activeWalletProvider);
    if (ref.read(myNumberProvider) == null) _detectSims();
    return SendFlowState(
      simNetworks: wallet == 'Airtel'
          ? const {SimNetwork.airtel}
          : const {SimNetwork.mtn},
    );
  }

  /// Fallback only — used when no number is registered.
  Future<void> _detectSims() async {
    final sims = await ref.read(ussdEngineProvider).getSimAccounts();
    final networks = <SimNetwork>{};
    for (final sim in sims) {
      final carrier = sim.carrier.toLowerCase();
      if (carrier.contains('mtn')) networks.add(SimNetwork.mtn);
      if (carrier.contains('airtel')) networks.add(SimNetwork.airtel);
    }
    if (networks.isNotEmpty) {
      state = state.copyWith(simNetworks: networks);
    }
  }

  void setAmount(int amount) => state = state.copyWith(amount: amount);

  void setInput(String input) =>
      state = state.copyWith(input: input, clearOverride: true);

  void overrideRoute(PayRoute route) =>
      state = state.copyWith(routeOverride: route);

  void setBankCode(String code) => state = state.copyWith(bankCode: code);

  void reset() => state = SendFlowState(simNetworks: state.simNetworks);
}

final sendFlowProvider =
    NotifierProvider<SendFlowNotifier, SendFlowState>(SendFlowNotifier.new);

/// Rwanda MSISDN prefix → network. 078/079 MTN, 072/073 Airtel.
String? detectNetwork(String msisdn) {
  return switch (detectRoute(msisdn)) {
    PayRoute.mtnNumber => 'MTN',
    PayRoute.airtelNumber => 'Airtel',
    _ => null,
  };
}
