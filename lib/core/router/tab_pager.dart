import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';

/// Shares the shell's [PageController] between the bottom nav (indicator
/// follows swipe progress) and [TabPager] (go_router's branch container).
class TabPagerScope extends InheritedWidget {
  const TabPagerScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final PageController controller;

  static PageController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabPagerScope>()?.controller;

  @override
  bool updateShouldNotify(TabPagerScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Swipeable container for the 5 tab branches (used as
/// `StatefulShellRoute(navigatorContainerBuilder: ...)`).
///
/// * Horizontal swipe changes tab. [PageView] follows [Directionality], so in
///   Arabic the page order matches the visual (RTL) tab order: swiping the
///   finger rightwards reveals the next tab on the left.
/// * Tapping a tab animates the pager (≤ 300ms, easeOutCubic) instead of a
///   hard cut; with "remove animations" it jumps.
/// * Every branch is kept alive (state, scroll position, text survive).
///
/// ### Gesture conflicts — how screens opt out
/// Inner horizontal scrollables (chip rows, comparison tables) already win:
/// the innermost recognizer gets the drag first, and the pager only receives
/// drags nobody below claimed. For content that handles horizontal drags
/// without scrolling (sliders, signature pads, maps, carousels that should
/// not hand over at their edges) wrap it in [TabSwipeOptOut].
class TabPager extends StatefulWidget {
  const TabPager({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<TabPager> createState() => _TabPagerState();
}

class _TabPagerState extends State<TabPager> {
  PageController? _fallback;

  /// True while a tap-driven animation runs: intermediate pages passed on
  /// the way must not switch branches.
  bool _programmatic = false;

  PageController get _controller =>
      TabPagerScope.maybeOf(context) ??
      (_fallback ??= PageController(
        initialPage: widget.navigationShell.currentIndex,
      ));

  @override
  void didUpdateWidget(TabPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.navigationShell.currentIndex;
    final controller = _controller;
    if (!controller.hasClients) return;
    final current = controller.page?.round() ?? target;
    if (current == target || _programmatic) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateTo(target));
  }

  Future<void> _animateTo(int index) async {
    final controller = _controller;
    if (!mounted || !controller.hasClients) return;
    final duration = AppMotion.resolve(context, AppMotion.max);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _programmatic = true;
    try {
      if (reduce) {
        controller.jumpToPage(index);
      } else {
        // For non-adjacent tabs, jump next to the target first so the
        // animation covers a single page instead of sliding through
        // every tab in between.
        final from = controller.page?.round() ?? index;
        if ((index - from).abs() > 1) {
          controller.jumpToPage(index > from ? index - 1 : index + 1);
        }
        await controller.animateToPage(
          index,
          duration: duration,
          curve: AppMotion.enter,
        );
      }
    } finally {
      _programmatic = false;
    }
  }

  void _onPageChanged(int index) {
    if (_programmatic) return;
    if (index == widget.navigationShell.currentIndex) return;
    // A swipe away from a screen should not keep the keyboard up.
    FocusManager.instance.primaryFocus?.unfocus();
    widget.navigationShell.goBranch(index);
  }

  @override
  void dispose() {
    _fallback?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      onPageChanged: _onPageChanged,
      // Snappy but smooth; no overscroll glow at the first/last tab.
      physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
      children: [for (final child in widget.children) _KeepAlive(child: child)],
    );
  }
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Isolate repaints of each tab from the pager's transform.
    return RepaintBoundary(child: widget.child);
  }
}

/// Claims horizontal drags inside [child] so they never switch tabs.
///
/// ```dart
/// TabSwipeOptOut(child: Slider(...))
/// ```
class TabSwipeOptOut extends StatelessWidget {
  const TabSwipeOptOut({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        HorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              HorizontalDragGestureRecognizer
            >(
              () => HorizontalDragGestureRecognizer(debugOwner: this),
              (r) => r
                ..onStart = (_) {}
                ..onUpdate = (_) {}
                ..onEnd = (_) {},
            ),
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
