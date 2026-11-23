import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
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

/// Floating faux-glass bottom bar with an emphasised, raised circular center
/// action (Search). No blur (doc 04 §2.6: the bar sits above scrolling lists).
///
/// When [pageController] is given, each item's selection amount is derived
/// from the live page position, so the indicator pill morphs (fades + widens)
/// in sync with the user's swipe. Only this small row rebuilds per frame.
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

  double _page() {
    final pc = pageController;
    if (pc != null && pc.hasClients && pc.position.haveDimensions) {
      return pc.page ?? currentIndex.toDouble();
    }
    return currentIndex.toDouble();
  }

  Widget _row() {
    final page = _page();
    return Row(
      children: [
        for (var i = 0; i < destinations.length; i++)
          Expanded(
            child: _NavItem(
              key: ValueKey('nav-$i'),
              destination: destinations[i],
              amount: (1 - (page - i).abs()).clamp(0.0, 1.0),
              emphasized: i == centerIndex,
              onTap: () => onSelected(i),
            ),
          ),
      ],
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
              borderRadius: AppRadius.lgAll,
              boxShadow: AppShadows.raised(c),
            ),
            child: GlassSurface(
              opacity: 0.92,
              borderRadius: AppRadius.lgAll,
              borderColor: c.hairline,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                  horizontal: AppSpacing.xxs,
                ),
                child: pc == null
                    ? _row()
                    : AnimatedBuilder(
                        animation: pc,
                        builder: (context, _) => _row(),
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

    final Widget icon;
    if (emphasized) {
      icon = PressableScale(
        pressedScale: 0.9,
        child: Transform.scale(
          scale: 0.92 + 0.08 * t,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [c.primary, c.primaryPressed],
              ),
              boxShadow: AppShadows.primaryGlow(c),
            ),
            child: Icon(Icons.search_rounded, color: c.onPrimary, size: 26),
          ),
        ),
      );
    } else {
      icon = SizedBox(
        width: 56,
        height: 32,
        child: Center(
          child: Container(
            // Indicator morph: widens 32 → 56 and fades in with selection.
            width: 32 + 24 * t,
            height: 32,
            decoration: BoxDecoration(
              color: c.primaryContainer.withValues(alpha: t),
              borderRadius: AppRadius.fullAll,
            ),
            child: Icon(
              selected ? destination.selectedIcon : destination.icon,
              size: 24,
              color: Color.lerp(c.textSecondary, c.onPrimaryContainer, t),
            ),
          ),
        ),
      );
    }

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        highlightShape: BoxShape.circle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: AppSpacing.xxs),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.labelS.copyWith(
                  color: Color.lerp(c.textSecondary, c.textPrimary, t),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
