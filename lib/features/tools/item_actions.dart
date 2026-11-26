import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/app_card.dart';
import '../../l10n/app_localizations.dart';
import '../content/item_summary.dart';
import '../content/package_facts.dart';
import '../export/export_sheet.dart';
import 'dial.dart';
import 'dial_template.dart';
import 'tool_routes.dart';
import 'tool_widgets.dart';

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
    final actions = <Widget>[
      if (dial.isNotEmpty)
        _ActionTile(
          key: const ValueKey('action-dial'),
          icon: AppIcons.call,
          label: l10n.toolsDial,
          onTap: () => launchDialAny(context, dial),
        ),
      _ActionTile(
        key: const ValueKey('action-favorite'),
        icon: favorite ? AppIcons.toolFavorite : AppIcons.toolFavoriteOff,
        label: l10n.toolsFavorite,
        semanticsLabel: favorite
            ? l10n.toolsFavoriteRemove
            : l10n.toolsFavoriteAdd,
        onTap: () => ref.read(favoritesProvider.notifier).toggle(item.id),
      ),
      if (item.type == ItemType.package)
        _ActionTile(
          key: const ValueKey('action-compare'),
          icon: AppIcons.toolCompare,
          label: l10n.toolsCompareAction,
          onTap: () => context.push(ToolRoutes.compareWith(item.id)),
        ),
      _ActionTile(
        key: const ValueKey('action-share'),
        icon: AppIcons.share,
        label: l10n.toolsShareSummary,
        onTap: () => showExportSheet(
          context,
          title: item.title,
          text: customerSummary(item),
          pdf: (pdf) => pdf.item(item),
        ),
      ),
      _ActionTile(
        key: const ValueKey('action-note'),
        icon: AppIcons.toolNotes,
        label: notes == 0 ? l10n.toolsNoteAction : l10n.toolsNoteCount(notes),
        onTap: () => context.push(ToolRoutes.notesFor(item.id)),
      ),
      _ActionTile(
        key: const ValueKey('action-edit'),
        icon: AppIcons.toolEdits,
        label: l10n.toolsEditAction,
        onTap: () => context.push(ToolRoutes.editItem(item.id)),
      ),
    ];
    // An even grid: three equal tiles a row, icon over its name.
    return LayoutBuilder(
      key: const ValueKey('item-actions'),
      builder: (context, box) {
        const gap = AppSpacing.xs;
        final columns = box.maxWidth >= 560 ? 6 : 3;
        final w = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final a in actions) SizedBox(width: w, child: a)],
        );
      },
    );
  }
}

/// One action: a tinted circle with the icon and the name under it.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticsLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      role: CardRole.flat,
      semanticLabel: semanticsLabel ?? label,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xxs,
      ),
      onTap: onTap,
      child: Column(
        children: [
          TintedIcon(icon, tile: IconTile.sm),
          const SizedBox(height: AppSpacing.xxs + 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTypography.labelS.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sends the customer summary through the share sheet; copies it when sharing
/// is not available.
Future<void> shareSummary(BuildContext context, ContentItem item) async {
  final l10n = AppLocalizations.of(context);
  final text = customerSummary(item);
  var shared = false;
  try {
    final r = await SharePlus.instance.share(ShareParams(text: text));
    shared = r.status != ShareResultStatus.unavailable;
  } catch (_) {
    // No share sheet on this device or browser.
  }
  if (shared) return;
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) showToolMessage(context, l10n.toolsSummaryCopied);
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
