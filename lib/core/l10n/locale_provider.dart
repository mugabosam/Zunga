import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kinyarwanda is the default when the device locale is rw; the app
/// otherwise follows the device among rw/en/fr and the user can override
/// from Profile (screen 22).
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final device = PlatformDispatcher.instance.locale.languageCode;
    return Locale(switch (device) {
      'rw' => 'rw',
      'fr' => 'fr',
      _ => 'en',
    });
  }

  void set(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
