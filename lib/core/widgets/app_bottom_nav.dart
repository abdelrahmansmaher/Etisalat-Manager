import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'glass_surface.dart';
import '../theme/app_icons.dart';

@immutable
class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating capsule navigation bar.
///
/// A fully rounded, faux-glass pill (no blur — it floats above scrolling
/// lists, doc 04 §2.6). The selected tab is a filled emerald capsule with
/// icon + label; the others are icon-only. The capsule **slides and
/// stretches** between tabs and follows the live swipe position of
/// [pageController], so it tracks the user's finger. The center item
/// (Search) is highlighted with a tinted circle while unselected.
///
/// Labels are clamped to 1.3× text scale so five tabs always fit at 360dp;
/// content screens honour the full 2.0× scale.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
    this.centerIndex = 2,
    this.pageController,
  });

  final List<AppNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final int centerIndex;
  final PageController? pageController;

  /// Height of the capsule items (the bar adds [_inset] around them).
  static const double itemHeight = 52;
  static const double _inset = 6;

  double _page() {
    final pc = pageController;
    if (pc != null && pc.hasClients && pc.position.haveDimensions) {
      return (pc.page ?? currentIndex.toDouble()).clamp(
        0.0,
        destinations.length - 1.0,
      );
    }
    return currentIndex.toDouble();
  }

  /// Icon-only width of an unselected item (≥ 44dp touch width).
  static const double baseWidth = 44;

  /// The selected capsule never takes more than this share of the bar, so
  /// it stays a compact pill instead of competing with page content.
  static const double maxSelectedShare = 0.3;

  /// Horizontal padding inside the selected capsule, per side.
  static const double capsulePadding = 12;

  static TextStyle labelStyle(AppColors c) => AppTypography.labelL.copyWith(
    color: c.onCapsuleSelected,
    fontWeight: FontWeight.w600,
  );

  /// Width the selected capsule needs for icon + label (hugging content),
  /// capped at [maxSelectedShare] of [total].
  static double selectedWidth(
    String label,
    TextStyle style,
    TextScaler scaler,
    double total,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final w = tp.width + AppIconSize.nav + 6 + capsulePadding * 2;
    tp.dispose();
    return w.clamp(baseWidth, total * maxSelectedShare);
  }

  Widget _bar(BuildContext context, double total) {
    final c = context.colors;
    final page = _page();
    final n = destinations.length;
    final style = labelStyle(c);
    final scaler = MediaQuery.textScalerOf(context);
    final amounts = [
      for (var i = 0; i < n; i++) (1 - (page - i).abs()).clamp(0.0, 1.0),
    ];
    // Each item: icon-only base, growing toward its own content width as it
    // becomes selected; the free space is spread evenly around the items.
    final widths = [
      for (var i = 0; i < n; i++)
        baseWidth +
            (selectedWidth(destinations[i].label, style, scaler, total) -
                    baseWidth) *
                amounts[i],
    ];
    final used = widths.fold(0.0, (a, b) => a + b);
    final gap = ((total - used) / n).clamp(0.0, double.infinity);
    var indicatorStart = 0.0;
    var indicatorWidth = 0.0;
    var acc = 0.0;
    for (var i = 0; i < n; i++) {
      indicatorStart += amounts[i] * (acc + gap / 2);
      indicatorWidth += amounts[i] * widths[i];
      acc += widths[i] + gap;
    }

    return SizedBox(
      height: itemHeight,
      child: Stack(
        children: [
          PositionedDirectional(
            key: const ValueKey('nav-indicator'),
            start: indicatorStart,
            width: indicatorWidth,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.capsuleSelected,
                borderRadius: AppRadius.fullAll,
                boxShadow: AppShadows.primaryGlow(c),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                SizedBox(
                  width: widths[i] + gap,
                  child: Center(
                    child: SizedBox(
                      width: widths[i],
                      child: _NavItem(
                        key: ValueKey('nav-$i'),
                        destination: destinations[i],
                        amount: amounts[i],
                        emphasized: i == centerIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pc = pageController;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.fullAll,
              boxShadow: AppShadows.raised(c),
            ),
            child: GlassSurface(
              opacity: 0.94,
              borderRadius: AppRadius.fullAll,
              borderColor: c.hairline,
              child: Padding(
                padding: const EdgeInsets.all(_inset),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    return pc == null
                        ? _bar(context, w)
                        : AnimatedBuilder(
                            animation: pc,
                            builder: (context, _) => _bar(context, w),
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.destination,
    required this.amount,
    required this.emphasized,
    required this.onTap,
  });

  final AppNavDestination destination;

  /// 0 = not selected … 1 = fully selected (fractional mid-swipe).
  final double amount;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = amount > 0.5;
    final t = AppMotion.enter.transform(amount);
    final iconColor = Color.lerp(
      emphasized ? c.primary : c.textSecondary,
      c.onCapsuleSelected,
      t,
    )!;

    Widget icon = Icon(
      selected ? destination.selectedIcon : destination.icon,
      size: AppIconSize.nav,
      color: iconColor,
    );
    if (emphasized) {
      // Search stands out while unselected: a tinted circle that fades into
      // the sliding capsule as it arrives (and shrinks to the plain icon
      // size so the selected capsule stays as compact as the others).
      final d = 38 - (38 - AppIconSize.nav) * t;
      icon = Container(
        width: d,
        height: d,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.primaryContainer.withValues(alpha: 1 - t),
        ),
        child: icon,
      );
    }

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      excludeSemantics: true,
      child: PressableScale(
        pressedScale: 0.92,
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppBottomNav.capsulePadding * t,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    // The label is always in the tree; it is revealed by the
                    // capsule's growth (width factor = selection amount).
                    Flexible(
                      child: ClipRect(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: t,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: AppSpacing.xs - 2,
                            ),
                            child: Text(
                              destination.label,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelL.copyWith(
                                color: c.onCapsuleSelected.withValues(alpha: t),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
