import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Soft, low-opacity shadows (doc 04 §2.5: no heavy multi-layer shadows).
/// At most two layers, tinted with the theme's [AppColors.shadow].
abstract final class AppShadows {
  /// Resting card.
  static List<BoxShadow> card(AppColors c) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.28 : 0.06),
      offset: const Offset(0, 6),
      blurRadius: 18,
      spreadRadius: -6,
    ),
  ];

  /// Raised elements: search pill, floating nav, center search button.
  static List<BoxShadow> raised(AppColors c) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.40 : 0.10),
      offset: const Offset(0, 10),
      blurRadius: 28,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: c.shadow.withValues(alpha: c.isDark ? 0.20 : 0.04),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  /// Emerald glow under the primary (center search) action.
  static List<BoxShadow> primaryGlow(AppColors c) => [
    BoxShadow(
      color: c.primary.withValues(alpha: c.isDark ? 0.30 : 0.32),
      offset: const Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];
}

extension AppColorsBrightness on AppColors {
  bool get isDark => brightness == Brightness.dark;
}
