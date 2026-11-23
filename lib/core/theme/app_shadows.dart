import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Soft, low-opacity shadows (doc 04 §2.5: no heavy multi-layer shadows).
/// At most two layers, tinted with the theme's [AppColors.shadow]. In dark
/// mode elevation is carried mostly by the tonal surface steps.
abstract final class AppShadows {
  /// Resting card.
  static List<BoxShadow> card(AppColors c) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.30 : 0.05),
      offset: const Offset(0, 4),
      blurRadius: 14,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.18 : 0.03),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Raised elements: search pill, floating nav.
  static List<BoxShadow> raised(AppColors c) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.45 : 0.10),
      offset: const Offset(0, 10),
      blurRadius: 30,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.22 : 0.04),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  /// Emerald glow under the selected capsule / primary action.
  static List<BoxShadow> primaryGlow(AppColors c) => [
    BoxShadow(
      color: (c.isDark ? c.primaryUi : c.capsuleSelected).withValues(
        alpha: c.isDark ? 0.28 : 0.26,
      ),
      offset: const Offset(0, 4),
      blurRadius: 14,
      spreadRadius: -3,
    ),
  ];
}
