import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/glass_popups.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/prose_text.dart';
import '../../l10n/app_localizations.dart';
import '../tools/dial.dart';
import 'content_widgets.dart';
import 'package_facts.dart';
import 'section_ui.dart';

/// Long-press preview of an item: what the customer asks for (price, code,
/// number) with call and copy, without leaving the list.
Future<void> showItemPeek(BuildContext context, ContentItem item) {
  HapticFeedback.mediumImpact();
  return showGlassPopup<void>(
    context,
    builder: (context) => ItemPeek(item: item),
  );
}

class ItemPeek extends ConsumerWidget {
  const ItemPeek({super.key, required this.item});

  final ContentItem item;

  /// Values worth dialling or copying, the first ones only.
  static List<String> valuesOf(ContentItem item) {
    final all = item.type == ItemType.contact
        ? [...item.phones, ...item.codes]
        : [...item.codes, ...item.phones];
    return {...all}.take(3).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final line = item.type == ItemType.package
        ? PackageLine.of(item, l10n)
        : null;
    final values = valuesOf(item);
    final favorite = ref.watch(
      favoritesProvider.select((s) => s.contains(item.id)),
    );

    return GlassPopupCard(
      key: ValueKey('peek-${item.id}'),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TintedIcon(item.icon, tile: IconTile.md),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProseText(
                        item.title,
                        style: AppTypography.titleL.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ItemMark(item),
                    ],
                  ),
                ),
              ],
            ),
            if (line?.price case final price?) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceText(price, size: 30),
                  const SizedBox(width: AppSpacing.sm),
                  if (line!.details.isNotEmpty)
                    Expanded(
                      child: ProseText(
                        line.details,
                        style: AppTypography.bodyM.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ] else if (item.summary.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              ProseText(
                clipWords(item.summary, max: 140),
                style: AppTypography.bodyM.copyWith(color: c.textSecondary),
              ),
            ],
            for (final v in values) ...[
              const SizedBox(height: AppSpacing.sm),
              CodeText(v, onCall: (v) => launchDial(context, v)),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('peek-open'),
                    onPressed: () {
                      final router = GoRouter.of(context);
                      Navigator.of(context).pop();
                      router.push(ContentRoutes.item(item.id));
                    },
                    icon: const Icon(AppIcons.arrowForward),
                    label: Text(l10n.peekOpen),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton.filledTonal(
                  key: const ValueKey('peek-favorite'),
                  tooltip: favorite
                      ? l10n.toolsFavoriteRemove
                      : l10n.toolsFavoriteAdd,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref.read(favoritesProvider.notifier).toggle(item.id);
                  },
                  icon: Icon(
                    favorite ? AppIcons.toolFavorite : AppIcons.toolFavoriteOff,
                    color: c.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
