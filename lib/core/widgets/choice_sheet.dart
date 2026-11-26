import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'badges.dart';
import 'capsules.dart';
import 'glass_popups.dart';
import 'liquid_glass.dart';
import '../theme/app_shadows.dart';

/// One choice in a [ChoiceSheet].
@immutable
class Choice<T> {
  const Choice({
    required this.value,
    required this.label,
    this.count,
    this.leading,
    this.key,
  });

  final T value;
  final String label;
  final int? count;

  /// Icon tile, family SIM...
  final Widget? leading;

  /// Key put on the tappable tile (tests, analytics).
  final Key? key;
}

/// Compact filter button: what is chosen now, a count and a down chevron.
/// It replaces a long row of capsules; the choices open in a [ChoiceSheet].
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = AppIcons.filter,
    this.count,
    this.active = false,
    this.semanticsLabel,
    this.floating = false,
    this.expand = false,
  });

  /// Fills the width it is given, content centred.
  final bool expand;

  /// Sits over scrolling content: frosted glass behind it.
  final bool floating;

  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final int? count;

  /// Something other than "all" is chosen: the pill turns navy.
  final bool active;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = active ? c.onCapsuleSelected : c.textPrimary;
    Widget pill = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      constraints: const BoxConstraints(minHeight: 40),
      decoration: active
          ? Capsule.selectedDecoration(c)
          : BoxDecoration(
              color: c.headerField,
              borderRadius: AppRadius.fullAll,
              border: Border.all(color: c.glassEdge),
            ),
      child: Material(
        type: MaterialType.transparency,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: AppIconSize.chip,
                  color: active ? fg : c.primary,
                ),
                const SizedBox(width: AppSpacing.xs - 2),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelL.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: AppSpacing.xs - 2),
                  AppBadge(label: '$count'),
                ],
                const SizedBox(width: 2),
                Icon(AppIcons.dropdown, size: 16, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
    if (floating && !active) {
      pill = LiquidGlass(
        tone: GlassTone.chrome,
        blur: true,
        stadium: true,
        shadows: AppShadows.card(c),
        child: pill,
      );
    }
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: PressableScale(pressedScale: 0.96, child: pill),
    );
  }
}

/// Opens the choices as a grid of glass tiles in a sheet; returns the one
/// tapped (or `null` when dismissed).
Future<T?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<Choice<T>> choices,
  required T? selected,
}) => showGlassSheet<T>(
  context,
  (context) =>
      ChoiceSheet<T>(title: title, choices: choices, selected: selected),
);

class ChoiceSheet<T> extends StatelessWidget {
  const ChoiceSheet({
    super.key,
    required this.title,
    required this.choices,
    required this.selected,
  });

  final String title;
  final List<Choice<T>> choices;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTypography.titleL.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, box) {
              final columns = box.maxWidth >= 520 ? 3 : 2;
              const gap = AppSpacing.xs;
              final w = (box.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final ch in choices)
                    SizedBox(
                      width: w,
                      child: _ChoiceTile<T>(
                        choice: ch,
                        selected: ch.value == selected,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({required this.choice, required this.selected});

  final Choice<T> choice;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onCapsuleSelected : c.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      label: choice.label,
      excludeSemantics: true,
      child: PressableScale(
        child: DecoratedBox(
          decoration: selected
              ? Capsule.selectedDecoration(c)
                    .copyWith(borderRadius: AppRadius.mdAll)
              : BoxDecoration(
                  color: c.headerField,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: c.glassEdge),
                ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: AppRadius.mdAll,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: choice.key,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop(choice.value);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      if (choice.leading != null) ...[
                        choice.leading!,
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          choice.label,
                          style: AppTypography.labelL.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (choice.count != null)
                        Text(
                          '${choice.count}',
                          style: AppTypography.labelL.copyWith(
                            color: selected
                                ? c.onCapsuleSelected
                                : c.textTertiary,
                            fontFeatures: AppTypography.tabular,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
