import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Restricted glassmorphism (doc 04 §2.6).
///
/// Default = **faux glass, no blur**: a solid surface at 88–92 % opacity with a
/// faint primary tint and a 1dp top highlight. Real [BackdropFilter] blur is
/// strictly opt-in via [enableBlur] (one surface per screen, strong devices
/// only, sigma ≤ 8) and is skipped automatically when the OS asks to reduce
/// animations/effects.
///
/// Allowed only on navigation chrome (bottom nav, scrolled app bar, home
/// hero, filter-sheet header). NEVER on surfaces showing prices, codes,
/// numbers, warnings, conflict/expiry banners or decision dialogs.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.opacity = 0.9,
    this.enableBlur = false,
    this.blurSigma = 8,
    this.borderRadius = BorderRadius.zero,
    this.showTopHighlight = true,
    this.borderColor,
  }) : assert(
         opacity >= 0.88 && opacity <= 1.0,
         'Glass opacity must stay ≥ 0.88 so text contrast holds over any '
         'background (doc 04 §2.1).',
       ),
       assert(blurSigma > 0 && blurSigma <= 8, 'Blur sigma must be in (0, 8].');

  final Widget child;
  final double opacity;

  /// Opt-in real blur. Keep false for anything above a scrolling list on
  /// mid-range devices (the costliest paint case in Flutter).
  final bool enableBlur;
  final double blurSigma;
  final BorderRadius borderRadius;
  final bool showTopHighlight;

  /// Full hairline border (floating surfaces); overrides the top highlight.
  final Color? borderColor;

  /// The colour actually painted (exposed for contrast tests).
  static Color surfaceColor(AppColors c, {double opacity = 0.9}) =>
      Color.alphaBlend(
        c.primary.withValues(alpha: 0.03),
        c.surface,
      ).withValues(alpha: opacity);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduceEffects = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final useBlur = enableBlur && !reduceEffects;

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor(c, opacity: opacity),
        borderRadius: borderRadius,
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : showTopHighlight
            ? Border(top: BorderSide(color: c.glassHighlight))
            : null,
      ),
      child: child,
    );

    if (useBlur) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: surface,
      );
    }

    if (useBlur || borderRadius != BorderRadius.zero) {
      surface = ClipRRect(borderRadius: borderRadius, child: surface);
    }
    return surface;
  }
}
