import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'liquid_glass.dart';

/// One row of a [showGlassMenu].
@immutable
class GlassMenuItem<T> {
  const GlassMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.leading,
    this.count,
    this.hue,
    this.key,
  }) : assert(icon != null || leading != null);

  final T value;
  final String label;

  /// Shown in a lit disc of [hue]; or pass [leading] instead.
  final IconData? icon;
  final Widget? leading;

  /// How many items this choice holds.
  final int? count;

  /// Colour of the icon disc; navy when `null`.
  final Color? hue;
  final Key? key;
}

/// A small menu of clear liquid glass that springs out of [anchor] (the
/// button that opened it). The list underneath stays visible, bent by the
/// glass. Returns the value tapped, or `null` when dismissed.
Future<T?> showGlassMenu<T>(
  BuildContext anchor, {
  required List<GlassMenuItem<T>> items,
  required T? selected,
}) {
  final box = anchor.findRenderObject()! as RenderBox;
  final rect = box.localToGlobal(Offset.zero) & box.size;
  final reduce = AppMotion.reduced(anchor);
  return showGeneralDialog<T>(
    context: anchor,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(anchor).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: reduce ? AppMotion.fast : AppMotion.spring,
    pageBuilder: (context, _, _) =>
        _GlassMenu<T>(anchor: rect, items: items, selected: selected),
    transitionBuilder: (context, animation, _, child) {
      final fade = CurvedAnimation(parent: animation, curve: AppMotion.enter);
      if (reduce) return FadeTransition(opacity: fade, child: child);
      final pop = CurvedAnimation(
        parent: animation,
        curve: AppMotion.springy,
        reverseCurve: AppMotion.exit,
      );
      return FadeTransition(
        opacity: fade,
        child: AnimatedBuilder(
          animation: pop,
          builder: (context, child) {
            final size = MediaQuery.sizeOf(context);
            // Grows out of the button that opened it.
            final origin = Alignment(
              (rect.center.dx / size.width) * 2 - 1,
              (rect.bottom / size.height) * 2 - 1,
            );
            final t = pop.value;
            return Transform(
              alignment: origin,
              transform: Matrix4.diagonal3Values(
                0.7 + 0.3 * t,
                0.4 + 0.6 * t,
                1,
              ),
              child: child,
            );
          },
          child: child,
        ),
      );
    },
  );
}

class _GlassMenu<T> extends StatelessWidget {
  const _GlassMenu({
    required this.anchor,
    required this.items,
    required this.selected,
  });

  final Rect anchor;
  final List<GlassMenuItem<T>> items;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = MediaQuery.sizeOf(context);
    final width = anchor.width.clamp(220.0, 300.0);
    // Under the button, aligned to its start edge, kept on screen.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final left = (rtl ? anchor.right - width : anchor.left).clamp(
      AppSpacing.sm,
      size.width - width - AppSpacing.sm,
    );
    return Stack(
      children: [
        Positioned(
          left: left,
          top: anchor.bottom + AppSpacing.xs,
          width: width,
          child: Material(
            type: MaterialType.transparency,
            child: LiquidGlass(
              key: const ValueKey('glass-menu'),
              tone: GlassTone.chrome,
              blur: true,
              borderRadius: AppRadius.lgAll,
              shadows: AppShadows.raised(c),
              child: ConstrainedBox(
                // Long lists scroll inside the glass, above the dock.
                constraints: BoxConstraints(
                  maxHeight: (size.height - anchor.bottom - 120).clamp(
                    160.0,
                    520.0,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxs + 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final item in items)
                        _GlassMenuRow<T>(
                          item: item,
                          selected: item.value == selected,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassMenuRow<T> extends StatelessWidget {
  const _GlassMenuRow({required this.item, required this.selected});

  final GlassMenuItem<T> item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hue = item.hue ?? c.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          color: selected
              ? hue.withValues(alpha: c.isDark ? 0.24 : 0.14)
              : Colors.transparent,
          borderRadius: AppRadius.mdAll,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: AppRadius.mdAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: item.key,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop(item.value);
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Row(
                children: [
                  item.leading ??
                      GlyphBadge(icon: item.icon!, hue: hue, size: 32),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTypography.labelL.copyWith(
                        color: c.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (item.count != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.xxs,
                      ),
                      child: Text(
                        '${item.count}',
                        style: AppTypography.labelL.copyWith(
                          color: c.textTertiary,
                          fontFeatures: AppTypography.tabular,
                        ),
                      ),
                    ),
                  AnimatedScale(
                    scale: selected ? 1 : 0,
                    duration: AppMotion.normal,
                    curve: AppMotion.springy,
                    child: Icon(
                      AppIcons.selected,
                      size: AppIconSize.action,
                      color: c.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A round, lit disc of colour holding a white glyph: the app's colourful
/// icon look (menus, quick actions).
class GlyphBadge extends StatelessWidget {
  const GlyphBadge({
    super.key,
    required this.icon,
    required this.hue,
    this.size = 36,
  });

  final IconData icon;
  final Color hue;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(Colors.white.withValues(alpha: 0.28), hue),
          hue,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.12), hue),
        ],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      boxShadow: [
        BoxShadow(
          color: hue.withValues(alpha: 0.35),
          blurRadius: size * 0.25,
          offset: Offset(0, size * 0.08),
        ),
      ],
    ),
    child: Icon(icon, size: size * 0.5, color: Colors.white),
  );
}
