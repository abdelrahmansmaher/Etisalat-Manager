import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/capsules.dart';
import '../../l10n/app_localizations.dart';
import '../content/package_facts.dart';
import 'dial.dart';
import 'dial_template.dart';
import 'tool_routes.dart';

/// Heart toggle for one item.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton(this.itemId, {super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final on = ref.watch(favoritesProvider.select((s) => s.contains(itemId)));
    return IconButton(
      key: ValueKey('favorite-$itemId'),
      isSelected: on,
      icon: Icon(on ? AppIcons.toolFavorite : AppIcons.toolFavoriteOff),
      color: context.colors.primary,
      tooltip: on ? l10n.toolsFavoriteRemove : l10n.toolsFavoriteAdd,
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(itemId),
    );
  }
}

/// Favorite, dial (when the item has a code or number), compare (packages),
/// note and edit. Wraps on narrow screens and large text.
class ItemActions extends ConsumerWidget {
  const ItemActions(this.item, {super.key});

  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favorite = ref.watch(
      favoritesProvider.select((s) => s.contains(item.id)),
    );
    final notes = ref.watch(itemNotesProvider(item.id)).length;
    final dial = dialValuesOf(item);
    return Wrap(
      key: const ValueKey('item-actions'),
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        if (dial.isNotEmpty)
          Capsule(
            key: const ValueKey('action-dial'),
            icon: AppIcons.call,
            label: l10n.toolsDial,
            onTap: () => launchDialAny(context, dial),
          ),
        Capsule(
          key: const ValueKey('action-favorite'),
          icon: favorite ? AppIcons.toolFavorite : AppIcons.toolFavoriteOff,
          label: l10n.toolsFavorite,
          semanticsLabel: favorite
              ? l10n.toolsFavoriteRemove
              : l10n.toolsFavoriteAdd,
          onTap: () => ref.read(favoritesProvider.notifier).toggle(item.id),
        ),
        if (item.type == ItemType.package)
          Capsule(
            key: const ValueKey('action-compare'),
            icon: AppIcons.toolCompare,
            label: l10n.toolsCompareAction,
            onTap: () => context.push(ToolRoutes.compareWith(item.id)),
          ),
        Capsule(
          key: const ValueKey('action-note'),
          icon: AppIcons.toolNotes,
          label: notes == 0
              ? l10n.toolsNoteAction
              : l10n.toolsNoteCount(notes),
          onTap: () => context.push(ToolRoutes.notesFor(item.id)),
        ),
        Capsule(
          key: const ValueKey('action-edit'),
          icon: AppIcons.toolEdits,
          label: l10n.toolsEditAction,
          onTap: () => context.push(ToolRoutes.editItem(item.id)),
        ),
      ],
    );
  }
}

/// What the dial action offers: the subscription code of a package, else
/// every code, else every phone number of the item.
List<String> dialValuesOf(ContentItem item) {
  final main = item.type == ItemType.package
      ? PackageFacts.of(item).code?.value
      : null;
  for (final list in [
    [?main],
    item.codes,
    item.phones,
  ]) {
    final ok = [
      for (final v in list)
        if (DialTemplate.parseAll(v).isNotEmpty) v,
    ];
    if (ok.isNotEmpty) return ok;
  }
  return const [];
}
