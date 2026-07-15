import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Light mode first (per spec). Background #FAFAF8, ink #141517,
/// single accent #0E6E5C, Inter, 16px radii.
ThemeData buildZungaTheme() {
  const scheme = ColorScheme.light(
    primary: ZTokens.accent,
    onPrimary: Colors.white,
    secondary: ZTokens.ink,
    onSecondary: Colors.white,
    surface: ZTokens.surface,
    onSurface: ZTokens.ink,
    outline: ZTokens.line,
    error: Color(0xFFB3261E),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: ZTokens.fontFamily,
    scaffoldBackgroundColor: ZTokens.bg,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
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
        letterSpacing: -0.17,
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
      style: FilledButton.styleFrom(
        backgroundColor: ZTokens.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZTokens.radius),
        ),
        textStyle: const TextStyle(
          fontFamily: ZTokens.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: ZTokens.surface,
        foregroundColor: ZTokens.ink,
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: ZTokens.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZTokens.radius),
        ),
        textStyle: const TextStyle(
          fontFamily: ZTokens.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ZTokens.ink2,
        textStyle: const TextStyle(
          fontFamily: ZTokens.fontFamily,
          fontSize: 14.5,
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
  );
}
