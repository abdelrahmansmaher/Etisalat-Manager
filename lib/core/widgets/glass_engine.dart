// ignore_for_file: prefer_initializing_formals
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The refraction engine behind every blurred liquid-glass surface.
///
/// A fragment shader (`shaders/liquid_glass.frag`) bends what lies under
/// the glass like a convex lens: a steep bezel at the rim that wraps the
/// picture around the edge, a flat, slightly magnifying middle, and a hint
/// of colour dispersion. Frost and saturation are composed on top.
///
/// It runs where the renderer can filter with a shader (Impeller, the
/// default on Android and iOS). Elsewhere (the web, widget tests) glass
/// falls back to frost and saturation only, with the same painted rim.
abstract final class GlassEngine {
  static ui.FragmentProgram? _program;

  /// Loads the shader once, at start-up. Never throws.
  static Future<void> warmUp() async {
    if (_program != null) return;
    if (!ui.ImageFilter.isShaderFilterSupported) {
      debugPrint('Liquid glass: no shader filters here, frost only');
      return;
    }
    try {
      _program = await ui.FragmentProgram.fromAsset(
        'shaders/liquid_glass.frag',
      );
    } catch (e) {
      debugPrint('Liquid glass: refraction unavailable ($e)');
    }
    debugPrint('Liquid glass: refraction ${refracts ? 'on' : 'off'}');
  }

  /// Whether glass refracts on this device.
  static bool get refracts => _program != null;
}

/// How strongly a surface bends light (logical px).
@immutable
class GlassOptics {
  const GlassOptics({
    required this.bezel,
    required this.bend,
    this.dispersion = 0.2,
    this.magnify = 0.0,
    this.frost = 8,
    this.saturation = const <double>[],
  });

  /// Width of the curved rim.
  final double bezel;

  /// How far the picture is pulled at the very edge.
  final double bend;

  /// Colour split at the rim (0 = none).
  final double dispersion;

  /// Magnification of the flat middle (0.03 = 3 %).
  final double magnify;

  /// Frosting blur sigma applied after refraction.
  final double frost;

  /// Colour matrix applied last (empty = none).
  final List<double> saturation;
}

/// Pushes a backdrop filter that refracts through the engine's shader.
/// Repaints itself while its route animates, so the lens follows the
/// shape through page transitions and sheets.
class RefractiveBackdrop extends SingleChildRenderObjectWidget {
  const RefractiveBackdrop({
    super.key,
    required this.optics,
    required this.radius,
    super.child,
  });

  final GlassOptics optics;

  /// Corner radius; `null` for a stadium.
  final double? radius;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderRefractive(
    optics: optics,
    radius: radius,
    dpr: MediaQuery.devicePixelRatioOf(context),
    motion: _motionOf(context),
  );

  @override
  void updateRenderObject(BuildContext context, RenderRefractive renderObject) {
    renderObject
      ..optics = optics
      ..radius = radius
      ..dpr = MediaQuery.devicePixelRatioOf(context)
      ..motion = _motionOf(context);
  }

  static Listenable? _motionOf(BuildContext context) {
    final route = ModalRoute.of(context);
    final a = route?.animation;
    final s = route?.secondaryAnimation;
    if (a == null && s == null) return null;
    return Listenable.merge([?a, ?s]);
  }
}

class RenderRefractive extends RenderProxyBox {
  RenderRefractive({
    required GlassOptics optics,
    required double? radius,
    required double dpr,
    required Listenable? motion,
  }) : _optics = optics,
       _radius = radius,
       _dpr = dpr,
       _motion = motion;

  GlassOptics _optics;
  set optics(GlassOptics v) {
    if (identical(v, _optics)) return;
    _optics = v;
    markNeedsPaint();
  }

  double? _radius;
  set radius(double? v) {
    if (v == _radius) return;
    _radius = v;
    markNeedsPaint();
  }

  double _dpr;
  set dpr(double v) {
    if (v == _dpr) return;
    _dpr = v;
    markNeedsPaint();
  }

  Listenable? _motion;
  set motion(Listenable? v) {
    if (v == _motion) return;
    if (attached) _motion?.removeListener(markNeedsPaint);
    _motion = v;
    if (attached) _motion?.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _motion?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _motion?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  BackdropFilterLayer? get layer => super.layer as BackdropFilterLayer?;

  @override
  void paint(PaintingContext context, Offset offset) {
    final program = GlassEngine._program;
    if (child == null || program == null || size.isEmpty) {
      layer = null;
      if (child != null) super.paint(context, offset);
      return;
    }
    final o = _optics;
    final d = _dpr;
    final origin = localToGlobal(Offset.zero) * d;
    final key = (
      origin.dx,
      origin.dy,
      size.width,
      size.height,
      _radius,
      d,
      identityHashCode(o),
    );
    // Same place, size and optics as last frame: keep the filter as it is
    // (no new shader, no new filter chain).
    if (key != _lastKey || _filter == null) {
      _lastKey = key;
      final r = (_radius ?? size.shortestSide / 2) * d;
      // A fresh shader per change: one the engine may still be drawing
      // with is never edited.
      final shader = program.fragmentShader()
        // 0-1: texture size, set by the engine.
        ..setFloat(2, origin.dx)
        ..setFloat(3, origin.dy)
        ..setFloat(4, size.width * d)
        ..setFloat(5, size.height * d)
        ..setFloat(6, r)
        ..setFloat(7, o.bezel * d)
        ..setFloat(8, o.bend * d)
        ..setFloat(9, o.dispersion)
        ..setFloat(10, o.magnify)
        ..setFloat(11, 0)
        ..setFloat(12, 0)
        ..setFloat(13, 0);
      ui.ImageFilter filter = ui.ImageFilter.shader(shader);
      if (o.frost > 0) {
        filter = ui.ImageFilter.compose(
          outer: ui.ImageFilter.blur(
            sigmaX: o.frost,
            sigmaY: o.frost,
            tileMode: TileMode.mirror,
          ),
          inner: filter,
        );
      }
      if (o.saturation.length == 20) {
        filter = ui.ImageFilter.compose(
          outer: ColorFilter.matrix(o.saturation),
          inner: filter,
        );
      }
      _filter = filter;
    }
    final l = layer ?? BackdropFilterLayer();
    if (!identical(l.filter, _filter)) l.filter = _filter;
    layer = l;
    context.pushLayer(l, super.paint, offset);
  }

  ui.ImageFilter? _filter;
  Object? _lastKey;
}
