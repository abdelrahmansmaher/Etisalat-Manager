import 'package:flutter/material.dart';

/// Type scale from doc 04 §2.2 (sizes in logical px / sp, Arabic-friendly
/// line heights expressed as `height = lineHeight / fontSize`).
///
/// TODO(fonts): IBM Plex Sans Arabic / IBM Plex Mono are not bundled yet (see
/// the commented `fonts:` block in pubspec.yaml). Until then Flutter silently
/// falls back through [sansFallback]/[monoFallback] to the platform font, so
/// the app renders correctly with system fonts.
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
    'Courier New',
    'monospace',
  ];

  static TextStyle _sans(double size, double lineHeight, FontWeight weight) =>
      TextStyle(
        fontFamily: sansFamily,
        fontFamilyFallback: sansFallback,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        letterSpacing: 0, // never letter-space Arabic
      );

  static final TextStyle headlineL = _sans(24, 36, FontWeight.w700);
  static final TextStyle headlineM = _sans(20, 30, FontWeight.w700);
  static final TextStyle titleL = _sans(18, 28, FontWeight.w600);
  static final TextStyle titleM = _sans(16, 24, FontWeight.w600);
  static final TextStyle bodyL = _sans(16, 26, FontWeight.w400);
  static final TextStyle bodyM = _sans(14, 22, FontWeight.w400);
  static final TextStyle labelL = _sans(14, 20, FontWeight.w500);

  /// Chips and metadata only — absolute minimum size.
  static final TextStyle labelS = _sans(12, 16, FontWeight.w500);

  /// Current (valid) price in an answer card.
  static final TextStyle price = _sans(22, 28, FontWeight.w700);

  /// Copyable codes, phone numbers, IDs.
  static const TextStyle code = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: monoFallback,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Material [TextTheme] mapped onto the doc tokens, coloured for a theme.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    TextStyle c(TextStyle s, Color color) => s.copyWith(color: color);
    return TextTheme(
      displayLarge: c(_sans(32, 44, FontWeight.w700), primary),
      displayMedium: c(_sans(28, 40, FontWeight.w700), primary),
      displaySmall: c(headlineL, primary),
      headlineLarge: c(headlineL, primary),
      headlineMedium: c(headlineM, primary),
      headlineSmall: c(titleL, primary),
      titleLarge: c(titleL, primary),
      titleMedium: c(titleM, primary),
      titleSmall: c(_sans(14, 20, FontWeight.w600), primary),
      bodyLarge: c(bodyL, primary),
      bodyMedium: c(bodyM, primary),
      bodySmall: c(_sans(12, 16, FontWeight.w400), secondary),
      labelLarge: c(labelL, primary),
      labelMedium: c(labelS, secondary),
      labelSmall: c(labelS, secondary),
    );
  }
}
