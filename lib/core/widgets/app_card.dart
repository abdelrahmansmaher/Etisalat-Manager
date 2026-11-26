import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/icon_hues.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'liquid_glass.dart';

/// iOS press feedback: the child dips to [pressedScale] at once while a
/// finger is down, and springs back when it lifts. Cheap: a transform.
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
        duration: AppMotion.resolve(
          context,
          _pressed ? const Duration(milliseconds: 110) : AppMotion.spring,
        ),
        curve: _pressed ? Curves.easeOut : AppMotion.bouncy,
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

/// Liquid-glass content card: the ambient light shows through, a bright rim
/// catches it, and a tappable card dips slightly under the finger.
/// A card given an explicit [color] (warnings, banners) stays solid.
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
    final content = Padding(padding: padding, child: child);
    final shadow = switch (role) {
      CardRole.hero => AppShadows.raised(c),
      CardRole.raised => AppShadows.card(c),
      _ => null,
    };
    final inner = onTap == null
        ? content
        : InkWell(onTap: onTap, child: content);
    Widget card;
    if (color == null && role != CardRole.sunken) {
      card = DecoratedBox(
        decoration: GlassDecoration(
          colors: c,
          borderRadius: radius,
          shadows: shadow,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(type: MaterialType.transparency, child: inner),
        ),
      );
    } else {
      card = DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: shadow),
        child: Material(
          color: color ?? c.glassTint,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: role == CardRole.sunken && borderColor == null
                ? BorderSide.none
                : BorderSide(color: borderColor ?? c.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: inner,
        ),
      );
    }
    if (onTap != null) card = PressableScale(pressedScale: 0.985, child: card);
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

/// Rounded-square icon tile: a lit, glossy tile in the icon's own hue
/// ([IconHues]) with a white glyph, like a home-screen app icon. Size,
/// glyph size and radius come from [IconTile].
///
/// Pass [hue] to choose the colour, or [background]/[color] for a quiet
/// tinted tile instead (status rows, neutral info).
class TintedIcon extends StatelessWidget {
  const TintedIcon(
    this.icon, {
    super.key,
    this.tile = IconTile.md,
    this.color,
    this.background,
    this.hue,
  });

  final IconData icon;
  final IconTile tile;
  final Color? color;
  final Color? background;
  final Hue? hue;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(tile.radius);
    if (background != null || color != null) {
      final base = background ?? c.primaryContainer;
      return Container(
        width: tile.box,
        height: tile.box,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              Color.alphaBlend(
                Colors.white.withValues(alpha: c.isDark ? 0.10 : 0.55),
                base,
              ),
              base,
            ],
          ),
          borderRadius: radius,
          border: Border.all(
            color: Colors.white.withValues(alpha: c.isDark ? 0.10 : 0.70),
          ),
        ),
        child: Icon(
          icon,
          size: tile.glyph,
          color: color ?? c.onPrimaryContainer,
        ),
      );
    }
    final h = (hue ?? IconHues.of(icon)).of(c);
    final small = tile.box <= IconTile.xs.box;
    return Container(
      width: tile.box,
      height: tile.box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(Colors.white.withValues(alpha: 0.22), h),
            h,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.10), h),
          ],
          stops: const [0, 0.55, 1],
        ),
        boxShadow: small
            ? null
            : [
                BoxShadow(
                  color: h.withValues(alpha: c.isDark ? 0.45 : 0.32),
                  blurRadius: tile.box * 0.28,
                  offset: Offset(0, tile.box * 0.08),
                  spreadRadius: -tile.box * 0.06,
                ),
              ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
      child: Icon(
        icon,
        size: tile.glyph,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
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
                    color: c.textSecondary,
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
