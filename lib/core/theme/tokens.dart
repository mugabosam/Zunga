import 'package:flutter/material.dart';

/// Design tokens — the single source of truth, transcribed from zunga-ui.html.
/// Near-monochrome, one accent, hairline borders, tabular numerals.
abstract final class ZTokens {
  // Colors
  static const bg = Color(0xFFFAFAF8);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF141517);
  static const ink2 = Color(0xFF6B6E73);
  static const ink3 = Color(0xFF9A9DA2);
  static const line = Color(0xFFE8E8E4);
  static const lineSoft = Color(0xFFF0F0EC);
  static const accent = Color(0xFF0E6E5C);
  static const accentTint = Color(0xFFEDF4F2);
  static const accentBorder = Color(0xFFD5E5E1);

  // Radii (8pt grid, 16px base radius)
  static const radius = 16.0;
  static const radiusCard = 20.0;
  static const radiusSmall = 12.0;
  static const radiusPill = 999.0;

  // Type
  static const fontFamily = 'Inter';
  static const fontFamilyMono = 'IBM Plex Mono';

  /// Tabular numerals for every amount, meter number and reference.
  static const numFeatures = [FontFeature.tabularFigures()];
}

/// Text styles used across the 22 screens.
abstract final class ZText {
  static const screenTitle = TextStyle(
      fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.17);
  static const pageTitle = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.44);
  static const groupLabel = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.84,
      color: ZTokens.ink3);
  static const rowTitle = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600);
  static const rowSub = TextStyle(fontSize: 12, color: ZTokens.ink3);
  static TextStyle amount(double size) => TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: size * -0.03,
      fontFeatures: ZTokens.numFeatures);
  static const num14 = TextStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w600,
      fontFeatures: ZTokens.numFeatures);
  static const mono = TextStyle(
      fontFamily: ZTokens.fontFamilyMono,
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: ZTokens.ink2);
}
