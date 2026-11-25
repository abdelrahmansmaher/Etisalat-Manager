import 'package:flutter/material.dart';

import '../router/app_page_transitions.dart';
import 'app_colors.dart';
import 'app_icons.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'trust_colors.dart';

/// Material 3 [ThemeData] built from the doc 04 tokens (not from a seed).
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light);
  static ThemeData dark() => _build(AppColors.dark);

  static ColorScheme colorScheme(AppColors c) => ColorScheme(
    brightness: c.brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.primaryContainer,
    onPrimaryContainer: c.onPrimaryContainer,
    secondary: c.accentText,
    onSecondary: c.surface,
    secondaryContainer: c.accentContainer,
    onSecondaryContainer: c.onAccentContainer,
    tertiary: c.info,
    onTertiary: c.surface,
    error: c.error,
    onError: c.onError,
    errorContainer: c.errorContainer,
    onErrorContainer: c.onErrorContainer,
    surface: c.surface,
    onSurface: c.textPrimary,
    onSurfaceVariant: c.textSecondary,
    surfaceDim: c.background,
    surfaceBright: c.surface,
    surfaceContainerLowest: c.background,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surfaceVariant,
    surfaceContainerHigh: c.surfaceElevated,
    surfaceContainerHighest: c.surfaceVariant,
    outline: c.borderStrong,
    outlineVariant: c.border,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: c.textPrimary,
    onInverseSurface: c.surface,
    inversePrimary: c.brightness == Brightness.light
        ? AppColors.dark.primary
        : AppColors.light.primary,
    // Tonal elevation via explicit surfaces + 1dp borders, no tint overlay.
    surfaceTint: Colors.transparent,
  );

  static ThemeData _build(AppColors c) {
    final scheme = colorScheme(c);
    final text = AppTypography.textTheme(
      primary: c.textPrimary,
      secondary: c.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.sansFamily,
      fontFamilyFallback: AppTypography.sansFallback,
      textTheme: text,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      extensions: [c, TrustColors.fromTokens(c)],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      iconTheme: IconThemeData(color: c.textSecondary, size: AppIconSize.nav),
      // Rounded, auto-mirrored back arrow everywhere (BackButton).
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(AppIcons.back),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.capsuleSurface,
        selectedColor: c.capsuleSelected,
        labelStyle: AppTypography.labelL.copyWith(color: c.textPrimary),
        secondaryLabelStyle: AppTypography.labelL.copyWith(
          color: c.onCapsuleSelected,
        ),
        checkmarkColor: c.onCapsuleSelected,
        side: BorderSide(color: c.hairline),
        shape: const StadiumBorder(),
        showCheckmark: false,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
        side: BorderSide(color: c.borderStrong, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : null,
        ),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primaryUi),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: c.hairline),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceVariant,
        hintStyle: text.bodyLarge?.copyWith(color: c.textTertiary),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: c.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: c.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: c.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.labelS.copyWith(
            color: states.contains(WidgetState.selected)
                ? c.textPrimary
                : c.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? c.onPrimaryContainer
                : c.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.capsuleSelected,
        indicatorShape: const StadiumBorder(),
        selectedIconTheme: IconThemeData(color: c.onCapsuleSelected),
        unselectedIconTheme: IconThemeData(color: c.textSecondary),
        selectedLabelTextStyle: AppTypography.labelL.copyWith(
          color: c.textPrimary,
        ),
        unselectedLabelTextStyle: AppTypography.labelL.copyWith(
          color: c.textSecondary,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
        minVerticalPadding: AppSpacing.xs,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTouchTarget, 48),
          textStyle: AppTypography.labelL,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTouchTarget, 48),
          textStyle: AppTypography.labelL,
          side: BorderSide(color: c.borderStrong),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTouchTarget, 48),
          textStyle: AppTypography.labelL,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.textPrimary,
        contentTextStyle: AppTypography.bodyM.copyWith(color: c.surface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.textPrimary,
          borderRadius: AppRadius.xsAll,
        ),
        textStyle: AppTypography.labelS.copyWith(color: c.surface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.l),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final p in TargetPlatform.values)
            p: const AppPageTransitionsBuilder(),
        },
      ),
    );
  }
}
