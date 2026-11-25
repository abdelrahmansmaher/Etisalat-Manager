import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'glass_surface.dart';

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
/// A fully rounded, faux-glass pill (no blur: it floats above scrolling
/// lists). Every tab shows icon and label; the selected one sits on a navy
/// capsule that slides and stretches between tabs and follows the live swipe
/// position of [pageController].
///
/// Labels are clamped to 1.3× text scale so four tabs always fit at 360dp;
/// content screens honour the full 2.0× scale.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
    this.pageController,
  });

  final List<AppNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final PageController? pageController;

  /// Height of the capsule items (the bar adds [_inset] around them).
  static const double itemHeight = 54;
  static const double _inset = 5;

  static final TextStyle labelStyle = AppTypography.labelS.copyWith(
    fontWeight: FontWeight.w600,
  );

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

  /// Item widths: each label gets the room it needs and the spare space is
  /// shared equally, so a long label never squeezes the others.
  List<double> _widths(BuildContext context, double total) {
    final scaler = MediaQuery.textScalerOf(context);
    final natural = [
      for (final d in destinations)
        () {
          final tp = TextPainter(
            text: TextSpan(text: d.label, style: labelStyle),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          final w = tp.width + 2 * AppSpacing.xs;
          tp.dispose();
          return w < AppSpacing.minTouchTarget ? AppSpacing.minTouchTarget : w;
        }(),
    ];
    final sum = natural.fold(0.0, (a, b) => a + b);
    final spare = (total - sum) / natural.length;
    return spare >= 0
        ? [for (final w in natural) w + spare]
        : [for (final w in natural) w * total / sum];
  }

  Widget _bar(BuildContext context, double total) {
    final c = context.colors;
    final page = _page();
    final n = destinations.length;
    final widths = _widths(context, total);
    final amounts = [
      for (var i = 0; i < n; i++) (1 - (page - i).abs()).clamp(0.0, 1.0),
    ];
    var start = 0.0;
    var width = 0.0;
    var acc = 0.0;
    for (var i = 0; i < n; i++) {
      start += amounts[i] * acc;
      width += amounts[i] * widths[i];
      acc += widths[i];
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: itemHeight),
      child: Stack(
        children: [
          PositionedDirectional(
            key: const ValueKey('nav-indicator'),
            start: start,
            width: width,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.capsuleSelected,
                borderRadius: AppRadius.fullAll,
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                SizedBox(
                  width: widths[i],
                  child: _NavItem(
                    key: ValueKey('nav-$i'),
                    destination: destinations[i],
                    amount: amounts[i],
                    onTap: () => onSelected(i),
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
        minimum: const EdgeInsets.only(bottom: AppSpacing.xs),
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
              opacity: 0.97,
              borderRadius: AppRadius.fullAll,
              borderColor: c.border,
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
    required this.onTap,
  });

  final AppNavDestination destination;

  /// 0 = not selected … 1 = fully selected (fractional mid-swipe).
  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = amount > 0.5;
    final color = Color.lerp(c.textSecondary, c.onCapsuleSelected, amount)!;
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      excludeSemantics: true,
      child: PressableScale(
        pressedScale: 0.94,
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppBottomNav.itemHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: AppIconSize.nav,
                    color: color,
                  ),
                  const SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        softWrap: false,
                        style: AppBottomNav.labelStyle.copyWith(color: color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
