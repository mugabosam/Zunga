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

/// The wallet shown in the home top-bar badge and used as the source of
/// the next payment: 'MTN' or 'Airtel'. Defaults to the registered
/// number's network; switching persists on-device.
class ActiveWalletNotifier extends Notifier<String> {
  static const _key = 'active_wallet';

  @override
  String build() {
    final myNumber = ref.watch(myNumberProvider);
    _restore();
    if (myNumber == null) return 'MTN';
    final local = myNumber.replaceAll(RegExp(r'\D'), '');
    return local.startsWith('072') || local.startsWith('073') ? 'Airtel' : 'MTN';
  }

  Future<void> _restore() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final saved = await storage.read(key: _key);
    if (saved == 'MTN' || saved == 'Airtel') state = saved!;
  }

  Future<void> switchTo(String wallet) async {
    state = wallet;
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    await storage.write(key: _key, value: wallet);
  }
}

final activeWalletProvider =
    NotifierProvider<ActiveWalletNotifier, String>(ActiveWalletNotifier.new);
