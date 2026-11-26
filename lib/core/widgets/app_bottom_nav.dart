import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'badges.dart';
import 'liquid_glass.dart';
import 'motion.dart';

@immutable
class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// A dot on the icon: something new waits on this tab.
  final bool badge;

  AppNavDestination withBadge(bool on) => AppNavDestination(
    icon: icon,
    selectedIcon: selectedIcon,
    label: label,
    badge: on,
  );
}

/// Floating liquid-glass dock, iOS style.
///
/// * A frosted capsule the content scrolls under, with a round search
///   button beside it.
/// * The selected tab sits under a clear glass "lens" that glides to the
///   next tab on a spring: its leading edge runs ahead and the trailing edge
///   catches up, so it stretches like a drop of liquid and settles.
/// * While the user swipes between tabs the lens follows the finger 1:1.
/// * The selected icon springs, and turns navy.
///
/// Labels are clamped to 1.3x text scale so four tabs always fit at 360dp.
class AppBottomNav extends StatefulWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
    this.pageController,
    this.swiping,
    this.onSearch,
    this.searchLabel,
  });

  final List<AppNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final PageController? pageController;

  /// True while the user drags the tab pages.
  final ValueListenable<bool>? swiping;

  /// Round search button beside the dock.
  final VoidCallback? onSearch;
  final String? searchLabel;

  /// Height of the tab items (the dock adds [_inset] around them).
  static const double itemHeight = 54;
  static const double _inset = 5;

  static final TextStyle labelStyle = AppTypography.labelS.copyWith(
    fontWeight: FontWeight.w600,
  );

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav>
    with TickerProviderStateMixin {
  // Lens edges, in "boundary" units: tab i spans [i, i + 1].
  late final AnimationController _start = AnimationController.unbounded(
    vsync: this,
    value: widget.currentIndex.toDouble(),
  );
  late final AnimationController _end = AnimationController.unbounded(
    vsync: this,
    value: widget.currentIndex + 1.0,
  );

  bool get _swiping => widget.swiping?.value ?? false;

  @override
  void initState() {
    super.initState();
    widget.swiping?.addListener(_onSwipingChanged);
  }

  @override
  void didUpdateWidget(AppBottomNav old) {
    super.didUpdateWidget(old);
    if (old.swiping != widget.swiping) {
      old.swiping?.removeListener(_onSwipingChanged);
      widget.swiping?.addListener(_onSwipingChanged);
    }
    if (old.currentIndex != widget.currentIndex && !_swiping) {
      _glideTo(widget.currentIndex);
    }
  }

  void _onSwipingChanged() {
    if (_swiping) {
      _start.stop();
      _end.stop();
    } else {
      // The swipe ended on a page: rest the lens there.
      _glideTo(widget.currentIndex);
    }
  }

  /// Moves the lens to [index]: the leading edge on a quick spring, the
  /// trailing one on a softer one (the liquid stretch).
  void _glideTo(int index) {
    final reduce = AppMotion.reduced(context);
    final a = index.toDouble(), b = index + 1.0;
    if (reduce) {
      _start.value = a;
      _end.value = b;
      return;
    }
    final forward = b > _end.value;
    final lead = AppMotion.springOf(response: 0.34, dampingFraction: 0.78);
    final trail = AppMotion.springOf(response: 0.5, dampingFraction: 0.86);
    _start.animateWith(
      SpringSimulation(forward ? trail : lead, _start.value, a, _start.velocity)
        ..tolerance = const Tolerance(distance: 0.001, velocity: 0.01),
    );
    _end.animateWith(
      SpringSimulation(forward ? lead : trail, _end.value, b, _end.velocity)
        ..tolerance = const Tolerance(distance: 0.001, velocity: 0.01),
    );
  }

  @override
  void dispose() {
    widget.swiping?.removeListener(_onSwipingChanged);
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  double? _page() {
    final pc = widget.pageController;
    if (pc != null && pc.hasClients && pc.position.haveDimensions) {
      return (pc.page ?? widget.currentIndex.toDouble()).clamp(
        0.0,
        widget.destinations.length - 1.0,
      );
    }
    return null;
  }

  /// Item widths: each label gets the room it needs and the spare space is
  /// shared equally, so a long label never squeezes the others.
  List<double> _widths(BuildContext context, double total) {
    final scaler = MediaQuery.textScalerOf(context);
    final natural = [
      for (final d in widget.destinations)
        () {
          final tp = TextPainter(
            text: TextSpan(text: d.label, style: AppBottomNav.labelStyle),
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
    if (spare >= 0) return [for (final w in natural) w + spare];
    // Too little room: every tab keeps the minimum target and the rest is
    // shared by how much more each label wanted (labels then scale down).
    const min = AppSpacing.minTouchTarget;
    final extra = natural.fold(0.0, (a, w) => a + (w - min));
    final room = total - min * natural.length;
    if (room <= 0 || extra <= 0) {
      return [for (final _ in natural) total / natural.length];
    }
    return [for (final w in natural) min + (w - min) * room / extra];
  }

  /// Boundary units to pixels from the start edge.
  static double _px(List<double> widths, double b) {
    final n = widths.length;
    final clamped = b.clamp(-0.4, n + 0.4);
    var x = 0.0;
    var i = 0;
    var rest = clamped;
    while (rest >= 1 && i < n) {
      x += widths[i];
      rest -= 1;
      i++;
    }
    if (rest < 0) return x + rest * widths.first;
    return x + rest * (i < n ? widths[i] : widths.last);
  }

  Widget _bar(BuildContext context, double total) {
    final n = widget.destinations.length;
    final widths = _widths(context, total);

    // Edges: the finger while swiping, otherwise the springs.
    final page = _page();
    final double a, b;
    if (_swiping && page != null) {
      a = page;
      b = page + 1;
    } else {
      a = _start.value;
      b = _end.value;
    }
    final left = _px(widths, a), right = _px(widths, b);
    final start = left < right ? left : right;
    final width = (right - left).abs().clamp(24.0, total);
    final center = (a + b) / 2 - 0.5;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppBottomNav.itemHeight),
      child: Stack(
        children: [
          PositionedDirectional(
            key: const ValueKey('nav-indicator'),
            start: start,
            width: width,
            top: 0,
            bottom: 0,
            child: const _Lens(),
          ),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                SizedBox(
                  width: widths[i],
                  child: _NavItem(
                    key: ValueKey('nav-$i'),
                    destination: widget.destinations[i],
                    amount: (1 - (center - i).abs()).clamp(0.0, 1.0),
                    selected: i == widget.currentIndex,
                    onTap: () {
                      if (i != widget.currentIndex) {
                        HapticFeedback.selectionClick();
                      }
                      widget.onSelected(i);
                    },
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
    final pc = widget.pageController;
    final listenable = Listenable.merge([_start, _end, ?pc, ?widget.swiping]);
    final dock = LiquidGlass(
      key: const ValueKey('nav-glass'),
      tone: GlassTone.chrome,
      blur: true,
      stadium: true,
      shadows: AppShadows.raised(c),
      child: Padding(
        padding: const EdgeInsets.all(AppBottomNav._inset),
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedBuilder(
            animation: listenable,
            builder: (context, _) => _bar(context, constraints.maxWidth),
          ),
        ),
      ),
    );
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(child: dock),
              if (widget.onSearch != null) ...[
                const SizedBox(width: AppSpacing.xs + 2),
                _SearchOrb(
                  onTap: widget.onSearch!,
                  label: widget.searchLabel ?? '',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The clear glass lens over the selected tab.
class _Lens extends StatelessWidget {
  const _Lens();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.fullAll,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: c.isDark
              ? [
                  Colors.white.withValues(alpha: 0.20),
                  Colors.white.withValues(alpha: 0.09),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  c.primaryContainer.withValues(alpha: 0.85),
                ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: c.isDark ? 0.22 : 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: c.primaryUi.withValues(alpha: c.isDark ? 0.30 : 0.22),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
    );
  }
}

/// Round glass search button beside the dock.
class _SearchOrb extends StatelessWidget {
  const _SearchOrb({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  static const double size = AppBottomNav.itemHeight + 2 * AppBottomNav._inset;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: PressableScale(
        pressedScale: 0.9,
        child: SizedBox.square(
          dimension: size,
          child: LiquidGlass(
            key: const ValueKey('nav-search'),
            tone: GlassTone.chrome,
            blur: true,
            stadium: true,
            shadows: AppShadows.raised(c),
            child: Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Center(
                  child: Icon(
                    AppIcons.search,
                    size: AppIconSize.nav,
                    color: c.primary,
                  ),
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
    required this.selected,
    required this.onTap,
  });

  final AppNavDestination destination;

  /// 0 = away from the lens ... 1 = under it (fractional while moving).
  final double amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = Color.lerp(c.textSecondary, c.primary, amount)!;
    // Vibrancy: a soft halo keeps icons and names clear over anything the
    // clear glass shows.
    final halo = [
      Shadow(
        color: (c.isDark ? Colors.black : Colors.white).withValues(
          alpha: c.isDark ? 0.55 : 0.85,
        ),
        blurRadius: 8,
      ),
    ];
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      excludeSemantics: true,
      child: PressableScale(
        pressedScale: 0.9,
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppBottomNav.itemHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  SpringPop(
                    trigger: selected,
                    from: 0.72,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          amount > 0.5
                              ? destination.selectedIcon
                              : destination.icon,
                          size: AppIconSize.nav,
                          color: color,
                          shadows: halo,
                        ),
                        if (destination.badge)
                          const PositionedDirectional(
                            key: ValueKey('nav-badge'),
                            top: -2,
                            end: -4,
                            child: BadgeDot(),
                          ),
                      ],
                    ),
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
                        style: AppBottomNav.labelStyle.copyWith(
                          color: color,
                          shadows: halo,
                          fontWeight: amount > 0.5
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
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
