import 'package:flutter/material.dart';

import '../router/tab_pager.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';

/// Capsule (pill) chip — the one navigation/filter shape used everywhere.
///
/// * selected: filled emerald ([AppColors.capsuleSelected]) + white label,
///   soft glow.
/// * unselected: soft surface ([AppColors.capsuleSurface]) + hairline border.
///
/// Colour changes animate in ~220ms; a press scales it to 0.96.
class Capsule extends StatelessWidget {
  const Capsule({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.trailing,
    this.dense = false,
    this.semanticsLabel,
    this.ltrLabel = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  /// Small widget after the label (e.g. a count).
  final Widget? trailing;

  /// 36dp tall instead of 44dp.
  final bool dense;
  final String? semanticsLabel;

  /// Lay the label out left-to-right (codes, phone numbers).
  final bool ltrLabel;

  static const Duration duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onCapsuleSelected : c.textPrimary;
    final iconColor = selected ? c.onCapsuleSelected : c.primary;
    final d = AppMotion.resolve(context, duration);

    Widget text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textDirection: ltrLabel ? TextDirection.ltr : null,
      style: (ltrLabel ? AppTypography.code : AppTypography.labelL).copyWith(
        color: fg,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: PressableScale(
        pressedScale: 0.96,
        enabled: onTap != null,
        child: AnimatedContainer(
          duration: d,
          curve: AppMotion.enter,
          constraints: BoxConstraints(minHeight: dense ? 36 : 44),
          decoration: BoxDecoration(
            color: selected ? c.capsuleSelected : c.capsuleSurface,
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: selected ? c.capsuleSelected : c.hairline,
            ),
            boxShadow: selected ? AppShadows.primaryGlow(c) : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  icon == null ? AppSpacing.md : AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: iconColor),
                      const SizedBox(width: AppSpacing.xs - 2),
                    ],
                    Flexible(child: text),
                    if (trailing != null) ...[
                      const SizedBox(width: AppSpacing.xs - 2),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable row of capsules. Claims horizontal drags, so it
/// never switches tabs when it sits inside the swipeable tab pager.
class CapsuleRow extends StatelessWidget {
  const CapsuleRow({
    super.key,
    required this.children,
    this.padding = EdgeInsetsDirectional.zero,
    this.spacing = AppSpacing.xs,
    this.controller,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return TabSwipeOptOut(
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: padding,
        child: Padding(
          // Room for the selected capsule's glow.
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One option of a [SegmentedCapsule].
@immutable
class CapsuleSegment<T> {
  const CapsuleSegment({
    required this.value,
    required this.label,
    this.icon,
    this.key,
  });

  final T value;
  final String label;
  final IconData? icon;

  /// Key put on the tappable segment (tests, analytics).
  final Key? key;
}

/// Segmented capsule control: equal-width segments inside a soft pill track,
/// with a filled emerald thumb that slides (220ms) to the selected segment.
/// Labels wrap instead of clipping at large text scales.
class SegmentedCapsule<T> extends StatelessWidget {
  const SegmentedCapsule({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<CapsuleSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final n = segments.length;
    final index = segments.indexWhere((s) => s.value == selected);
    final d = AppMotion.resolve(context, Capsule.duration);
    final x = n <= 1 || index < 0 ? -1.0 : -1 + 2 * index / (n - 1);

    return TabSwipeOptOut(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: c.surfaceVariant,
          borderRadius: AppRadius.fullAll,
          border: Border.all(color: c.hairline),
        ),
        child: Stack(
          children: [
            if (index >= 0)
              Positioned.fill(
                child: AnimatedAlign(
                  duration: d,
                  curve: AppMotion.enter,
                  alignment: AlignmentDirectional(x, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / n,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.capsuleSelected,
                        borderRadius: AppRadius.fullAll,
                        boxShadow: AppShadows.primaryGlow(c),
                      ),
                    ),
                  ),
                ),
              ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < n; i++)
                    Expanded(
                      child: _Segment(
                        key: segments[i].key,
                        segment: segments[i],
                        selected: i == index,
                        duration: d,
                        onTap: () => onChanged(segments[i].value),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    super.key,
    required this.segment,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final CapsuleSegment<T> segment;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onCapsuleSelected : c.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: segment.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs - 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (segment.icon != null) ...[
                  Icon(segment.icon, size: 18, color: fg),
                  const SizedBox(width: AppSpacing.xxs),
                ],
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: duration,
                    curve: AppMotion.enter,
                    style: AppTypography.labelL.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    child: Text(segment.label, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
