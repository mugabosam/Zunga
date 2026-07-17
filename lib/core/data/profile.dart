import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The one thing Zunga asks before first use: which number will you be
/// paying from? That number defines the source network for every
/// transaction (078/079 MTN · 072/073 Airtel) and, once name lookup is
/// live, whose registered identity the transactions belong to.
///
/// Stored in Android Keystore-backed secure storage, on this phone only.
class ProfileStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyMyNumber = 'my_msisdn';

  static Future<String?> readMyNumber() => _storage.read(key: _keyMyNumber);

  static Future<void> saveMyNumber(String msisdn) =>
      _storage.write(key: _keyMyNumber, value: msisdn);
}

/// Loaded once at startup (main.dart overrides the initial value) and
/// updated when the user registers or changes their number.
class MyNumberNotifier extends Notifier<String?> {
  MyNumberNotifier(this._initial);

  final String? _initial;

  @override
  String? build() => _initial;

  Future<void> register(String msisdn) async {
    await ProfileStore.saveMyNumber(msisdn);
    state = msisdn;
  }
}

/// Overridden in main() with the value read from secure storage.
final myNumberProvider = NotifierProvider<MyNumberNotifier, String?>(
  () => MyNumberNotifier(null),
);
