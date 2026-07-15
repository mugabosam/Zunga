import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Zunga app PIN (§6.2): 4-6 digits, Argon2id-hashed with a random salt,
/// stored only in hardware-backed secure storage, verified locally,
/// never transmitted. 5 failed attempts trigger a 30 s backoff that
/// doubles each further failure.
///
/// This is the APP PIN. Carrier/bank PINs are a different thing entirely:
/// they exist in memory for the duration of a USSD injection and are
/// never persisted anywhere, including here.
class PinService {
  PinService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  static const _hashKey = 'zunga.pin.hash';
  static const _saltKey = 'zunga.pin.salt';
  static const _failsKey = 'zunga.pin.fails';
  static const _lockUntilKey = 'zunga.pin.lock_until';

  // Tuned for 2 GB-RAM devices: 32 MiB, 3 iterations.
  static final _argon2 = Argon2id(
    parallelism: 1,
    memory: 32 * 1024,
    iterations: 3,
    hashLength: 32,
  );

  Future<bool> hasPin() async => (await _storage.read(key: _hashKey)) != null;

  Future<void> setPin(String pin) async {
    assert(pin.length >= 4 && pin.length <= 6);
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final hash = await _hash(pin, salt);
    await _storage.write(key: _saltKey, value: base64Encode(salt));
    await _storage.write(key: _hashKey, value: base64Encode(hash));
    await _storage.write(key: _failsKey, value: '0');
    await _storage.delete(key: _lockUntilKey);
  }

  /// Returns how long the user must still wait, or null if not locked out.
  Future<Duration?> lockoutRemaining() async {
    final raw = await _storage.read(key: _lockUntilKey);
    if (raw == null) return null;
    final until = DateTime.tryParse(raw);
    if (until == null || DateTime.now().isAfter(until)) return null;
    return until.difference(DateTime.now());
  }

  Future<bool> verifyPin(String pin) async {
    if (await lockoutRemaining() != null) return false;
    final saltB64 = await _storage.read(key: _saltKey);
    final hashB64 = await _storage.read(key: _hashKey);
    if (saltB64 == null || hashB64 == null) return false;

    final candidate = await _hash(pin, base64Decode(saltB64));
    final ok = _constantTimeEquals(candidate, base64Decode(hashB64));

    if (ok) {
      await _storage.write(key: _failsKey, value: '0');
      await _storage.delete(key: _lockUntilKey);
      return true;
    }
    final fails = (int.tryParse(await _storage.read(key: _failsKey) ?? '0') ?? 0) + 1;
    await _storage.write(key: _failsKey, value: '$fails');
    if (fails >= 5) {
      // 30 s at 5 fails, doubling per additional failure.
      final backoff = Duration(seconds: 30 * (1 << (fails - 5)));
      await _storage.write(
        key: _lockUntilKey,
        value: DateTime.now().add(backoff).toIso8601String(),
      );
    }
    return false;
  }

  Future<List<int>> _hash(String pin, List<int> salt) async {
    final key = await _argon2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
