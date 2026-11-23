import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Subtle press feedback: scales the child to [pressedScale] while a pointer
/// is down (100ms, easeOutCubic). Cheap — a transform, no opacity layer.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (!widget.enabled || _pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: AppMotion.resolve(context, AppMotion.fast),
        curve: AppMotion.enter,
        child: widget.child,
      ),
    );
  }
}

/// The standard content card: elevated tonal surface, 20 radius, hairline
/// border, soft shadow, ink ripple + press scale when tappable.
///
/// Content cards are always solid (never glass) — doc 04 §2.6.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.cardPadding),
    this.color,
    this.gradient,
    this.borderColor,
    this.semanticLabel,
    this.radius = AppRadius.mdAll,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  /// Optional soft gradient painted under the content (hero cards).
  final Gradient? gradient;
  final Color? borderColor;
  final String? semanticLabel;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget content = Padding(padding: padding, child: child);
    if (gradient != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: content,
      );
    }
    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.card(c),
      ),
      child: Material(
        color: color ?? c.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor ?? c.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
    if (onTap != null) {
      card = PressableScale(child: card);
    }
    if (semanticLabel != null) {
      card = Semantics(
        button: onTap != null,
        label: semanticLabel,
        excludeSemantics: true,
        child: card,
      );
    }
    return card;
  }
}

/// Tinted rounded-square icon container (soft emerald by default).
class TintedIcon extends StatelessWidget {
  const TintedIcon(
    this.icon, {
    super.key,
    this.size = 44,
    this.color,
    this.background,
    this.gradient,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final Color? background;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradient == null ? (background ?? c.primaryContainer) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        icon,
        size: size * 0.52,
        color: color ?? c.onPrimaryContainer,
      ),
    );
  }
}

/// Section header: title with clear hierarchy + optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: c.textTertiary,
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
