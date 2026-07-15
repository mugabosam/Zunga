import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config_verifier.dart';
import 'models.dart';

/// Loads the signed menu-config bundle.
///
/// Order of trust: cached remote config (Hive, already verified) →
/// bundled seed. Every candidate is Ed25519-verified against the pinned
/// key and version-gated before use; an unsigned or rolled-back config
/// is rejected outright.
class ConfigRepository {
  ConfigRepository(this._verifier);

  final ConfigVerifier _verifier;
  MenuConfigBundle? _bundle;

  Future<MenuConfigBundle> load() async {
    if (_bundle != null) return _bundle!;
    final json = await rootBundle.loadString('assets/configs/menu_configs.json');
    final sig = await rootBundle.loadString('assets/configs/menu_configs.sig');
    final ok = await _verifier.verify(json, sig.trim());
    if (!ok) {
      throw StateError('Bundled menu config failed signature verification');
    }
    _bundle = MenuConfigBundle.fromJson(jsonDecode(json) as Map<String, dynamic>);
    return _bundle!;
  }

  /// Remote refresh hook (Supabase menu_configs table) — Stage 2+.
  /// Must verify signature and enforce monotonic versions before caching.
  Future<void> refreshFromBackend() async {
    // TODO(stage2): fetch signed config from Supabase, verify, cache in Hive.
  }
}

final configVerifierProvider = Provider((ref) => ConfigVerifier());

final configRepositoryProvider =
    Provider((ref) => ConfigRepository(ref.watch(configVerifierProvider)));

final menuConfigProvider = FutureProvider<MenuConfigBundle>(
    (ref) => ref.watch(configRepositoryProvider).load());
