import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/router/tab_pager.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../l10n/app_localizations.dart';
import '../content/package_family.dart';
import 'compare_logic.dart';
import 'package_info.dart';
import 'tool_widgets.dart';

/// Side-by-side comparison of 2 to 4 packages.
class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key, this.initialId});

  final String? initialId;

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final List<String> _selectedIds = [];
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final id = widget.initialId;
    if (id != null && id.isNotEmpty) {
      _selectedIds.add(id);
    }
  }

  Future<void> _addPackage() async {
    final picked = await showPackagePicker(
      context,
      exclude: _selectedIds.toSet(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (!_selectedIds.contains(picked.item.id) && _selectedIds.length < 4) {
        _selectedIds.add(picked.item.id);
      }
    });
  }

  void _remove(String id) {
    setState(() => _selectedIds.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final allInfos = ref.watch(packageInfosProvider);
    final byId = {for (final p in allInfos) p.item.id: p};
    final selected = [
      for (final id in _selectedIds)
        if (byId[id] != null) byId[id]!,
    ];

    final rows = selected.length >= 2 ? compareRows(selected) : const <CompareValues>[];
    final differs = selected.length >= 2 && periodsDiffer(selected);

    return PageScaffold(
      title: l10n.toolsCompareTitle,
      subtitle: l10n.toolsCompareHint,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final p in selected)
              Capsule(
                key: ValueKey('compare-chip-${p.item.id}'),
                label: p.item.title,
                selected: true,
                trailing: Icon(
                  AppIcons.toolRemove,
                  size: AppIconSize.inline,
                  color: c.onCapsuleSelected,
                ),
                semanticsLabel: l10n.toolsCompareRemove(p.item.title),
                onTap: () => _remove(p.item.id),
              ),
            if (selected.length < 4)
              Capsule(
                key: const ValueKey('compare-add'),
                icon: AppIcons.toolAdd,
                label: l10n.toolsCompareAdd,
                onTap: _addPackage,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (selected.length < 2)
          PlaceholderPanel(
            icon: AppIcons.toolCompare,
            title: l10n.toolsCompareTitle,
            body: l10n.toolsCompareHint,
            action: FilledButton.icon(
              onPressed: _addPackage,
              icon: const Icon(AppIcons.toolAdd),
              label: Text(l10n.toolsCompareAdd),
            ),
          )
        else ...[
          if (differs) ...[
            AppCard(
              role: CardRole.flat,
              color: c.warningContainer,
              borderColor: c.warning.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: IconLine(
                icon: AppIcons.info,
                text: l10n.toolsComparePeriods,
                color: c.onWarningContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _CompareTable(packages: selected, rows: rows),
        ],
      ],
    );
  }
}

class _CompareTable extends StatelessWidget {
  const _CompareTable({required this.packages, required this.rows});

  final List<PackageInfo> packages;
  final List<CompareValues> rows;

  static String _rowLabel(AppLocalizations l10n, CompareRow row) => switch (row) {
    CompareRow.price => l10n.toolsRowPrice,
    CompareRow.total => l10n.toolsRowTotal,
    CompareRow.quota => l10n.toolsRowQuota,
    CompareRow.gb => l10n.toolsRowGb,
    CompareRow.minutes => l10n.toolsRowMinutes,
    CompareRow.mix => l10n.toolsRowMix,
    CompareRow.validity => l10n.toolsRowValidity,
    CompareRow.code => l10n.toolsRowCode,
    CompareRow.after => l10n.toolsRowAfter,
  };

  static String? _bestBadge(AppLocalizations l10n, CompareRow row) =>
      switch (row) {
        CompareRow.price || CompareRow.total => l10n.toolsBestLowest,
        CompareRow.gb || CompareRow.minutes || CompareRow.mix =>
          l10n.toolsBestHighest,
        CompareRow.validity => l10n.toolsBestLongest,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    const labelWidth = 108.0;
    const colWidth = 152.0;

    return AppCard(
      role: CardRole.flat,
      padding: EdgeInsets.zero,
      child: TabSwipeOptOut(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: labelWidth + colWidth * packages.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Package header row
                Container(
                  color: c.surfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            l10n.toolsRowPackage,
                            style: AppTypography.labelL.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      for (final p in packages)
                        SizedBox(
                          width: colWidth,
                          child: InkWell(
                            onTap: () =>
                                context.push(ContentRoutes.item(p.item.id)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FamilyTile(p.family),
                                  const SizedBox(height: AppSpacing.xs),
                                  ProseText(
                                    p.item.title,
                                    style: AppTypography.titleS.copyWith(
                                      color: c.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Comparison metric rows
                for (final r in rows)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.hairline)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: labelWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: Text(
                              _rowLabel(l10n, r.row),
                              style: AppTypography.labelL.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        for (var i = 0; i < packages.length; i++)
                          SizedBox(
                            width: colWidth,
                            child: _CompareCell(
                              value: r.texts[i],
                              isCode: r.row == CompareRow.code,
                              isPrice:
                                  r.row == CompareRow.price ||
                                  r.row == CompareRow.total,
                              bestLabel: r.best.contains(i)
                                  ? _bestBadge(l10n, r.row)
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                // Status row
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.hairline)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            l10n.toolsRowStatus,
                            style: AppTypography.labelL.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      for (final p in packages)
                        SizedBox(
                          width: colWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: ItemStatusTag(p.item),
                          ),
                        ),
                    ],
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

class _CompareCell extends StatelessWidget {
  const _CompareCell({
    required this.value,
    required this.isCode,
    required this.isPrice,
    this.bestLabel,
  });

  final String? value;
  final bool isCode;
  final bool isPrice;
  final String? bestLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: bestLabel == null
          ? null
          : BoxDecoration(
              color: c.verifiedContainer,
              borderRadius: AppRadius.xsAll,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bestLabel != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.toolBest,
                  size: AppIconSize.inline,
                  color: c.verified,
                ),
                const SizedBox(width: 4),
                Text(
                  bestLabel!,
                  style: AppTypography.labelS.copyWith(
                    color: c.verified,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
          ],
          if (isPrice && value != null && value!.trim().isNotEmpty)
            GoldAmount(value!)
          else if (isCode && value != null && value!.trim().isNotEmpty)
            CodeValue(value!)
          else
            ToolValue(value, isCode: isCode),
        ],
      ),
    );
  }
}
