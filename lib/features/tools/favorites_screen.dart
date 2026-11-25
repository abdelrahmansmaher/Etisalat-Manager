import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../l10n/app_localizations.dart';
import '../content/section_ui.dart';

/// Ordered favorites list with drag-to-reorder.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final items = ref.watch(favoriteItemsProvider);

    return PageScaffold(
      title: l10n.toolsFavoritesTitle,
      subtitle: items.length > 1 ? l10n.toolsFavoritesHint : null,
      children: [
        if (items.isEmpty)
          PlaceholderPanel(
            icon: AppIcons.toolFavoriteOff,
            title: l10n.toolsFavoritesEmpty,
            body: l10n.toolsFavoritesEmptyBody,
          )
        else
          AppCard(
            role: CardRole.flat,
            padding: EdgeInsets.zero,
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: items.length,
              onReorderItem: (oldIndex, newIndex) {
                final ids = [for (final i in items) i.id];
                final moved = ids.removeAt(oldIndex);
                ids.insert(newIndex, moved);
                ref.read(favoritesProvider.notifier).reorder(ids);
              },
              itemBuilder: (context, i) {
                final item = items[i];
                return Column(
                  key: ValueKey('fav-${item.id}'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (i > 0) Divider(color: c.hairline, height: 1),
                    ListTile(
                      leading: ReorderableDragStartListener(
                        index: i,
                        child: Icon(
                          AppIcons.toolDrag,
                          color: c.textTertiary,
                          semanticLabel: l10n.toolsReorder(item.title),
                        ),
                      ),
                      title: ProseText(
                        item.title,
                        style: AppTypography.titleS.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        item.section.title(l10n),
                        style: AppTypography.labelS.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: l10n.toolsFavoriteRemove,
                        icon: Icon(AppIcons.toolFavorite, color: c.primary),
                        onPressed: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(item.id),
                      ),
                      onTap: () => context.push(ContentRoutes.item(item.id)),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
