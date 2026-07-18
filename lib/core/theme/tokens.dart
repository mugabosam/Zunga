import 'package:flutter/material.dart';

/// Design tokens — transcribed from zunga-ui.html (navy/orange revision).
/// White cards with soft shadows, navy primary, single warm orange
/// accent, Poppins, radii 16–28. Friendly and professional like a
/// modern neobank — never flat or monochrome.
abstract final class ZTokens {
  // Colors
  static const bg = Color(0xFFF6F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF232C63);
  static const ink2 = Color(0xFF7A80A0);
  static const ink3 = Color(0xFFA6ABC4);
  static const line = Color(0xFFECEDF4);
  static const lineSoft = Color(0xFFF2F3F8);
  static const navy = Color(0xFF232C63);
  static const navy2 = Color(0xFF2E3A7C);

  // Dark home surface (keypad-first screen only).
  static const bgDark = Color(0xFF10142E);
  static const cardDark = Color(0xFF171D42);
  static const lineDark = Color(0xFF2A3160);
  static const accent = Color(0xFFEE7B3F);
  static const accentTint = Color(0xFFFDEEE4);
  static const accentBorder = Color(0xFFF8DCC7);

  // Radii
  static const radius = 20.0;
  static const radiusCard = 26.0;
  static const radiusButton = 18.0;
  static const radiusSmall = 14.0;
  static const radiusPill = 999.0;

  // Shadows — cards float, they don't outline.
  static const shadow = [
    BoxShadow(
      color: Color(0x29232C63),
      blurRadius: 30,
      offset: Offset(0, 14),
      spreadRadius: -12,
    ),
  ];
  static const shadowSoft = [
    BoxShadow(
      color: Color(0x1F232C63),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -10,
    ),
  ];
  static const shadowAccent = [
    BoxShadow(
      color: Color(0x80EE7B3F),
      blurRadius: 22,
      offset: Offset(0, 10),
      spreadRadius: -8,
    ),
  ];

  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy2, navy],
    stops: [0.0, 0.7],
  );

  // Type
  static const fontFamily = 'Poppins';
  static const fontFamilyMono = 'IBM Plex Mono';

  /// Tabular numerals for every amount, meter number and reference.
  static const numFeatures = [FontFeature.tabularFigures()];
}

/// Text styles used across the screens.
abstract final class ZText {
  static const screenTitle = TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
  static const pageTitle = TextStyle(fontSize: 21, fontWeight: FontWeight.w600);
  static const groupLabel = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: ZTokens.ink3);
  static const rowTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  static const rowSub = TextStyle(fontSize: 11.5, color: ZTokens.ink3);
  static TextStyle amount(double size) => TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: ZTokens.navy,
      fontFeatures: ZTokens.numFeatures);
  static const num14 = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFeatures: ZTokens.numFeatures);
  static const mono = TextStyle(
      fontFamily: ZTokens.fontFamilyMono,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ZTokens.ink2);
}
