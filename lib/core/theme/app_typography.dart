import 'package:flutter/material.dart';

/// Type scale (logical px / sp). Line heights are generous for Arabic
/// (`height = lineHeight / fontSize`). Fonts are bundled (see pubspec):
/// IBM Plex Sans Arabic (Arabic + Latin) and IBM Plex Mono for codes.
abstract final class AppTypography {
  static const String sansFamily = 'IBM Plex Sans Arabic';
  static const String monoFamily = 'IBM Plex Mono';

  static const List<String> sansFallback = [
    'Noto Sans Arabic',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static const List<String> monoFallback = [
    'Roboto Mono',
    'Consolas',
    'Menlo',
    'monospace',
  ];

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextStyle _sans(
    double size,
    double lineHeight,
    FontWeight weight, {
    List<FontFeature>? features,
  }) => TextStyle(
    fontFamily: sansFamily,
    fontFamilyFallback: sansFallback,
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    letterSpacing: 0, // never letter-space Arabic
    fontFeatures: features,
  );

  /// Home greeting.
  static final TextStyle displayL = _sans(32, 44, FontWeight.w700);

  /// Large page titles (collapse into the app bar on scroll).
  static final TextStyle displayM = _sans(28, 40, FontWeight.w700);

  static final TextStyle headlineL = _sans(24, 36, FontWeight.w700);
  static final TextStyle headlineM = _sans(20, 30, FontWeight.w700);
  static final TextStyle titleL = _sans(18, 28, FontWeight.w600);
  static final TextStyle titleM = _sans(16, 24, FontWeight.w600);
  static final TextStyle titleS = _sans(14, 20, FontWeight.w600);
  static final TextStyle bodyL = _sans(16, 26, FontWeight.w400);
  static final TextStyle bodyM = _sans(14, 22, FontWeight.w400);
  static final TextStyle bodyS = _sans(12, 18, FontWeight.w400);
  static final TextStyle labelL = _sans(14, 20, FontWeight.w500);

  /// Chips and metadata only — absolute minimum size.
  static final TextStyle labelS = _sans(12, 16, FontWeight.w500);

  /// Overline above numbers ("السعر", "الصلاحية").
  static final TextStyle overline = _sans(12, 16, FontWeight.w600);

  /// The package price hero — very large, tabular.
  static final TextStyle priceHero = _sans(
    44,
    52,
    FontWeight.w700,
    features: tabular,
  );

  /// Current price in an answer card.
  static final TextStyle price = _sans(
    24,
    32,
    FontWeight.w700,
    features: tabular,
  );

  /// Metric tile value (quota, validity…).
  static final TextStyle metric = _sans(
    20,
    28,
    FontWeight.w700,
    features: tabular,
  );

  /// Copyable codes, phone numbers, IDs.
  static const TextStyle code = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: monoFallback,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    fontFeatures: tabular,
  );

  /// Prominent code (subscription code row).
  static const TextStyle codeL = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: monoFallback,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    fontFeatures: tabular,
  );

  /// Material [TextTheme] mapped onto the tokens, coloured for a theme.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    TextStyle c(TextStyle s, Color color) => s.copyWith(color: color);
    return TextTheme(
      displayLarge: c(displayL, primary),
      displayMedium: c(displayM, primary),
      displaySmall: c(headlineL, primary),
      headlineLarge: c(headlineL, primary),
      headlineMedium: c(headlineM, primary),
      headlineSmall: c(titleL, primary),
      titleLarge: c(titleL, primary),
      titleMedium: c(titleM, primary),
      titleSmall: c(titleS, primary),
      bodyLarge: c(bodyL, primary),
      bodyMedium: c(bodyM, primary),
      bodySmall: c(bodyS, secondary),
      labelLarge: c(labelL, primary),
      labelMedium: c(labelS, secondary),
      labelSmall: c(labelS, secondary),
    );
  }
}
