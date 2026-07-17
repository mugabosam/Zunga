import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ussd/engine.dart';
import 'data/profile.dart';
import 'data/sample_data.dart';
import 'router/app_router.dart';
import '../ussd/providers.dart';

/// Launcher-shortcut handling (Send money / Buy electricity / Check
/// balance). MainActivity captures the zunga:// deep link; this asks
/// for it once after startup and acts on it.
class ShortcutDispatcher {
  ShortcutDispatcher(this.ref);

  final Ref ref;
  static const _channel = MethodChannel('rw.zunga/shortcuts');

  Future<void> dispatchPending() async {
    String? route;
    try {
      route = await _channel.invokeMethod<String>('getLaunchRoute');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
    if (route == null) return;

    // Registration gate still applies: unregistered users land on
    // /register via the router redirect regardless of the shortcut.
    final router = ref.read(routerProvider);
    switch (route) {
      case '/send':
        router.go('/home');
        router.push('/send');
      case '/bills':
        router.go('/home');
        router.push('/bills');
      case '/balance':
        router.go('/home');
        final wallet = ref.read(activeWalletProvider);
        final UssdEngine engine = ref.read(ussdEngineProvider);
        await engine.launchUssd(
            wallet == 'Airtel' ? airtelBalanceCode : mtnBalanceCode);
      default:
        router.go('/home');
    }
  }
}

final shortcutDispatcherProvider =
    Provider<ShortcutDispatcher>((ref) => ShortcutDispatcher(ref));
