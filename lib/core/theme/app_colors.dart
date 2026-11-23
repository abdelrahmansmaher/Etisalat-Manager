import 'package:flutter/material.dart';

/// Colour system v2 (emerald-led, true neutrals, warm-gold accent).
///
/// Light: airy off-white background, white cards, quiet hairlines.
/// Dark: deep green-black layers with three clear elevation steps
/// (background → surface → surfaceElevated) and emerald that glows slightly.
///
/// Every text/background pair is asserted ≥ 4.5:1 (UI graphics ≥ 3:1) in
/// `test/core/theme/contrast_test.dart`, in both modes.
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
    required this.accent,
    required this.accentText,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.hairline,
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
    required this.capsuleSelected,
    required this.onCapsuleSelected,
    required this.capsuleSurface,
    required this.glassHighlight,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.shadow,
  });

  final Brightness brightness;

  /// Buttons, links, focus ring, highlighted numbers.
  final Color primary;
  final Color onPrimary;

  /// Pressed / hover; second stop of primary gradients.
  final Color primaryPressed;

  /// Non-text graphics only (large icons, progress, dots).
  final Color primaryUi;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Warm gold, used sparingly (price highlights, "new" marks). Graphics only.
  final Color accent;

  /// Gold that is safe for text on surfaces.
  final Color accentText;
  final Color accentContainer;
  final Color onAccentContainer;

  final Color background;
  final Color surface;

  /// Sunken fills: inputs, table stripes, code chips.
  final Color surfaceVariant;

  /// Raised cards, search pill, floating nav (third tonal step in dark).
  final Color surfaceElevated;

  final Color textPrimary;
  final Color textSecondary;

  /// Metadata (dates, sources, counts).
  final Color textTertiary;

  /// Decorative dividers only.
  final Color border;

  /// Field / outlined-control borders (≥ 3:1).
  final Color borderStrong;

  /// 1px low-alpha hairline around cards and capsules.
  final Color hairline;

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

  /// Owner-only private notes.
  final Color restricted;
  final Color restrictedContainer;

  /// Neutral grey on purpose.
  final Color unverified;
  final Color unverifiedContainer;

  /// Selected capsule fill (nav indicator, chips, segmented thumb) and its
  /// label colour — white on emerald in both modes.
  final Color capsuleSelected;
  final Color onCapsuleSelected;

  /// Unselected capsule fill (paired with [hairline] border).
  final Color capsuleSurface;

  /// 1dp top hairline on faux-glass surfaces.
  final Color glassHighlight;

  /// Static hero gradient (painted once, no animation).
  final Color heroGradientStart;
  final Color heroGradientEnd;

  /// Base colour for soft, low-opacity shadows (see AppShadows).
  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  static const AppColors light = AppColors(
    brightness: Brightness.light,
    primary: Color(0xFF047857),
    onPrimary: Color(0xFFFFFFFF),
    primaryPressed: Color(0xFF065F46),
    primaryUi: Color(0xFF059669),
    primaryContainer: Color(0xFFDDF4EA),
    onPrimaryContainer: Color(0xFF064E3B),
    accent: Color(0xFFB7811A),
    accentText: Color(0xFF8A5A00),
    accentContainer: Color(0xFFFBF1DC),
    onAccentContainer: Color(0xFF6B4500),
    background: Color(0xFFF4F7F5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEEF2F0),
    surfaceElevated: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0D1714),
    textSecondary: Color(0xFF424F4A),
    textTertiary: Color(0xFF5A6762),
    border: Color(0xFFDCE3E0),
    borderStrong: Color(0xFF7A8782),
    hairline: Color(0x170D1714), // textPrimary @ 9%
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFDF3E1),
    onWarningContainer: Color(0xFF7A3A06),
    error: Color(0xFFB42318),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDECEA),
    onErrorContainer: Color(0xFF8A1C12),
    info: Color(0xFF1D4ED8),
    verified: Color(0xFF046C4E),
    verifiedContainer: Color(0xFFE2F5EB),
    restricted: Color(0xFF6B21A8),
    restrictedContainer: Color(0xFFF3E8FF),
    unverified: Color(0xFF4B5563),
    unverifiedContainer: Color(0xFFF1F3F4),
    capsuleSelected: Color(0xFF047857),
    onCapsuleSelected: Color(0xFFFFFFFF),
    capsuleSurface: Color(0xFFFFFFFF),
    glassHighlight: Color(0xFFFFFFFF),
    heroGradientStart: Color(0xFFD9F2E6),
    heroGradientEnd: Color(0xFFF4F7F5), // = background
    shadow: Color(0xFF0B2B22),
  );

  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    primary: Color(0xFF3DDBA4),
    onPrimary: Color(0xFF022C22),
    primaryPressed: Color(0xFF7BEBC0),
    primaryUi: Color(0xFF1FBF89),
    primaryContainer: Color(0xFF0F3A2D),
    onPrimaryContainer: Color(0xFFA9F3D3),
    accent: Color(0xFFE7B95A),
    accentText: Color(0xFFF2C978),
    accentContainer: Color(0xFF2E2511),
    onAccentContainer: Color(0xFFF7DA98),
    background: Color(0xFF080D0B),
    surface: Color(0xFF0F1714),
    surfaceVariant: Color(0xFF16201C),
    surfaceElevated: Color(0xFF1A2622),
    textPrimary: Color(0xFFEDF4F1),
    textSecondary: Color(0xFFB5C3BD),
    textTertiary: Color(0xFF909E98),
    border: Color(0xFF26332E),
    borderStrong: Color(0xFF61736B),
    hairline: Color(0x1CEDF4F1), // textPrimary @ 11%
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF30240A),
    onWarningContainer: Color(0xFFFCD34D),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF381517),
    onErrorContainer: Color(0xFFFCA5A5),
    info: Color(0xFF7CB4FB),
    verified: Color(0xFF6EE7B7),
    verifiedContainer: Color(0xFF0F3A2D),
    restricted: Color(0xFFC99BFC),
    restrictedContainer: Color(0xFF2B1A42),
    unverified: Color(0xFFB8C2BE),
    unverifiedContainer: Color(0xFF1E2926),
    capsuleSelected: Color(0xFF047857),
    onCapsuleSelected: Color(0xFFFFFFFF),
    capsuleSurface: Color(0xFF16201C),
    glassHighlight: Color(0xFF2A3833),
    heroGradientStart: Color(0xFF0D3326),
    heroGradientEnd: Color(0xFF080D0B), // = background
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
      accent: accent,
      accentText: accentText,
      accentContainer: accentContainer,
      onAccentContainer: onAccentContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant,
      surfaceElevated: surfaceElevated,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      border: border,
      borderStrong: borderStrong,
      hairline: hairline,
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
      capsuleSelected: capsuleSelected,
      onCapsuleSelected: onCapsuleSelected,
      capsuleSurface: capsuleSurface,
      glassHighlight: glassHighlight,
      heroGradientStart: heroGradientStart,
      heroGradientEnd: heroGradientEnd,
      shadow: shadow,
    );
  }

  /// Tokens switch discretely between themes (the 200ms theme change is a
  /// cross-fade of the whole tree); pick the target past the midpoint.
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
