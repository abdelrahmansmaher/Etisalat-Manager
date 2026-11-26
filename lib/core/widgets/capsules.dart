import 'package:flutter/material.dart';

import '../router/tab_pager.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'liquid_glass.dart';
import '../theme/app_icons.dart';
import '../theme/icon_hues.dart';

/// Capsule (pill) chip — the one navigation/filter shape used everywhere.
///
/// * selected: filled navy ([AppColors.capsuleSelected]) + white label.
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

  static const Duration duration = AppMotion.normal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sliding = _SlidingScope.of(context);
    final fg = selected ? c.onCapsuleSelected : c.textPrimary;
    // An unselected capsule shows its icon in the icon's own hue.
    final hue = icon == null ? null : IconHues.of(icon!);
    final iconColor = selected
        ? c.onCapsuleSelected
        : (hue == null || hue == Hue.navy ? c.primary : hue.of(c));
    final d = AppMotion.resolve(context, duration);

    Widget text = AnimatedDefaultTextStyle(
      duration: d,
      curve: AppMotion.enter,
      style: (ltrLabel ? AppTypography.code : AppTypography.labelL).copyWith(
        color: fg,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textDirection: ltrLabel ? TextDirection.ltr : null,
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
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: dense ? 36 : 44),
          child: DecoratedBox(
            decoration: sliding
                ? const BoxDecoration()
                : GlassDecoration(
                    colors: c,
                    stadium: true,
                    fill: c.headerField,
                  ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: selected && !sliding ? 1 : 0,
                    duration: d,
                    curve: AppMotion.enter,
                    child: DecoratedBox(decoration: selectedDecoration(c)),
                  ),
                ),
                Material(
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
                            Icon(
                              icon,
                              size: AppIconSize.chip,
                              color: iconColor,
                            ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Selected fill: navy with a soft top light and a glow under it.
  static BoxDecoration selectedDecoration(AppColors c) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.alphaBlend(
          Colors.white.withValues(alpha: 0.16),
          c.capsuleSelected,
        ),
        c.capsuleSelected,
      ],
    ),
    borderRadius: AppRadius.fullAll,
    border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
    boxShadow: [
      BoxShadow(
        color: c.capsuleSelected.withValues(alpha: 0.35),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: -4,
      ),
    ],
  );
}

/// Tells capsules that their row paints the pills and a sliding indicator.
class _SlidingScope extends InheritedWidget {
  const _SlidingScope({required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SlidingScope>() != null;

  @override
  bool updateShouldNotify(_SlidingScope old) => false;
}

/// Horizontally scrollable row of capsules. Claims horizontal drags, so it
/// never switches tabs when it sits inside the swipeable tab pager.
///
/// With [selected] (the index of the chosen child), one navy indicator
/// glides from the old choice to the new one on a spring, the way iOS
/// moves a selection, and the chosen capsule scrolls into view.
class CapsuleRow extends StatefulWidget {
  const CapsuleRow({
    super.key,
    required this.children,
    this.padding = EdgeInsetsDirectional.zero,
    this.spacing = AppSpacing.xs,
    this.controller,
    this.selected,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollController? controller;

  /// Index in [children] of the selected one (-1: none yet); `null` = a
  /// plain row without a sliding indicator.
  final int? selected;

  @override
  State<CapsuleRow> createState() => _CapsuleRowState();
}

class _CapsuleRowState extends State<CapsuleRow> {
  final GlobalKey _stack = GlobalKey();
  List<GlobalKey> _keys = const [];
  List<Rect> _rects = const [];

  void _syncKeys() {
    if (_keys.length != widget.children.length) {
      _keys = [for (final _ in widget.children) GlobalKey()];
    }
  }

  @override
  void didUpdateWidget(CapsuleRow old) {
    super.didUpdateWidget(old);
    final i = widget.selected;
    if (i != null && i != old.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final ctx = i < _keys.length ? _keys[i].currentContext : null;
        if (ctx == null || !ctx.mounted) return;
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: AppMotion.resolve(context, AppMotion.max),
          curve: AppMotion.enter,
        );
      });
    }
  }

  void _measure(Duration _) {
    if (!mounted) return;
    final stack = _stack.currentContext?.findRenderObject();
    if (stack is! RenderBox || !stack.hasSize) return;
    final rects = <Rect>[];
    for (final k in _keys) {
      final box = k.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      final o = box.localToGlobal(Offset.zero, ancestor: stack);
      rects.add(o & box.size);
    }
    var same = rects.length == _rects.length;
    for (var i = 0; same && i < rects.length; i++) {
      final a = rects[i], b = _rects[i];
      same =
          (a.left - b.left).abs() < 0.5 &&
          (a.top - b.top).abs() < 0.5 &&
          (a.width - b.width).abs() < 0.5 &&
          (a.height - b.height).abs() < 0.5;
    }
    if (!same) setState(() => _rects = rects);
  }

  @override
  Widget build(BuildContext context) {
    final sliding = widget.selected != null;
    Widget row;
    if (!sliding) {
      row = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < widget.children.length; i++) ...[
            if (i > 0) SizedBox(width: widget.spacing),
            widget.children[i],
          ],
        ],
      );
    } else {
      _syncKeys();
      WidgetsBinding.instance.addPostFrameCallback(_measure);
      final c = context.colors;
      final sel = widget.selected!;
      final selRect = sel >= 0 && sel < _rects.length ? _rects[sel] : null;
      row = Stack(
        key: _stack,
        children: [
          for (final r in _rects)
            Positioned.fromRect(
              rect: r,
              child: DecoratedBox(
                decoration: GlassDecoration(
                  colors: c,
                  stadium: true,
                  fill: c.headerField,
                ),
              ),
            ),
          if (selRect != null)
            AnimatedPositioned.fromRect(
              key: const ValueKey('capsule-indicator'),
              rect: selRect,
              duration: AppMotion.resolve(context, AppMotion.spring),
              curve: AppMotion.snappy,
              child: DecoratedBox(decoration: Capsule.selectedDecoration(c)),
            ),
          _SlidingScope(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.children.length; i++) ...[
                  if (i > 0) SizedBox(width: widget.spacing),
                  KeyedSubtree(key: _keys[i], child: widget.children[i]),
                ],
              ],
            ),
          ),
        ],
      );
    }
    return TabSwipeOptOut(
      child: SingleChildScrollView(
        controller: widget.controller,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: widget.padding,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: row,
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
/// with a filled navy thumb that slides (220ms) to the selected segment.
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
          color: c.glassTint,
          borderRadius: AppRadius.fullAll,
          border: Border.all(color: c.glassEdge),
        ),
        child: Stack(
          children: [
            if (index >= 0)
              Positioned.fill(
                child: AnimatedAlign(
                  duration: AppMotion.resolve(context, AppMotion.spring),
                  curve: AppMotion.snappy,
                  alignment: AlignmentDirectional(x, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / n,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: Capsule.selectedDecoration(c),
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
                  Icon(segment.icon, size: AppIconSize.chip, color: fg),
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
