import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Motion tokens, modelled on iOS: everything moves on springs.
///
/// * [smooth]: no bounce (iOS `.smooth`), the default for movement.
/// * [snappy]: a hint of overshoot (iOS `.snappy`), for selection.
/// * [bouncy]: a visible but short bounce (iOS `.bouncy`), for popups,
///   badges and icons.
///
/// Durations are the time a spring takes to settle. Nothing loops. With
/// "remove animations" everything collapses to a short fade.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration emphasized = Duration(milliseconds: 420);
  static const Duration max = Duration(milliseconds: 480);

  /// A full spring settle: popups, the nav icon, copied ticks.
  static const Duration spring = Duration(milliseconds: 560);

  /// iOS push / pop.
  static const Duration page = Duration(milliseconds: 500);

  /// One row of a list rising into place.
  static const Duration entrance = Duration(milliseconds: 520);

  /// Gap between two rows of the same list.
  static const Duration stagger = Duration(milliseconds: 30);

  /// Snackbar confirmation for copy.
  static const Duration copyConfirmation = Duration(milliseconds: 1500);

  /// iOS `.smooth`: critically damped.
  static const Curve smooth = SpringCurve(dampingFraction: 1);

  /// iOS `.snappy`: settles fast with a hint of overshoot.
  static const Curve snappy = SpringCurve(dampingFraction: 0.82);

  /// iOS `.bouncy`.
  static const Curve bouncy = SpringCurve(dampingFraction: 0.68);

  /// Default curve for anything entering or moving.
  static const Curve enter = smooth;

  /// Leaving: starts briskly, ends softly.
  static const Curve exit = Curves.easeInOutCubic;

  /// Popups, badges, selected icons.
  static const Curve springy = bouncy;

  /// Large surfaces (sheets, panels, thumbs).
  static const Curve springSoft = snappy;

  /// Physical springs for gesture-driven or retargeted motion (the nav and
  /// capsule indicators). `response` and `dampingFraction` as in SwiftUI.
  static SpringDescription springOf({
    double response = 0.42,
    double dampingFraction = 0.82,
  }) {
    final stiffness = math.pow(2 * math.pi / response, 2).toDouble();
    final damping = 4 * math.pi * dampingFraction / response;
    return SpringDescription(mass: 1, stiffness: stiffness, damping: damping);
  }

  /// Respects the OS "remove animations" setting: everything collapses to a
  /// short fade-equivalent duration.
  static Duration resolve(BuildContext context, Duration duration) {
    final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return disable ? fast : duration;
  }

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// A spring from 0 to 1 as a [Curve] (for implicit animations), with
/// SwiftUI's damping fraction: 1 = no bounce, lower = more bounce.
/// It always ends exactly at 1.
class SpringCurve extends Curve {
  const SpringCurve({required this.dampingFraction});

  final double dampingFraction;

  /// Natural frequency in "curve time": the spring is at rest by ~t = 0.85.
  static const double _omega = 8.5;

  @override
  double transformInternal(double t) {
    if (t >= 1) return 1;
    final z = dampingFraction;
    final wt = _omega * t;
    double v;
    if (z >= 1) {
      v = 1 - (1 + wt) * math.exp(-wt);
    } else {
      final wd = _omega * math.sqrt(1 - z * z);
      v =
          1 -
          math.exp(-z * wt) *
              (math.cos(wd * t) + (z * _omega / wd) * math.sin(wd * t));
    }
    // Blend into 1 over the last 15% so the end is seamless.
    if (t > 0.85) {
      final k = (t - 0.85) / 0.15;
      return v + (1 - v) * k * k;
    }
    return v;
  }
}
