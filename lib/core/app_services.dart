import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Small native services that are not USSD-related.
class AppServices {
  static const _channel = MethodChannel('rw.zunga/app');

  /// Shares the APK of the build currently running — always fresh
  /// during development. Replaced by the Play Store listing at launch.
  Future<bool> shareApk() async {
    try {
      return await _channel.invokeMethod<bool>('shareApk') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

final appServicesProvider = Provider((ref) => AppServices());
