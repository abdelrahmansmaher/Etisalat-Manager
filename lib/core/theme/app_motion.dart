import 'package:flutter/widgets.dart';

/// Motion tokens (doc 04 §2.8). Nothing exceeds [max] except real progress.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration emphasized = Duration(milliseconds: 250);
  static const Duration max = Duration(milliseconds: 300);

  /// Snackbar confirmation for copy (≤ 1.5 s, doc 04 P6).
  static const Duration copyConfirmation = Duration(milliseconds: 1500);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// Respects the OS "remove animations" setting: everything collapses to a
  /// ≤ 100ms fade-equivalent duration.
  static Duration resolve(BuildContext context, Duration duration) {
    final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return disable ? fast : duration;
  }
}
