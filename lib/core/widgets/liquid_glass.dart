import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Ambient light behind every screen: a calm base lit by three soft lights.
///
/// Painted once and cached (it never animates), so the glass above it has
/// colour to refract without costing a frame.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final backdrop = RepaintBoundary(
      child: CustomPaint(
        key: const ValueKey('app-backdrop'),
        painter: _BackdropPainter(c),
        child: const SizedBox.expand(),
      ),
    );
    if (child == null) return backdrop;
    return Stack(fit: StackFit.expand, children: [backdrop, child!]);
  }

  /// Where the lights sit (fractions of the screen) and how strong they are.
  static const lights = <(Alignment, double, double, double)>[
    // alignment, radius (x shortest side), light alpha, dark alpha
    (Alignment(-1.1, -1.05), 1.15, 0.60, 0.60),
    (Alignment(1.15, -0.15), 1.0, 0.55, 0.34),
    (Alignment(-0.6, 1.1), 1.1, 0.50, 0.45),
  ];

  /// The colours a surface can sit on, for contrast checks: the base and
  /// each light at full strength over it.
  static List<Color> samples(AppColors c) {
    final colors = [c.aurora1, c.aurora2, c.aurora3];
    return [
      c.background,
      for (var i = 0; i < lights.length; i++)
        Color.alphaBlend(
          colors[i].withValues(alpha: c.isDark ? lights[i].$4 : lights[i].$3),
          c.background,
        ),
    ];
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.c);

  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = c.background);
    final colors = [c.aurora1, c.aurora2, c.aurora3];
    final side = size.shortestSide;
    for (var i = 0; i < AppBackdrop.lights.length; i++) {
      final (align, r, la, da) = AppBackdrop.lights[i];
      final center = align.withinRect(rect);
      final radius = side * r;
      final color = colors[i].withValues(alpha: c.isDark ? da : la);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            radius,
            [
              color,
              color.withValues(alpha: color.a * 0.45),
              color.withValues(alpha: 0),
            ],
            const [0, 0.45, 1],
          ),
      );
    }
    // A soft wash from the top keeps headers luminous.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          [
            (c.isDark ? Colors.black : Colors.white).withValues(
              alpha: c.isDark ? 0.0 : 0.18,
            ),
            (c.isDark ? Colors.black : Colors.white).withValues(alpha: 0),
            (c.isDark ? Colors.black : Colors.white).withValues(
              alpha: c.isDark ? 0.22 : 0.10,
            ),
          ],
          const [0, 0.5, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.c != c;
}

/// How much a glass surface stands out.
enum GlassTone {
  /// Cards and rows resting on the backdrop.
  card,

  /// Chrome that blurs what scrolls under it (header, nav bar, sheets).
  chrome,

  /// Deep navy glass: the SIM panel holding the price.
  navy,
}

/// Paints liquid glass: translucent fill, a sheen across the top and a rim
/// that is bright where the light hits and faint on the far side.
class GlassDecoration extends Decoration {
  const GlassDecoration({
    required this.colors,
    this.tone = GlassTone.card,
    this.borderRadius = AppRadius.mdAll,
    this.shadows,
    this.fill,
    this.stadium = false,
  });

  final AppColors colors;
  final GlassTone tone;
  final BorderRadius borderRadius;
  final List<BoxShadow>? shadows;

  /// Overrides the tone's fill (still translucent glass).
  final Color? fill;

  /// Fully rounded ends, whatever the height.
  final bool stadium;

  /// The fill painted for [tone] (exposed for contrast tests).
  static Color fillOf(AppColors c, GlassTone tone) => switch (tone) {
    GlassTone.card => c.glassFill,
    GlassTone.chrome => c.glassChrome,
    GlassTone.navy => c.masthead.withValues(alpha: c.isDark ? 0.86 : 0.93),
  };

  @override
  bool get isComplex => true;

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) =>
      Path()..addRRect(_rrect(rect));

  RRect _rrect(Rect rect) => stadium
      ? RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide / 2))
      : borderRadius.toRRect(rect);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _GlassPainter(this);

  @override
  bool operator ==(Object other) =>
      other is GlassDecoration &&
      other.colors == colors &&
      other.tone == tone &&
      other.borderRadius == borderRadius &&
      other.fill == fill &&
      other.stadium == stadium &&
      identical(other.shadows, shadows);

  @override
  int get hashCode => Object.hash(colors, tone, borderRadius, fill, stadium);
}

