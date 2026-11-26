import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../l10n/app_localizations.dart';
import '../content/section_ui.dart';
import 'tool_routes.dart';
import 'tool_widgets.dart';

/// List of the owner's local edits, plus export/import and new item creation.
class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    List<ContentOverride> edits,
  ) async {
    final l10n = AppLocalizations.of(context);
    final jsonText = OverridesTransfer.export(edits, ref.read(clockProvider)());
    await showToolSheet<void>(
      context,
      (ctx) => SheetBody(
        title: l10n.editorExport,
        children: [
          Text(
            l10n.editorExportNoNotes,
            style: AppTypography.bodyM.copyWith(
              color: ctx.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final res = await SharePlus.instance.share(
                  ShareParams(text: jsonText),
                );
                if (res.status == ShareResultStatus.unavailable &&
                    context.mounted) {
                  await Clipboard.setData(ClipboardData(text: jsonText));
                  if (context.mounted) {
                    showToolMessage(context, l10n.editorShareFailed);
                  }
                }
              } catch (_) {
                await Clipboard.setData(ClipboardData(text: jsonText));
                if (context.mounted) {
                  showToolMessage(context, l10n.editorShareFailed);
                }
              }
            },
            icon: const Icon(AppIcons.toolExport),
            label: Text(l10n.editorShare),
          ),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: jsonText));
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) showToolMessage(context, l10n.editorCopied);
            },
            icon: const Icon(AppIcons.copy),
            label: Text(l10n.editorCopy),
          ),
        ],
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    ImportDiff? preview;
    String? error;
    int missing = 0;

    await showToolSheet<void>(
      context,
      (ctx) => SheetTextController(
        builder: (ctx, controller) => StatefulBuilder(
          builder: (ctx, setSheet) {
            final bundled = ref.read(bundledRawProvider).value ?? const {};
            final mine = ref.read(overridesProvider);
            void inspect() {
              try {
                final incoming = OverridesTransfer.parse(controller.text);
                final diff = OverridesTransfer.diff(mine, incoming);
                final m = incoming
                    .where((o) => !o.isNew && !bundled.containsKey(o.id))
                    .length;
                setSheet(() {
                  preview = diff;
                  missing = m;
                  error = null;
                });
              } catch (_) {
                setSheet(() {
                  preview = null;
                  error = l10n.editorImportInvalid;
                });
              }
            }

            return SheetBody(
              title: l10n.editorImport,
              children: [
                TextField(
                  controller: controller,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: l10n.editorImportHint,
                    errorText: error,
                    errorMaxLines: 3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final data = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        if (data?.text != null) {
                          controller.text = data!.text!;
                          inspect();
                        }
                      },
                      icon: const Icon(AppIcons.toolImport),
                      label: Text(l10n.editorPaste),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: FilledButton(
                        onPressed: inspect,
                        child: Text(l10n.editorImportCheck),
                      ),
                    ),
                  ],
                ),
                if (preview != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  if (preview!.isEmpty)
                    Text(
                      l10n.editorImportNothing,
                      style: AppTypography.bodyM.copyWith(
                        color: ctx.colors.textSecondary,
                      ),
                    )
                  else ...[
                    Text(
                      l10n.editorImportDiff(
                        preview!.added.length,
                        preview!.replaced.length,
                        preview!.same,
                      ),
                      style: AppTypography.titleS,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.editorImportKeeps,
                      style: AppTypography.bodyS.copyWith(
                        color: ctx.colors.textSecondary,
                      ),
                    ),
                    if (missing > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.editorImportMissing(missing),
                        style: AppTypography.bodyS.copyWith(
                          color: ctx.colors.onWarningContainer,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton(
                      onPressed: () {
                        ref.read(overridesProvider.notifier).saveAll([
                          ...preview!.added,
                          ...preview!.replaced,
                        ]);
                        Navigator.pop(ctx);
                        showToolMessage(context, l10n.editorImportDone);
                      },
                      child: Text(l10n.editorImportApply),
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overrides = ref.watch(overridesProvider);
    final edits = overrides.values.toList()
      ..sort((a, b) => b.editedAt.compareTo(a.editedAt));
    final bundled = ref.watch(bundledRawProvider).value ?? const {};

    return PageScaffold(
      title: l10n.editorMyEdits,
      actions: [
        IconButton(
          key: const ValueKey('editor-add'),
          tooltip: l10n.editorAdd,
          icon: const Icon(AppIcons.toolAdd),
          onPressed: () => context.push(ToolRoutes.newItem),
        ),
      ],
      children: [
        ToolHero(
          icon: AppIcons.toolEdits,
          hue: ToolHue.editor,
          text: l10n.editorLocalOnly,
          stats: [('${edits.length}', l10n.heroEdits)],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const ValueKey('editor-import'),
                onPressed: () => _import(context, ref),
                icon: const Icon(AppIcons.toolImport),
                label: Text(l10n.editorImport),
              ),
            ),
            if (edits.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('editor-export'),
                  onPressed: () => _export(context, ref, edits),
                  icon: const Icon(AppIcons.toolExport),
                  label: Text(l10n.editorExport),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (edits.isEmpty)
          PlaceholderPanel(
            icon: AppIcons.toolEdits,
            title: l10n.editorEmpty,
            body: l10n.editorEmptyBody,
            action: FilledButton.icon(
              onPressed: () => context.push(ToolRoutes.newItem),
              icon: const Icon(AppIcons.toolAdd),
              label: Text(l10n.editorAdd),
            ),
          )
        else
          for (final o in edits) ...[
            _EditRow(
              entry: o,
              state: editStateOf(o, bundled),
              bundledItem: bundled[o.id]?.$2,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
      ],
    );
  }
}

class _EditRow extends ConsumerWidget {
  const _EditRow({
    required this.entry,
    required this.state,
    required this.bundledItem,
  });

  final ContentOverride entry;
  final EditState state;
  final RawItem? bundledItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final title =
        (entry.fields['title_ar'] as String?) ??
        (bundledItem?['title_ar'] as String?) ??
        entry.id;

    final badge = switch (state) {
      EditState.added => (l10n.editorStateAdded, c.primary, c.primaryContainer),
      EditState.current => (
        entry.hidden ? l10n.editorStateHidden : l10n.editedByYou,
        c.textSecondary,
        c.surfaceVariant,
      ),
      EditState.newerBundled => (
        l10n.editorStateNewer,
        c.onWarningContainer,
        c.warningContainer,
      ),
      EditState.removed => (
        l10n.editorStateRemoved,
        c.onErrorContainer,
        c.errorContainer,
      ),
    };

    Future<void> restore() async {
      final ok = await askToConfirm(
        context,
        title: entry.isNew
            ? l10n.editorDeleteAsk(title)
            : l10n.editorRestoreAsk(title),
        body: entry.isNew ? null : l10n.editorRestoreBody,
        confirm: entry.isNew ? l10n.toolsDelete : l10n.editorRestore,
      );
      if (ok) ref.read(overridesProvider.notifier).restore(entry.id);
    }

    return AppCard(
      role: CardRole.flat,
      onTap: state == EditState.removed || entry.hidden
          ? null
          : () => context.push(ContentRoutes.item(entry.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: badge.$3,
              borderRadius: AppRadius.xsAll,
            ),
            child: Text(
              badge.$1,
              style: AppTypography.labelS.copyWith(color: badge.$2),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ProseText(
            title,
            style: AppTypography.titleM.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if (state != EditState.removed)
                Capsule(
                  dense: true,
                  icon: AppIcons.toolEdits,
                  label: l10n.toolsEditAction,
                  onTap: () => context.push(ToolRoutes.editItem(entry.id)),
                ),
              if (state == EditState.newerBundled && bundledItem != null) ...[
                Capsule(
                  dense: true,
                  icon: AppIcons.selected,
                  label: l10n.editorKeepMine,
                  onTap: () => ref
                      .read(overridesProvider.notifier)
                      .keepMine(entry.id, fingerprint(bundledItem!)),
                ),
                Capsule(
                  dense: true,
                  icon: AppIcons.toolRestore,
                  label: l10n.editorUseNew,
                  onTap: restore,
                ),
              ] else
                Capsule(
                  dense: true,
                  icon: entry.isNew
                      ? AppIcons.toolDelete
                      : AppIcons.toolRestore,
                  label: entry.isNew
                      ? l10n.editorDeleteAdded
                      : l10n.editorRestore,
                  onTap: restore,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditableFact {
  _EditableFact({
    required String label,
    required String value,
    required String unit,
    required this.kind,
  }) : label = TextEditingController(text: label),
       value = TextEditingController(text: value),
       unit = TextEditingController(text: unit);

  final TextEditingController label;
  final TextEditingController value;
  final TextEditingController unit;
  FactKind kind;

  void dispose() {
    label.dispose();
    value.dispose();
    unit.dispose();
  }
}

/// Create or edit a local content item override.
class ItemEditorScreen extends ConsumerStatefulWidget {
  const ItemEditorScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<ItemEditorScreen> createState() => _ItemEditorScreenState();
}

class _ItemEditorScreenState extends ConsumerState<ItemEditorScreen> {
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _body = TextEditingController();
  final _steps = TextEditingController();
  final _category = TextEditingController();
  final _codes = TextEditingController();
  final _phones = TextEditingController();
  final _statusNote = TextEditingController();
  final List<_EditableFact> _facts = [];

  ContentSection _section = ContentSection.packages;
  ItemType _type = ItemType.article;
  bool _hidden = false;
  bool _dirty = false;
  bool _loaded = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _body.dispose();
    _steps.dispose();
    _category.dispose();
    _codes.dispose();
    _phones.dispose();
    _statusNote.dispose();
    for (final f in _facts) {
      f.dispose();
    }
    super.dispose();
  }

  static ContentItem? _hiddenItem(RawItem? base, ContentOverride? existing) {
    if (existing == null) return null;
    try {
      return ContentItem.fromJson({
        ...?base,
        ...existing.fields,
        'id': existing.id,
      }, existing.section);
    } on FormatException {
      return null;
    }
  }

  void _initFrom(ContentItem? item, ContentOverride? existing) {
    if (_loaded) return;
    _loaded = true;
    if (item != null) {
      _section = item.section;
      _type = item.type;
      _title.text = item.title;
      _summary.text = _clean(item.summary);
      _body.text = _clean(item.body ?? '');
      _steps.text = item.steps.map(_clean).join('\n');
      _category.text = item.category;
      _codes.text = item.codes.join('\n');
      _phones.text = item.phones.join('\n');
      _statusNote.text = (existing?.fields['status_note_ar'] as String?) ?? '';
      for (final f in item.facts) {
        _facts.add(
          _EditableFact(
            label: f.label,
            value: f.value,
            unit: f.unit ?? '',
            kind: f.kind,
          ),
        );
      }
    }
    if (existing != null) {
      _hidden = existing.hidden;
    }
  }

  /// Without the invisible marks added around codes for display.
  static String _clean(String s) =>
      s.replaceAll(String.fromCharCode(0x200E), '');

  void _markDirty([Object? _]) {
    if (!_dirty) setState(() => _dirty = true);
  }

  List<String> _lines(TextEditingController c) => [
    for (final line in c.text.split('\n'))
      if (line.trim().isNotEmpty) line.trim(),
  ];

  void _save(
    ContentItem? current,
    ContentOverride? existing,
    RawItem? baseRaw,
  ) {
    final l10n = AppLocalizations.of(context);
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l10n.editorTitleRequired);
      return;
    }
    for (final f in _facts) {
      final hasL = f.label.text.trim().isNotEmpty;
      final hasV = f.value.text.trim().isNotEmpty;
      if (hasL != hasV || (!hasL && !hasV)) {
        setState(() => _error = l10n.editorFactRequired);
        return;
      }
    }
    setState(() => _error = null);

    final factsJson = [
      for (final f in _facts)
        {
          'label_ar': f.label.text.trim(),
          'value': f.value.text.trim(),
          if (f.unit.text.trim().isNotEmpty) 'unit': f.unit.text.trim(),
          'kind': f.kind.name,
        },
    ];
    final fields = <String, dynamic>{
      'title_ar': title,
      'summary_ar': _summary.text.trim(),
      'body_ar': _body.text.trim(),
      'steps_ar': _lines(_steps),
      'category_ar': _category.text.trim(),
      'type': _type.name,
      'facts': factsJson,
      'codes': _lines(_codes),
      'phones': _lines(_phones),
      if (_statusNote.text.trim().isNotEmpty)
        'status_note_ar': _statusNote.text.trim(),
    };

    final notifier = ref.read(overridesProvider.notifier);
    final isNew = widget.itemId == null || (existing?.isNew ?? false);
    if (!isNew && baseRaw != null) {
      // Keep only what really changed, so a corrected title does not drop
      // the original's structured price and quota.
      fields.removeWhere((k, v) => _sameAsBase(baseRaw[k], v));
      if (fields.isEmpty && !_hidden) {
        if (existing != null) {
          notifier.restore(existing.id);
          setState(() => _dirty = false);
          showToolMessage(context, l10n.editorSaved);
        } else {
          setState(() => _dirty = false);
          showToolMessage(context, l10n.editorNothingChanged);
        }
        if (context.canPop()) context.pop();
        return;
      }
    }
    final id = widget.itemId ?? notifier.newId();
    final override = ContentOverride(
      id: id,
      section: _section,
      isNew: isNew,
      hidden: _hidden,
      fields: fields,
      editedAt: ref.read(clockProvider)(),
      baseFingerprint: baseRaw == null
          ? existing?.baseFingerprint
          : fingerprint(baseRaw),
    );
    notifier.save(override);
    setState(() => _dirty = false);
    showToolMessage(context, l10n.editorSaved);
    if (context.canPop()) context.pop();
  }

  /// Missing and empty mean the same; a fact without a unit equals one with
  /// an empty unit.
  static bool _sameAsBase(Object? base, Object? mine) {
    bool empty(Object? v) => v == null || v == '' || (v is List && v.isEmpty);
    if (empty(base) && empty(mine)) return true;
    if (base is List && mine is List && base.every((e) => e is Map)) {
      Object? norm(Object? f) => f is! Map
          ? f
          : {
              'label_ar': '${f['label_ar'] ?? ''}'.trim(),
              'value': '${f['value'] ?? ''}'.trim(),
              'unit': '${f['unit'] ?? ''}'.trim(),
              'kind': FactKind.parse(f['kind']).name,
            };
      return canonicalJson([for (final f in base) norm(f)]) ==
          canonicalJson([for (final f in mine) norm(f)]);
    }
    if (base is String && mine is String) return base.trim() == mine.trim();
    return canonicalJson(base) == canonicalJson(mine);
  }

  static String _kindLabel(AppLocalizations l10n, FactKind k) => switch (k) {
    FactKind.price => l10n.editorKindPrice,
    FactKind.code => l10n.editorKindCode,
    FactKind.phone => l10n.editorKindPhone,
    FactKind.quantity => l10n.editorKindQuantity,
    FactKind.duration => l10n.editorKindDuration,
    FactKind.percent => l10n.editorKindPercent,
    FactKind.date => l10n.editorKindDate,
    FactKind.text => l10n.editorKindText,
  };

  static String _typeLabel(AppLocalizations l10n, ItemType t) => switch (t) {
    ItemType.package => l10n.editorTypePackage,
    ItemType.code => l10n.editorTypeCode,
    ItemType.contact => l10n.editorTypeContact,
    ItemType.service => l10n.editorTypeService,
    ItemType.procedure => l10n.editorTypeProcedure,
    ItemType.fee => l10n.editorTypeFee,
    ItemType.rule => l10n.editorTypeRule,
    ItemType.article => l10n.editorTypeArticle,
    ItemType.glossary => l10n.editorTypeGlossary,
    ItemType.faq => l10n.editorTypeFaq,
    _ => l10n.editorTypeArticle,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final item = widget.itemId == null
        ? null
        : ref.watch(contentItemProvider(widget.itemId!));
    final existing = widget.itemId == null
        ? null
        : ref.watch(itemOverrideProvider(widget.itemId!));
    final bundled = ref.watch(bundledRawProvider);
    final baseRaw = widget.itemId == null
        ? null
        : bundled.value?[widget.itemId!]?.$2;

    if (widget.itemId != null && bundled.value == null && bundled.isLoading) {
      return PageScaffold(
        title: l10n.editorEditTitle,
        children: const [SkeletonList()],
      );
    }
    if (widget.itemId != null && item == null && existing == null) {
      return PageScaffold(
        title: l10n.editorEditTitle,
        children: [
          PlaceholderPanel(
            icon: AppIcons.notFound,
            title: l10n.detailNotFound,
            body: l10n.toolsItemRemoved,
          ),
        ],
      );
    }

    // A hidden item is not in the library: rebuild it from its original and
    // the edit, so the form never opens blank over existing data.
    _initFrom(item ?? _hiddenItem(baseRaw, existing), existing);
    final isNew = widget.itemId == null || (existing?.isNew ?? false);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await askToConfirm(
          context,
          title: l10n.editorLeaveAsk,
          confirm: l10n.editorLeave,
          cancel: l10n.editorStay,
        );
        if (leave && context.mounted) {
          setState(() => _dirty = false);
          context.pop();
        }
      },
      child: PageScaffold(
        title: isNew ? l10n.editorNewTitle : l10n.editorEditTitle,
        actions: [
          TextButton(
            key: const ValueKey('editor-save'),
            onPressed: () => _save(item, existing, baseRaw),
            child: Text(l10n.toolsSave),
          ),
        ],
        children: [
          AppCard(
            role: CardRole.flat,
            color: c.warningContainer,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: IconLine(
              icon: AppIcons.info,
              text: l10n.editorNotConfirmed,
              color: c.onWarningContainer,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              role: CardRole.flat,
              color: c.errorContainer,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: IconLine(
                icon: AppIcons.conflict,
                text: _error!,
                color: c.onErrorContainer,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (isNew) ...[
            DropdownButtonFormField<ContentSection>(
              isExpanded: true,
              initialValue: _section,
              decoration: InputDecoration(labelText: l10n.editorFieldSection),
              items: [
                for (final s in ContentSection.values)
                  DropdownMenuItem(value: s, child: Text(s.title(l10n))),
              ],
              onChanged: (s) {
                if (s != null) {
                  setState(() => _section = s);
                  _markDirty();
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<ItemType>(
              isExpanded: true,
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.editorFieldType),
              items: [
                for (final t in const [
                  ItemType.package,
                  ItemType.code,
                  ItemType.contact,
                  ItemType.service,
                  ItemType.procedure,
                  ItemType.fee,
                  ItemType.rule,
                  ItemType.article,
                  ItemType.glossary,
                  ItemType.faq,
                ])
                  DropdownMenuItem(value: t, child: Text(_typeLabel(l10n, t))),
              ],
              onChanged: (t) {
                if (t != null) {
                  setState(() => _type = t);
                  _markDirty();
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          TextField(
            key: const ValueKey('editor-title'),
            controller: _title,
            onChanged: _markDirty,
            decoration: InputDecoration(labelText: l10n.editorFieldTitle),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _category,
            onChanged: _markDirty,
            decoration: InputDecoration(labelText: l10n.editorFieldCategory),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _summary,
            minLines: 2,
            maxLines: 4,
            onChanged: _markDirty,
            decoration: InputDecoration(labelText: l10n.editorFieldSummary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const ValueKey('editor-body'),
            controller: _body,
            minLines: 2,
            maxLines: 8,
            onChanged: _markDirty,
            decoration: InputDecoration(labelText: l10n.editorFieldBody),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const ValueKey('editor-steps'),
            controller: _steps,
            minLines: 1,
            maxLines: 8,
            onChanged: _markDirty,
            decoration: InputDecoration(labelText: l10n.editorFieldSteps),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(
            l10n.editorFieldFacts,
            trailing: TextButton.icon(
              onPressed: () {
                setState(() {
                  _facts.add(
                    _EditableFact(
                      label: '',
                      value: '',
                      unit: '',
                      kind: FactKind.text,
                    ),
                  );
                });
                _markDirty();
              },
              icon: const Icon(AppIcons.toolAdd),
              label: Text(l10n.editorAddFact),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < _facts.length; i++) ...[
            AppCard(
              key: ObjectKey(_facts[i]),
              role: CardRole.flat,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _facts[i].label,
                          onChanged: _markDirty,
                          decoration: InputDecoration(
                            labelText: l10n.editorFactLabel,
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.editorRemoveFact(i + 1),
                        icon: Icon(AppIcons.toolRemove, color: c.error),
                        onPressed: () {
                          final removed = _facts.removeAt(i);
                          removed.dispose();
                          setState(() {});
                          _markDirty();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _facts[i].value,
                          onChanged: _markDirty,
                          decoration: InputDecoration(
                            labelText: l10n.editorFactValue,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: TextField(
                          controller: _facts[i].unit,
                          onChanged: _markDirty,
                          decoration: InputDecoration(
                            labelText: l10n.editorFactUnit,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<FactKind>(
                    isExpanded: true,
                    initialValue: _facts[i].kind,
                    decoration: InputDecoration(
                      labelText: l10n.editorFactKind,
                      isDense: true,
                    ),
                    items: [
                      for (final k in FactKind.values)
                        DropdownMenuItem(
                          value: k,
                          child: Text(_kindLabel(l10n, k)),
                        ),
                    ],
                    onChanged: (k) {
                      if (k != null) {
                        setState(() => _facts[i].kind = k);
                        _markDirty();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _codes,
            minLines: 1,
            maxLines: 4,
            textDirection: TextDirection.ltr,
            onChanged: _markDirty,
            decoration: InputDecoration(labelText: l10n.editorFieldCodes),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _phones,
            minLines: 1,
            maxLines: 4,
            textDirection: TextDirection.ltr,
            onChanged: _markDirty,
            decoration: InputDecoration(labelText: l10n.editorFieldPhones),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _statusNote,
            onChanged: _markDirty,
            decoration: InputDecoration(labelText: l10n.editorFieldStatusNote),
          ),
          if (!isNew) ...[
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              value: _hidden,
              title: Text(l10n.editorHide),
              subtitle: Text(l10n.editorHideHint),
              onChanged: (v) {
                setState(() => _hidden = v);
                _markDirty();
              },
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => _save(item, existing, baseRaw),
            child: Text(l10n.toolsSave),
          ),
        ],
      ),
    );
  }
}
