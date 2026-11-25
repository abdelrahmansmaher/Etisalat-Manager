import 'package:flutter/material.dart';

/// Colour system v4, taken from the SIM card: a deep navy body with gold
/// contacts.
///
/// * **Navy** carries structure, actions and selection (masthead, buttons,
///   selected capsules, links).
/// * **Gold** means a price and nothing else.
/// * **Green** means "confirmed" and nothing else.
///
/// Light: a cool slate page, pure white surfaces, near-black navy text.
/// Dark: midnight, with three clear elevation steps (background, surface,
/// surfaceElevated).
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
    required this.capsuleSelected,
    required this.onCapsuleSelected,
    required this.capsuleSurface,
    required this.glassHighlight,
    required this.masthead,
    required this.onMasthead,
    required this.onMastheadMuted,
    required this.mastheadField,
    required this.mastheadPrice,
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

  /// Selected capsule fill (nav indicator, chips, segmented thumb) and its
  /// label colour — white on navy in both modes.
  final Color capsuleSelected;
  final Color onCapsuleSelected;

  /// Unselected capsule fill (paired with [hairline] border).
  final Color capsuleSurface;

  /// 1dp top hairline on faux-glass surfaces.
  final Color glassHighlight;

  /// The SIM body: tab masthead and the package price panel.
  final Color masthead;
  final Color onMasthead;
  final Color onMastheadMuted;

  /// Search pill and code row sitting on [masthead].
  final Color mastheadField;

  /// Gold price on [masthead] (the SIM contacts).
  final Color mastheadPrice;

  /// Base colour for soft, low-opacity shadows (see AppShadows).
  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  static const AppColors light = AppColors(
    brightness: Brightness.light,
    primary: Color(0xFF1D3180),
    onPrimary: Color(0xFFFFFFFF),
    primaryPressed: Color(0xFF131F56),
    primaryUi: Color(0xFF3D57BD),
    primaryContainer: Color(0xFFE1E7FA),
    onPrimaryContainer: Color(0xFF16265F),
    accent: Color(0xFFB27A12),
    accentText: Color(0xFF875700),
    accentContainer: Color(0xFFFBF0D6),
    onAccentContainer: Color(0xFF664100),
    background: Color(0xFFE9EDF5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEFF2F9),
    surfaceElevated: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0A1230),
    textSecondary: Color(0xFF354060),
    textTertiary: Color(0xFF525C7B),
    border: Color(0xFFC8D0E2),
    borderStrong: Color(0xFF6F7A99),
    hairline: Color(0x1F0A1230),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFDF3E1),
    onWarningContainer: Color(0xFF7A3A06),
    error: Color(0xFFB42318),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDECEA),
    onErrorContainer: Color(0xFF8A1C12),
    info: Color(0xFF1D4ED8),
    verified: Color(0xFF0B6B45),
    verifiedContainer: Color(0xFFE0F4E9),
    capsuleSelected: Color(0xFF1A2C70),
    onCapsuleSelected: Color(0xFFFFFFFF),
    capsuleSurface: Color(0xFFFFFFFF),
    glassHighlight: Color(0xFFFFFFFF),
    masthead: Color(0xFF142258),
    onMasthead: Color(0xFFFFFFFF),
    onMastheadMuted: Color(0xFFB9C5EE),
    mastheadField: Color(0xFFFFFFFF),
    mastheadPrice: Color(0xFFF5CB6E),
    shadow: Color(0xFF0A1437),
  );

  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    primary: Color(0xFFA3B6FF),
    onPrimary: Color(0xFF0B1440),
    primaryPressed: Color(0xFFC5D0FF),
    primaryUi: Color(0xFF7389F0),
    primaryContainer: Color(0xFF1C2B63),
    onPrimaryContainer: Color(0xFFD0D9FF),
    accent: Color(0xFFE3B04B),
    accentText: Color(0xFFF0C56B),
    accentContainer: Color(0xFF2C2410),
    onAccentContainer: Color(0xFFF7DA98),
    background: Color(0xFF060A18),
    surface: Color(0xFF0C1226),
    surfaceVariant: Color(0xFF1C2648),
    surfaceElevated: Color(0xFF121A34),
    textPrimary: Color(0xFFF0F3FC),
    textSecondary: Color(0xFFBFC8E3),
    textTertiary: Color(0xFF98A3C5),
    border: Color(0xFF2A3559),
    borderStrong: Color(0xFF6B78A3),
    hairline: Color(0x24AEBDFF),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF30240A),
    onWarningContainer: Color(0xFFFCD34D),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF381517),
    onErrorContainer: Color(0xFFFCA5A5),
    info: Color(0xFF7CB4FB),
    verified: Color(0xFF6BDDAA),
    verifiedContainer: Color(0xFF0E3729),
    capsuleSelected: Color(0xFF3450BF),
    onCapsuleSelected: Color(0xFFFFFFFF),
    capsuleSurface: Color(0xFF121A34),
    glassHighlight: Color(0xFF2A3661),
    masthead: Color(0xFF0E1735),
    onMasthead: Color(0xFFF5F7FF),
    onMastheadMuted: Color(0xFFA7B4DE),
    mastheadField: Color(0xFF1E2A57),
    mastheadPrice: Color(0xFFF5CB6E),
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
      capsuleSelected: capsuleSelected,
      onCapsuleSelected: onCapsuleSelected,
      capsuleSurface: capsuleSurface,
      glassHighlight: glassHighlight,
      masthead: masthead,
      onMasthead: onMasthead,
      onMastheadMuted: onMastheadMuted,
      mastheadField: mastheadField,
      mastheadPrice: mastheadPrice,
      shadow: shadow,
    );
  }

  /// Interpolates every token, so the 300ms theme switch is a smooth
  /// cross-fade of colours rather than a hard cut.
  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primaryPressed: l(primaryPressed, other.primaryPressed),
      primaryUi: l(primaryUi, other.primaryUi),
      primaryContainer: l(primaryContainer, other.primaryContainer),
      onPrimaryContainer: l(onPrimaryContainer, other.onPrimaryContainer),
      accent: l(accent, other.accent),
      accentText: l(accentText, other.accentText),
      accentContainer: l(accentContainer, other.accentContainer),
      onAccentContainer: l(onAccentContainer, other.onAccentContainer),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceVariant: l(surfaceVariant, other.surfaceVariant),
      surfaceElevated: l(surfaceElevated, other.surfaceElevated),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      hairline: l(hairline, other.hairline),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
      error: l(error, other.error),
      onError: l(onError, other.onError),
      errorContainer: l(errorContainer, other.errorContainer),
      onErrorContainer: l(onErrorContainer, other.onErrorContainer),
      info: l(info, other.info),
      verified: l(verified, other.verified),
      verifiedContainer: l(verifiedContainer, other.verifiedContainer),
      capsuleSelected: l(capsuleSelected, other.capsuleSelected),
      onCapsuleSelected: l(onCapsuleSelected, other.onCapsuleSelected),
      capsuleSurface: l(capsuleSurface, other.capsuleSurface),
      glassHighlight: l(glassHighlight, other.glassHighlight),
      masthead: l(masthead, other.masthead),
      onMasthead: l(onMasthead, other.onMasthead),
      onMastheadMuted: l(onMastheadMuted, other.onMastheadMuted),
      mastheadField: l(mastheadField, other.mastheadField),
      mastheadPrice: l(mastheadPrice, other.mastheadPrice),
      shadow: l(shadow, other.shadow),
    );
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
