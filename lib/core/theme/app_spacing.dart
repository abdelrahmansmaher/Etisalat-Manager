import 'package:flutter/widgets.dart';

/// 4dp spacing scale (doc 04 §2.3).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;

  /// Gap between cards.
  static const double cardGap = sm;

  /// Padding inside a card.
  static const double cardPadding = md;

  /// Minimum touch target (Material) — doc 04 §6.1.
  static const double minTouchTarget = 48;

  /// Widest readable column; wider screens centre it.
  static const double maxContentWidth = 840;

  /// Horizontal screen padding by width class (mobile / tablet / web). On
  /// wide screens it grows so the content column never passes
  /// [maxContentWidth].
  static double screenPaddingFor(double width) {
    final base = width >= 600 ? xl : md;
    final side = (width - maxContentWidth) / 2;
    return side > base ? side : base;
  }

  static EdgeInsetsDirectional screenPadding(double width) =>
      EdgeInsetsDirectional.symmetric(horizontal: screenPaddingFor(width));
}
