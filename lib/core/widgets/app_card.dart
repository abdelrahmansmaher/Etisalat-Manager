import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
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

/// How a card sits in the hierarchy. Shadow, border, radius and fill encode
/// the role, so not every surface looks the same:
enum CardRole {
  /// The one key answer of a page: radius 20, lifted shadow.
  hero,

  /// Standalone entry: radius 20, soft shadow.
  raised,

  /// Repeating content (list rows, tables, settings, sources): radius 16,
  /// hairline only, no shadow — quiet and dense.
  flat,

  /// Data inside a card or a grid of numbers (metric tiles): radius 14,
  /// sunken fill, no border, no shadow.
  sunken,
}

/// Solid content card (never glass — doc 04 §2.6) with ink ripple when
/// tappable. No press-scale: cards stay calm; capsules/nav carry the
/// tactile motion.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.cardPadding),
    this.role = CardRole.raised,
    this.color,
    this.borderColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final CardRole role;
  final Color? color;

  final Color? borderColor;
  final String? semanticLabel;

  BorderRadius get radius => switch (role) {
    CardRole.hero => AppRadius.mdAll,
    CardRole.raised => AppRadius.mdAll,
    CardRole.flat => AppRadius.rowAll,
    CardRole.sunken => AppRadius.smAll,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fill =
        color ??
        (role == CardRole.sunken ? c.surfaceVariant : c.surfaceElevated);
    final content = Padding(padding: padding, child: child);
    final shadow = switch (role) {
      CardRole.hero => AppShadows.raised(c),
      CardRole.raised => AppShadows.card(c),
      _ => null,
    };
    Widget card = DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadow),
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: role == CardRole.sunken && borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor ?? c.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
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

/// Rounded-square icon tile. Size, glyph size and radius come from
/// [IconTile]; navy tint by default.
class TintedIcon extends StatelessWidget {
  const TintedIcon(
    this.icon, {
    super.key,
    this.tile = IconTile.md,
    this.color,
    this.background,
  });

  final IconData icon;
  final IconTile tile;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: tile.box,
      height: tile.box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? c.primaryContainer,
        borderRadius: BorderRadius.circular(tile.radius),
      ),
      child: Icon(
        icon,
        size: tile.glyph,
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
                  style: theme.textTheme.titleMedium?.copyWith(
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
