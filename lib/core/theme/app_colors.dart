import 'package:flutter/material.dart';

/// Colour tokens from doc 04 §2.1 (Emerald identity, no brand colours,
/// no red accent). Exposed as a [ThemeExtension] so widgets can read tokens
/// that have no [ColorScheme] slot (`context.colors.textTertiary`).
///
/// Values marked "derived" are not in the doc table; they were chosen to keep
/// WCAG AA and are asserted in `test/core/theme/contrast_test.dart`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryPressed,
    required this.primaryUi,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.info,
    required this.verified,
    required this.verifiedContainer,
    required this.restricted,
    required this.restrictedContainer,
    required this.unverified,
    required this.unverifiedContainer,
    required this.glassHighlight,
    required this.surfaceElevated,
    required this.hairline,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.shadow,
  });

  final Brightness brightness;

  /// Buttons, links, active tab, focus ring.
  final Color primary;
  final Color onPrimary;

  /// Pressed / hover.
  final Color primaryPressed;

  /// Non-text graphics only (large icons, progress). Never small text.
  final Color primaryUi;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color background;
  final Color surface;
  final Color surfaceVariant;

  final Color textPrimary;
  final Color textSecondary;

  /// Metadata (dates, sources).
  final Color textTertiary;

  /// Decorative dividers only — never the sole boundary of a control.
  final Color border;

  /// Field / outlined-button borders (≥ 3:1).
  final Color borderStrong;

  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  final Color info;

  final Color verified;
  final Color verifiedContainer;

  /// "Restricted" in doc 04; in v0.2 used for owner-only private notes.
  final Color restricted;
  final Color restrictedContainer;

  /// Neutral grey on purpose.
  final Color unverified;
  final Color unverifiedContainer;

  /// 1dp top hairline on faux-glass surfaces (doc 04 §2.6).
  final Color glassHighlight;

  /// Third tonal step (background -> surface -> elevated): raised cards,
  /// the search pill, the floating nav bar.
  final Color surfaceElevated;

  /// 1px hairline borders at low alpha (premium, quieter than [border]).
  final Color hairline;

  /// Static hero gradient on Home (cheap: painted once, no animation).
  final Color heroGradientStart;
  final Color heroGradientEnd;

  /// Base colour for soft, low-opacity shadows (see AppShadows).
  final Color shadow;

  static const AppColors light = AppColors(
    brightness: Brightness.light,
    primary: Color(0xFF047857),
    onPrimary: Color(0xFFFFFFFF),
    primaryPressed: Color(0xFF065F46),
    primaryUi: Color(0xFF059669),
    primaryContainer: Color(0xFFD1FAE5),
    onPrimaryContainer: Color(0xFF064E3B),
    background: Color(0xFFF5F9F7),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEAF3EF),
    textPrimary: Color(0xFF0F1F1A),
    textSecondary: Color(0xFF3F524B),
    textTertiary: Color(0xFF5A6B65),
    border: Color(0xFFC9D8D1),
    borderStrong: Color(0xFF7A9089),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFEF3E2),
    onWarningContainer: Color(0xFF7A3A06),
    error: Color(0xFFB42318),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDECEA),
    onErrorContainer: Color(0xFF8A1C12),
    info: Color(0xFF1D4ED8),
    verified: Color(0xFF046C4E),
    verifiedContainer: Color(0xFFE3F5EC),
    restricted: Color(0xFF6B21A8),
    restrictedContainer: Color(0xFFF3E8FF), // derived
    unverified: Color(0xFF4B5563),
    unverifiedContainer: Color(0xFFF1F3F4),
    glassHighlight: Color(0xFFFFFFFF), // derived
    surfaceElevated: Color(0xFFFFFFFF),
    hairline: Color(0x1A0F1F1A), // textPrimary @ 10%
    heroGradientStart: Color(0xFFD5F2E3),
    heroGradientEnd: Color(0xFFF5F9F7), // = background
    shadow: Color(0xFF0B3B2C), // deep emerald-tinted shadow
  );

  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    primary: Color(0xFF34D399),
    onPrimary: Color(0xFF022C22),
    primaryPressed: Color(0xFF6EE7B7), // derived
    primaryUi: Color(0xFF10B981), // derived
    primaryContainer: Color(0xFF0F3A2C),
    onPrimaryContainer: Color(0xFFA7F3D0),
    background: Color(0xFF0B1512),
    surface: Color(0xFF13211C),
    surfaceVariant: Color(0xFF1A2B25),
    textPrimary: Color(0xFFE6F2EC),
    textSecondary: Color(0xFFA9BFB6),
    textTertiary: Color(0xFF82988F),
    border: Color(0xFF2A3D36),
    borderStrong: Color(0xFF5E7B70),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF3A2A08),
    onWarningContainer: Color(0xFFFCD34D),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A), // derived
    errorContainer: Color(0xFF3D1414),
    onErrorContainer: Color(0xFFFCA5A5),
    info: Color(0xFF60A5FA),
    verified: Color(0xFF6EE7B7),
    verifiedContainer: Color(0xFF0F3A2C),
    restricted: Color(0xFFC084FC),
    restrictedContainer: Color(0xFF2E1A47), // derived
    unverified: Color(0xFFB8C2BE),
    unverifiedContainer: Color(0xFF22302B),
    glassHighlight: Color(0xFF2E443B), // derived (lighter than surface)
    surfaceElevated: Color(0xFF1E322B),
    hairline: Color(0x1FE6F2EC), // textPrimary @ 12%
    heroGradientStart: Color(0xFF103B2D),
    heroGradientEnd: Color(0xFF0B1512), // = background
    shadow: Color(0xFF000000),
  );

  @override
  AppColors copyWith({Color? primary, Color? surface, Color? background}) {
    return AppColors(
      brightness: brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary,
      primaryPressed: primaryPressed,
      primaryUi: primaryUi,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      border: border,
      borderStrong: borderStrong,
      warning: warning,
      warningContainer: warningContainer,
      onWarningContainer: onWarningContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      info: info,
      verified: verified,
      verifiedContainer: verifiedContainer,
      restricted: restricted,
      restrictedContainer: restrictedContainer,
      unverified: unverified,
      unverifiedContainer: unverifiedContainer,
      glassHighlight: glassHighlight,
      surfaceElevated: surfaceElevated,
      hairline: hairline,
      heroGradientStart: heroGradientStart,
      heroGradientEnd: heroGradientEnd,
      shadow: shadow,
    );
  }

  /// Tokens switch discretely between themes (no colour tweening needed for
  /// a 200ms theme change); pick the target past the midpoint.
  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppColorsContext on BuildContext {
  /// Design tokens of the current theme. Falls back to light tokens when the
  /// extension is missing (e.g. a bare widget test without [AppTheme]).
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppColors.dark
          : AppColors.light);
}
