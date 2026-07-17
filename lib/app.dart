import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/shortcuts.dart';
import 'core/theme/theme.dart';
import 'l10n/app_localizations.dart';

class ZungaApp extends ConsumerStatefulWidget {
  const ZungaApp({super.key});

  @override
  ConsumerState<ZungaApp> createState() => _ZungaAppState();
}

class _ZungaAppState extends ConsumerState<ZungaApp> {
  @override
  void initState() {
    super.initState();
    // Launcher shortcuts (Send money / Buy electricity / Check balance)
    // are resolved once the first frame is up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shortcutDispatcherProvider).dispatchPending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

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
    );
  }
}
