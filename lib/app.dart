import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/onboarding/lock_screen.dart';
import 'l10n/app_localizations.dart';
import 'security/app_lock.dart';

class ZungaApp extends ConsumerWidget {
  const ZungaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final locked = ref.watch(appLockProvider);

    return MaterialApp.router(
      title: 'Zunga',
      debugShowCheckedModeBanner: false,
      theme: buildZungaTheme(),
      locale: locale,
      supportedLocales: const [Locale('rw'), Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        // Session lock overlays the whole app after 60 s in background.
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (locked) const LockScreen(),
          ],
        );
      },
    );
  }
}
