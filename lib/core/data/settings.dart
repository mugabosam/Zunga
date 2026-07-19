import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// User preferences (screen 22 / Faranga-grade settings). Persisted
/// on-device; nothing here ever syncs to a server.
class AppSettings {
  const AppSettings({
    this.enableContacts = true,
    this.saveRecents = true,
    this.saveTransactions = true,
    this.notifications = true,
  });

  /// Recipient suggestions from the device contact list (lookup is
  /// on-device; turning this off disables the contacts fallback).
  final bool enableContacts;

  /// Keep one-tap "paid before" recipients.
  final bool saveRecents;

  /// Keep the on-device transaction ledger.
  final bool saveTransactions;
  final bool notifications;

  AppSettings copyWith({
    bool? enableContacts,
    bool? saveRecents,
    bool? saveTransactions,
    bool? notifications,
  }) {
    return AppSettings(
      enableContacts: enableContacts ?? this.enableContacts,
      saveRecents: saveRecents ?? this.saveRecents,
      saveTransactions: saveTransactions ?? this.saveTransactions,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, bool> toMap() => {
    'enableContacts': enableContacts,
    'saveRecents': saveRecents,
    'saveTransactions': saveTransactions,
    'notifications': notifications,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    enableContacts: map['enableContacts'] as bool? ?? true,
    saveRecents: map['saveRecents'] as bool? ?? true,
    saveTransactions: map['saveTransactions'] as bool? ?? true,
    notifications: map['notifications'] as bool? ?? true,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  AppSettings build() {
    _restore();
    return const AppSettings();
  }

  Future<void> _restore() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return;
    try {
      state = AppSettings.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt prefs fall back to defaults.
    }
  }

  Future<void> update(AppSettings settings) async {
    state = settings;
    await _storage.write(key: _key, value: jsonEncode(settings.toMap()));
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
