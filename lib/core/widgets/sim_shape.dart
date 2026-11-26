import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded rectangle with one cut corner (top end), the silhouette of a SIM
/// card. Used for the family tile of a package and the price panel only.
class SimShape extends OutlinedBorder {
  const SimShape({super.side, this.radius = 8, this.cut = 10});

  final double radius;

  /// Length of the cut along each edge.
  final double cut;

  Path _path(Rect outer, TextDirection? direction, [double inset = 0]) {
    final r = outer.deflate(inset);
    final radius = Radius.circular(this.radius.clamp(0, r.shortestSide / 2));
    final x = cut.clamp(0.0, r.shortestSide / 2);
    final base = Path()..addRRect(RRect.fromRectAndRadius(r, radius));
    final left = direction == TextDirection.rtl;
    final edge = left ? r.left : r.right;
    final corner = Path()
      ..moveTo(edge, r.top)
      ..lineTo(left ? edge + x : edge - x, r.top)
      ..lineTo(edge, r.top + x)
      ..close();
    return Path.combine(PathOperation.difference, base, corner);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, textDirection);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, textDirection, side.width);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(_path(rect, textDirection, side.width / 2), side.toPaint());
  }

  @override
  SimShape scale(double t) =>
      SimShape(side: side.scale(t), radius: radius * t, cut: cut * t);

  @override
  SimShape copyWith({BorderSide? side}) =>
      SimShape(side: side ?? this.side, radius: radius, cut: cut);
}

/// The SIM panel as deep navy glass: lit from the top-start corner, a thin
/// bright rim and a soft navy glow under it.
ShapeDecoration simGlassDecoration(AppColors c, {double cut = 34}) =>
    ShapeDecoration(
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          Color.alphaBlend(Colors.white.withValues(alpha: 0.12), c.masthead),
          c.masthead,
          Color.alphaBlend(c.aurora1.withValues(alpha: 0.18), c.masthead),
        ],
        stops: const [0, 0.55, 1],
      ),
      shape: SimShape(
        radius: 20,
        cut: cut,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
      shadows: [
        BoxShadow(
          color: c.masthead.withValues(alpha: c.isDark ? 0.6 : 0.35),
          blurRadius: 28,
          offset: const Offset(0, 12),
          spreadRadius: -10,
        ),
      ],
    );
