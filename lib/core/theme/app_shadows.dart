import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Soft, low-opacity shadows (doc 04 §2.5: no heavy multi-layer shadows).
/// At most two layers, tinted with the theme's [AppColors.shadow]. In dark
/// mode elevation is carried mostly by the tonal surface steps.
abstract final class AppShadows {
  /// Resting card.
  static List<BoxShadow> card(AppColors c) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.34 : 0.08),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.18 : 0.04),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Raised elements: search pill, floating nav.
  static List<BoxShadow> raised(AppColors c) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.50 : 0.16),
      offset: const Offset(0, 10),
      blurRadius: 30,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.22 : 0.06),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];
}
