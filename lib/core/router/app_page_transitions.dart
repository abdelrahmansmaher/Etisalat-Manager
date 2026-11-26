import 'package:flutter/cupertino.dart' show CupertinoPageTransition;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Shared push/pop transition: the iOS one. The new page slides in from
/// the trailing edge (from the left in Arabic) over the old page, which
/// drifts a third of the way back under it, with the iOS curve and a soft
/// shadow on the incoming edge. A back swipe follows the finger 1:1.
///
/// With "remove animations" it collapses to a plain fade.
class AppPageTransition extends StatelessWidget {
  const AppPageTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    this.linear = false,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  /// True while a user gesture drives the route (follow the finger 1:1).
  final bool linear;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    }
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: linear,
      child: child,
    );
  }
}

/// Registers [AppPageTransition] for every platform in
/// `ThemeData.pageTransitionsTheme`, so plain `MaterialPageRoute`s and
/// go_router's default `MaterialPage`s share the same motion.
/// (Edge swipe-back needs [AppPageRoute] / [AppPage].)
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.page;

  @override
  Duration get reverseTransitionDuration => AppMotion.page;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      linear: route.navigator?.userGestureInProgress ?? false,
      child: child,
    );
  }
}

/// Page route with [AppPageTransition] and a Cupertino-style edge swipe-back
/// on **all** platforms (start edge: left in English, right in Arabic).
class AppPageRoute<T> extends PageRoute<T> {
  AppPageRoute({required this.builder, super.settings, super.fullscreenDialog});

  final WidgetBuilder builder;

  /// Width of the start-edge strip that begins a back swipe.
  static const double edgeWidth = 24;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => AppMotion.page;

  @override
  Duration get reverseTransitionDuration => AppMotion.page;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  bool get _canSwipeBack =>
      !isFirst &&
      !fullscreenDialog &&
      !willHandlePopInternally &&
      popDisposition == RoutePopDisposition.pop;

  void _onSwipeStart() => navigator?.didStartUserGesture();

  void _onSwipeUpdate(double fraction) {
    final c = controller;
    if (c != null) c.value = (c.value - fraction).clamp(0.0, 1.0);
  }

  void _onSwipeEnd(double fractionVelocity) {
    final c = controller;
    final nav = navigator;
    if (c == null || nav == null) return;
    final stay = fractionVelocity.abs() >= 1.0
        ? fractionVelocity <= 0
        : c.value > 0.5;
    if (stay) {
      c.animateTo(
        1,
        duration: AppMotion.normal,
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    } else {
      nav.pop();
    }
    if (c.isAnimating) {
      late final AnimationStatusListener listener;
      listener = (status) {
        if (status.isAnimating) return;
        nav.didStopUserGesture();
        c.removeStatusListener(listener);
      };
      c.addStatusListener(listener);
    } else {
      nav.didStopUserGesture();
    }
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      linear: navigator?.userGestureInProgress ?? false,
      child: _EdgeSwipeBack(
        enabled: _canSwipeBack,
        onStart: _onSwipeStart,
        onUpdate: _onSwipeUpdate,
        onEnd: _onSwipeEnd,
        child: child,
      ),
    );
  }
}

/// go_router page using [AppPageRoute]. For detail screens:
///
/// ```dart
/// GoRoute(
///   path: 'package/:id',
///   pageBuilder: (context, state) =>
///       AppPage(key: state.pageKey, child: PackageScreen(id: ...)),
/// )
/// ```
class AppPage<T> extends Page<T> {
  const AppPage({
    required this.child,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) => AppPageRoute<T>(
    settings: this,
    fullscreenDialog: fullscreenDialog,
    builder: (_) => child,
  );
}

class _EdgeSwipeBack extends StatelessWidget {
  const _EdgeSwipeBack({
    required this.enabled,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onStart;

  /// Fraction of the width moved toward dismissal (positive = dismissing).
  final ValueChanged<double> onUpdate;

  /// Velocity in widths/second toward dismissal.
  final ValueChanged<double> onEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final sign = rtl ? -1.0 : 1.0;
    final width = MediaQuery.sizeOf(context).width;
    final padding = MediaQuery.paddingOf(context);
    final edge = AppPageRoute.edgeWidth + (rtl ? padding.right : padding.left);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: edge,
          child: RawGestureDetector(
            behavior: HitTestBehavior.translucent,
            gestures: {
              HorizontalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    HorizontalDragGestureRecognizer
                  >(() => HorizontalDragGestureRecognizer(debugOwner: this), (
                    r,
                  ) {
                    r
                      ..onStart = (_) {
                        onStart();
                      }
                      ..onUpdate = (d) {
                        onUpdate(sign * d.delta.dx / width);
                      }
                      ..onEnd = (d) {
                        onEnd(sign * d.velocity.pixelsPerSecond.dx / width);
                      }
                      ..onCancel = () {
                        onEnd(0);
                      };
                  }),
            },
          ),
        ),
      ],
    );
  }
}
