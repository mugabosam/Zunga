import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'pinned_keys.dart';

/// Ed25519 verification of menu configs (§6.5).
///
/// A compromised backend must not be able to redirect users' money:
/// every config is signed offline, the public key is pinned in the
/// binary, and version numbers are monotonic (no rollback).
class ConfigVerifier {
  ConfigVerifier({List<int>? publicKeyBytes})
      : _publicKey = SimplePublicKey(
          publicKeyBytes ?? base64Decode(pinnedConfigPublicKeyB64),
          type: KeyPairType.ed25519,
        );

  final SimplePublicKey _publicKey;
  final _ed25519 = Ed25519();

  /// Verifies `signatureB64` over the exact UTF-8 bytes of `configJson`.
  Future<bool> verify(String configJson, String signatureB64) async {
    try {
      final signature = Signature(
        base64Decode(signatureB64),
        publicKey: _publicKey,
      );
      return await _ed25519.verify(
        utf8.encode(configJson),
        signature: signature,
      );
    } catch (_) {
      return false;
    }
  }

  /// Monotonic version gate: a config older than what we already trust
  /// is a rollback attempt and must be rejected.
  static bool acceptsVersion({required int incoming, required int current}) =>
      incoming >= current;
}
