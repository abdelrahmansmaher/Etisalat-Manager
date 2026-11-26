import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/glass_popups.dart';
import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';
import 'tool_widgets.dart';

/// Device-only private notes, optionally scoped to one content item.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openEditor({PrivateNote? note}) async {
    final l10n = AppLocalizations.of(context);
    final saved = await showToolSheet<String>(
      context,
      (context) => SheetTextController(
        text: note?.text ?? '',
        builder: (context, controller) => SheetBody(
          title: note == null ? l10n.notesAdd : l10n.notesEdit,
          children: [
            TextField(
              key: const ValueKey('note-editor-field'),
              controller: controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(hintText: l10n.notesHint),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.toolsCancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('note-save'),
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: Text(l10n.toolsSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (saved == null || saved.trim().isEmpty || !mounted) return;
    final notifier = ref.read(notesProvider.notifier);
    if (note == null) {
      final item = widget.itemId == null
          ? null
          : ref.read(contentItemProvider(widget.itemId!));
      notifier.add(saved, itemId: widget.itemId, itemTitle: item?.title);
    } else {
      notifier.edit(note.id, saved);
    }
  }

  void _delete(PrivateNote note) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(notesProvider.notifier);
    notifier.remove(note.id);
    showGlassToast(
      context,
      l10n.notesDeleted,
      icon: AppIcons.toolDelete,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: l10n.toolsUndo,
        onPressed: () => notifier.putBack(note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final item = widget.itemId == null
        ? null
        : ref.watch(contentItemProvider(widget.itemId!));
    final all = widget.itemId == null
        ? ref.watch(notesProvider)
        : ref.watch(itemNotesProvider(widget.itemId!));
    final shown = searchNotes(all, _query);
    final locale = Localizations.localeOf(context);

    return PageScaffold(
      title: l10n.notesTitle,
      subtitle: item == null ? null : l10n.notesForItem(item.title),
      actions: [
        IconButton(
          key: const ValueKey('notes-add'),
          tooltip: l10n.notesAdd,
          icon: const Icon(AppIcons.toolAdd),
          onPressed: () => _openEditor(),
        ),
      ],
      children: [
        AppCard(
          role: CardRole.flat,
          color: c.warningContainer,
          borderColor: c.warning.withValues(alpha: 0.35),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconLine(
                icon: AppIcons.privateNote,
                text: l10n.notesWarning,
                color: c.onWarningContainer,
              ),
              const SizedBox(height: 2),
              Text(
                l10n.notesLocal,
                style: AppTypography.labelS.copyWith(
                  color: c.onWarningContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (all.isNotEmpty) ...[
          TextField(
            key: const ValueKey('notes-search'),
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l10n.notesSearch,
              prefixIcon: const Icon(AppIcons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(
                        AppIcons.clear,
                        size: AppIconSize.action,
                      ),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (shown.isEmpty)
          PlaceholderPanel(
            icon: AppIcons.toolNotes,
            title: l10n.notesEmpty,
            body: l10n.notesEmptyBody,
            action: FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(AppIcons.toolAdd),
              label: Text(l10n.notesAdd),
            ),
          )
        else
          for (final note in shown) ...[
            AppCard(
              key: ValueKey('note-${note.id}'),
              role: CardRole.flat,
              onTap: () => _openEditor(note: note),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ProseText(
                          note.text,
                          style: AppTypography.bodyL.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.notesDeleteOne,
                        icon: Icon(
                          AppIcons.toolDelete,
                          size: AppIconSize.action,
                          color: c.textTertiary,
                        ),
                        onPressed: () => _delete(note),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        TrustFormat.date(note.updatedAt, locale),
                        style: AppTypography.labelS.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                      if (widget.itemId == null &&
                          note.itemId != null &&
                          note.itemTitle != null)
                        InkWell(
                          onTap: () =>
                              context.push(ContentRoutes.item(note.itemId!)),
                          child: Text(
                            l10n.notesForItem(note.itemTitle!),
                            style: AppTypography.labelS.copyWith(
                              color: c.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
      ],
    );
  }
}
