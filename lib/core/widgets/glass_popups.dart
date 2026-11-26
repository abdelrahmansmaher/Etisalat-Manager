import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'liquid_glass.dart';

/// Opens a centred glass popup: the page behind blurs and dims, and the
/// popup springs up from slightly smaller. Tapping outside closes it.
Future<T?> showGlassPopup<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? barrierLabel,
  bool dismissible = true,
}) {
  final reduce = AppMotion.reduced(context);
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: dismissible,
    barrierLabel:
        barrierLabel ??
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: reduce ? AppMotion.fast : AppMotion.spring,
    pageBuilder: (context, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Material(
              type: MaterialType.transparency,
              child: builder(context),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) {
      final c = context.colors;
      final fade = CurvedAnimation(parent: animation, curve: AppMotion.enter);
      final pop = CurvedAnimation(
        parent: animation,
        curve: AppMotion.springy,
        reverseCurve: AppMotion.exit,
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          // Blurred, dimmed page behind; tapping it closes the popup.
          IgnorePointer(
            child: AnimatedBuilder(
              animation: fade,
              builder: (context, _) => reduce
                  ? ColoredBox(
                      color: c.shadow.withValues(alpha: 0.35 * fade.value),
                    )
                  : BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 10 * fade.value,
                        sigmaY: 10 * fade.value,
                      ),
                      child: ColoredBox(
                        color: c.shadow.withValues(
                          alpha: (c.isDark ? 0.45 : 0.22) * fade.value,
                        ),
                      ),
                    ),
            ),
          ),
          FadeTransition(
            opacity: fade,
            child: reduce
                ? child
                : ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1).animate(pop),
                    child: child,
                  ),
          ),
        ],
      );
    },
  );
}

/// The glass card of a popup, with a title row.
class GlassPopupCard extends StatelessWidget {
  const GlassPopupCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => LiquidGlass(
    tone: GlassTone.chrome,
    blur: true,
    borderRadius: AppRadius.lgAll,
    shadows: AppShadows.raised(context.colors),
    padding: padding,
    child: child,
  );
}

/// Short confirmation that floats above the nav bar: an icon in a small
/// disc and one line, on glass. It springs in and leaves by itself.
void showGlassToast(
  BuildContext context,
  String text, {
  IconData icon = AppIcons.toolMeets,
  Duration duration = const Duration(milliseconds: 2200),
  SnackBarAction? action,
}) {
  final c = context.colors;
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        content: _Toast(text: text, icon: icon, colors: c, action: action),
      ),
    );
}

class _Toast extends StatelessWidget {
  const _Toast({
    required this.text,
    required this.icon,
    required this.colors,
    this.action,
  });

  final String text;
  final IconData icon;
  final AppColors colors;
  final SnackBarAction? action;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final reduce = AppMotion.reduced(context);
    final body = Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              Colors.white.withValues(alpha: 0.10),
              c.masthead.withValues(alpha: 0.94),
            ),
            c.masthead.withValues(alpha: 0.94),
          ],
        ),
        shadows: AppShadows.raised(c),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppIconSize.chip, color: c.onMasthead),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyM.copyWith(
                color: c.onMasthead,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: () {
                action!.onPressed();
                ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
              },
              style: TextButton.styleFrom(foregroundColor: c.mastheadPrice),
              child: Text(action!.label),
            ),
        ],
      ),
    );
    if (reduce) return body;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: AppMotion.spring,
      curve: AppMotion.springy,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: body,
    );
  }
}

/// Opens a frosted glass bottom sheet with its own grab handle.
Future<T?> showGlassSheet<T>(BuildContext context, WidgetBuilder builder) {
  final c = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: c.shadow.withValues(alpha: c.isDark ? 0.5 : 0.28),
    // iOS sheet: rises on a smooth spring, leaves briskly.
    sheetAnimationStyle: AnimationStyle(
      duration: AppMotion.resolve(context, AppMotion.page),
      reverseDuration: AppMotion.resolve(context, AppMotion.normal),
      curve: AppMotion.snappy,
      reverseCurve: AppMotion.exit,
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: LiquidGlass(
        key: const ValueKey('glass-sheet'),
        tone: GlassTone.chrome,
        blur: true,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.l),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  bottom: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: c.textTertiary.withValues(alpha: 0.45),
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),
            Flexible(child: builder(context)),
          ],
        ),
      ),
    ),
  );
}