class _GlassPainter extends BoxPainter {
  _GlassPainter(this.d);

  final GlassDecoration d;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null || size.isEmpty) return;
    final c = d.colors;
    final rect = offset & size;
    final rrect = d._rrect(rect);
    final navy = d.tone == GlassTone.navy;

    for (final s in d.shadows ?? const <BoxShadow>[]) {
      canvas.drawRRect(
        rrect.shift(s.offset).inflate(s.spreadRadius),
        s.toPaint(),
      );
    }

    final fill = d.fill ?? GlassDecoration.fillOf(c, d.tone);
    final top = Color.alphaBlend(
      Colors.white.withValues(alpha: navy ? 0.10 : (c.isDark ? 0.05 : 0.10)),
      fill,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          top,
          fill,
        ]),
    );

    // Sheen: light caught by the upper part of the glass.
    final sheen = navy ? Colors.white.withValues(alpha: 0.10) : c.glassSheen;
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.55),
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          Offset(rect.center.dx, rect.top + rect.height * 0.55),
          [sheen, sheen.withValues(alpha: 0)],
        ),
    );
    canvas.restore();

    // Rim: bright at the top-start, faint at the bottom-end.
    final hi = navy ? Colors.white.withValues(alpha: 0.30) : c.glassEdge;
    final lo = navy ? Colors.white.withValues(alpha: 0.06) : c.glassEdgeLow;
    canvas.drawRRect(
      rrect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [
            hi,
            hi.withValues(alpha: hi.a * 0.35),
            lo,
            hi.withValues(alpha: hi.a * 0.55),
          ],
          const [0, 0.38, 0.7, 1],
        ),
    );
  }
}

/// A liquid-glass surface. With [blur] it frosts and saturates whatever
/// scrolls beneath it (headers, the nav bar, sheets, popups); without it,
/// it lets the ambient backdrop show through (cards and rows).
///
/// Blur turns itself off when the system asks for reduced effects.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.tone = GlassTone.card,
    this.borderRadius = AppRadius.mdAll,
    this.blur = false,
    this.shadows,
    this.fill,
    this.stadium = false,
    this.padding,
  });

  final Widget child;
  final GlassTone tone;
  final BorderRadius borderRadius;
  final bool blur;
  final List<BoxShadow>? shadows;
  final Color? fill;
  final bool stadium;
  final EdgeInsetsGeometry? padding;

  /// Frost + saturation used by every blurred surface.
  static ui.ImageFilter filter({double sigma = 22}) => ui.ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate),
    inner: ui.ImageFilter.blur(
      sigmaX: sigma,
      sigmaY: sigma,
      tileMode: TileMode.mirror,
    ),
  );

  /// Saturation x1.6 (Rec. 709 weights).
  static const List<double> _saturate = [
    1.4724, -0.4291, -0.0433, 0, 0, //
    -0.1276, 1.1709, -0.0433, 0, 0, //
    -0.1276, -0.4291, 1.5567, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    Widget content = DecoratedBox(
      decoration: GlassDecoration(
        colors: c,
        tone: tone,
        borderRadius: borderRadius,
        fill: fill,
        stadium: stadium,
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    final clip = stadium
        ? ClipPath(
            clipper: const ShapeBorderClipper(shape: StadiumBorder()),
            child: content,
          )
        : ClipRRect(borderRadius: borderRadius, child: content);
    if (blur && !reduce) {
      content = stadium
          ? ClipPath(
              clipper: const ShapeBorderClipper(shape: StadiumBorder()),
              child: BackdropFilter(filter: filter(), child: content),
            )
          : ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(filter: filter(), child: content),
            );
    } else {
      content = clip;
    }
    if (shadows == null || shadows!.isEmpty) return content;
    return DecoratedBox(
      decoration: stadium
          ? ShapeDecoration(shape: const StadiumBorder(), shadows: shadows)
          : BoxDecoration(borderRadius: borderRadius, boxShadow: shadows),
      child: content,
    );
  }
}
