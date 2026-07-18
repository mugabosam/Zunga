import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Navy/orange system: #F6F6FA background, white cards with soft
/// shadows, navy #232C63 primary, orange #EE7B3F accent, Poppins.
ThemeData buildZungaTheme() {
  const scheme = ColorScheme.light(
    primary: ZTokens.accent,
    onPrimary: Colors.white,
    secondary: ZTokens.navy,
    onSecondary: Colors.white,
    surface: ZTokens.surface,
    onSurface: ZTokens.ink,
    outline: ZTokens.line,
    error: Color(0xFFD84A3A),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: ZTokens.fontFamily,
    scaffoldBackgroundColor: ZTokens.bg,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: ZTokens.ink,
      displayColor: ZTokens.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ZTokens.bg,
      foregroundColor: ZTokens.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: ZTokens.fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: ZTokens.ink,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ZTokens.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: ZTokens.lineSoft,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? ZTokens.accent.withValues(alpha: 0.35)
              : ZTokens.accent,
        ),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(56)),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZTokens.radiusButton),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: ZTokens.fontFamily,
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: ZTokens.surface,
        foregroundColor: ZTokens.ink,
        minimumSize: const Size.fromHeight(56),
        side: BorderSide.none,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZTokens.radiusButton),
        ),
        textStyle: const TextStyle(
          fontFamily: ZTokens.fontFamily,
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ZTokens.ink2,
        textStyle: const TextStyle(
          fontFamily: ZTokens.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? ZTokens.accent
            : ZTokens.line,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ZTokens.navy,
      contentTextStyle: const TextStyle(
        fontFamily: ZTokens.fontFamily,
        fontSize: 13.5,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZTokens.radiusSmall),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
