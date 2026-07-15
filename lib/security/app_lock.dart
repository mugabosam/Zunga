import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pin_service.dart';

final pinServiceProvider = Provider((ref) => PinService());

/// Session lock (§6.7): auto-lock after 60 s in background; PIN or
/// biometrics to reopen. Sensitive actions re-prompt regardless.
class AppLockNotifier extends Notifier<bool> with WidgetsBindingObserver {
  static const backgroundGrace = Duration(seconds: 60);
  DateTime? _backgroundedAt;

  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    switch (lifecycle) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final at = _backgroundedAt;
        _backgroundedAt = null;
        if (at != null && DateTime.now().difference(at) >= backgroundGrace) {
          state = true;
        }
      default:
        break;
    }
  }

  void lock() => state = true;

  void unlock() => state = false;
}

final appLockProvider = NotifierProvider<AppLockNotifier, bool>(AppLockNotifier.new);
