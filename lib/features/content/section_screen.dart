import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_localizations.dart';
import 'content_widgets.dart';
import 'section_ui.dart';

enum StatusFilter { all, confirmed, unconfirmed }

/// Items of one section grouped by `category_ar` (pinned headers), with
/// status filter chips. Unconfirmed groups come last.
class SectionScreen extends ConsumerStatefulWidget {
  const SectionScreen({super.key, required this.sectionKey});

  final String sectionKey;

  @override
  ConsumerState<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends ConsumerState<SectionScreen> {
  StatusFilter _filter = StatusFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final section = ContentSection.fromKey(widget.sectionKey);
    final async = ref.watch(contentProvider);
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);

    if (section == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: EdgeInsets.all(pad),
          child: PlaceholderPanel(
            icon: Icons.search_off_rounded,
            title: l10n.detailNotFound,
            body: l10n.detailNotFoundBody,
          ),
        ),
      );
    }

    final all = async.value?.itemsOf(section) ?? const <ContentItem>[];
    final items = [
      for (final i in all)
        if (switch (_filter) {
          StatusFilter.all => true,
          StatusFilter.confirmed => i.status == ItemStatus.confirmed,
          StatusFilter.unconfirmed => i.status != ItemStatus.confirmed,
        })
          i,
    ];

    // Group by category, keeping first-seen order; unverified groups last.
    final groups = <String, List<ContentItem>>{};
    final late = <String, List<ContentItem>>{};
    for (final i in items) {
      final unverified = i.type == ItemType.unverified;
      final name = i.category.isNotEmpty
          ? i.category
          : (unverified ? l10n.unconfirmedGroupTitle : section.title(l10n));
      (unverified ? late : groups).putIfAbsent(name, () => []).add(i);
    }
    for (final e in late.entries) {
      groups.putIfAbsent(e.key, () => []).addAll(e.value);
    }

    final hPad = EdgeInsetsDirectional.symmetric(horizontal: pad);

    return Scaffold(
      appBar: AppBar(title: Text(section.title(l10n))),
      body: CustomScrollView(
        key: const ValueKey('section-scroll'),
        slivers: [
          SliverPadding(
            padding: EdgeInsetsDirectional.fromSTEB(pad, AppSpacing.sm, pad, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.subtitle(l10n),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final f in StatusFilter.values)
                        ChoiceChip(
                          key: ValueKey('filter-${f.name}'),
                          label: Text(switch (f) {
                            StatusFilter.all => l10n.filterAll,
                            StatusFilter.confirmed => l10n.filterConfirmed,
                            StatusFilter.unconfirmed => l10n.filterUnconfirmed,
                          }),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.itemCount(items.length),
                    style: AppTypography.labelS.copyWith(color: c.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          if (async.isLoading && async.value == null)
            const SliverToBoxAdapter(child: ContentLoading())
          else if (items.isEmpty)
            SliverPadding(
              padding: EdgeInsets.all(pad),
              sliver: SliverToBoxAdapter(
                child: PlaceholderPanel(
                  icon: Icons.inbox_outlined,
                  title: l10n.contentEmptySection,
                  body: l10n.contentEmptySectionBody,
                ),
              ),
            ),
          for (final g in groups.entries)
            SliverMainAxisGroup(
              slivers: [
                PinnedHeaderSliver(
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    padding: EdgeInsetsDirectional.fromSTEB(
                      pad,
                      AppSpacing.md,
                      pad,
                      AppSpacing.xs,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        g.key,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: c.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: hPad,
                  sliver: SliverList.separated(
                    itemCount: g.value.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.cardGap),
                    itemBuilder: (_, i) => ContentItemRow(item: g.value[i]),
                  ),
                ),
              ],
            ),
          SliverPadding(
            padding: EdgeInsetsDirectional.fromSTEB(
              pad,
              AppSpacing.xl,
              pad,
              AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: const SliverToBoxAdapter(
              child: UnofficialDisclaimer.compact(),
            ),
          ),
        ],
      ),
    );
  }
}
