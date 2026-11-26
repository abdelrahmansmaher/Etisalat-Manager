import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'liquid_glass.dart';

Decoration _decoration(AppColors c) => GlassDecoration(
  colors: c,
  borderRadius: AppRadius.rowAll,
  shadows: AppShadows.card(c),
);

/// Hairline between two rows of a surface.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    indent: AppSpacing.sm,
    endIndent: AppSpacing.sm,
    color: context.colors.hairline,
  );
}

/// Dense rows grouped in one surface with dividers (never one card per row).
class ListSurface extends StatelessWidget {
  const ListSurface({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration(context.colors),
      child: ClipRRect(
        borderRadius: AppRadius.rowAll,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const RowDivider(),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// [ListSurface] built lazily inside a scroll view.
class SliverListSurface extends StatelessWidget {
  const SliverListSurface({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: _decoration(context.colors),
      sliver: SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, _) => const RowDivider(),
        itemBuilder: (context, i) => ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(i == 0 ? AppRadius.row : 0),
            bottom: Radius.circular(i == itemCount - 1 ? AppRadius.row : 0),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: itemBuilder(context, i),
          ),
        ),
      ),
    );
  }
}
