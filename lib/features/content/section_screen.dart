import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_localizations.dart';
import 'content_widgets.dart';
import 'section_ui.dart';

enum StatusFilter { all, confirmed, unconfirmed }

/// Items of one section grouped by `category_ar` under sticky headers, a
/// segmented capsule status filter (الكل / مؤكد / غير مؤكد) and a row of
/// jump-to-category capsules. Unconfirmed groups come last.
class SectionScreen extends ConsumerStatefulWidget {
  const SectionScreen({super.key, required this.sectionKey});

  final String sectionKey;

  @override
  ConsumerState<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends ConsumerState<SectionScreen> {
  StatusFilter _filter = StatusFilter.all;
  final _scroll = ScrollController();
  final Map<String, GlobalKey> _headerKeys = {};
  String? _activeGroup;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String group) =>
      _headerKeys.putIfAbsent(group, () => GlobalKey(debugLabel: group));

  /// Scrolls until the (lazily built) header of [group] exists, then aligns
  /// it to the top under the app bar.
  Future<void> _jumpTo(String group) async {
    setState(() => _activeGroup = group);
    final key = _keyFor(group);
    if (!_scroll.hasClients) return;
    if (key.currentContext == null) {
      _scroll.jumpTo(0);
      await WidgetsBinding.instance.endOfFrame;
      for (var i = 0; i < 40 && key.currentContext == null; i++) {
        final p = _scroll.position;
        if (p.pixels >= p.maxScrollExtent) break;
        _scroll.jumpTo(
          (p.pixels + p.viewportDimension * 0.8).clamp(0, p.maxScrollExtent),
        );
        await WidgetsBinding.instance.endOfFrame;
      }
    }
    final ctx = key.currentContext;
    if (!mounted || ctx == null || !ctx.mounted) return;
    final duration = AppMotion.resolve(context, AppMotion.emphasized);
    await Scrollable.ensureVisible(
      ctx,
      duration: duration,
      curve: AppMotion.enter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final section = ContentSection.fromKey(widget.sectionKey);
    final async = ref.watch(contentProvider);
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);

    if (section == null) {
      return PageScaffold(
        title: l10n.detailNotFound,
        children: [
          PlaceholderPanel(
            icon: Icons.search_off_rounded,
            title: l10n.detailNotFound,
            body: l10n.detailNotFoundBody,
          ),
        ],
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
    final tone = section.tone(context);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedCapsule<StatusFilter>(
          key: const ValueKey('status-filter'),
          selected: _filter,
          onChanged: (f) => setState(() {
            _filter = f;
            _activeGroup = null;
          }),
          segments: [
            for (final f in StatusFilter.values)
              CapsuleSegment(
                key: ValueKey('filter-${f.name}'),
                value: f,
                label: switch (f) {
                  StatusFilter.all => l10n.filterAll,
                  StatusFilter.confirmed => l10n.filterConfirmed,
                  StatusFilter.unconfirmed => l10n.filterUnconfirmed,
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(Icons.layers_rounded, size: 16, color: tone.foreground),
            const SizedBox(width: AppSpacing.xxs + 2),
            Expanded(
              child: Text(
                l10n.itemCount(items.length),
                key: const ValueKey('section-count'),
                style: AppTypography.labelS.copyWith(color: c.textTertiary),
              ),
            ),
          ],
        ),
      ],
    );

    return PageScaffold(
      scrollKey: const ValueKey('section-scroll'),
      controller: _scroll,
      title: section.title(l10n),
      subtitle: section.subtitle(l10n),
      header: header,
      slivers: [
        if (groups.length > 1)
          // Pinned, so categories stay one tap away while scrolling; the
          // group headers pin right under it.
          PinnedHeaderSliver(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: CapsuleRow(
                key: const ValueKey('category-capsules'),
                padding: hPad,
                children: [
                  for (final g in groups.keys)
                    Capsule(
                      key: ValueKey('jump-$g'),
                      label: g,
                      dense: true,
                      selected: _activeGroup == g,
                      semanticsLabel: l10n.sectionJumpTo(g),
                      onTap: () => _jumpTo(g),
                    ),
                ],
              ),
            ),
          ),
        if (async.isLoading && async.value == null)
          SliverPadding(
            padding: hPad,
            sliver: const SliverToBoxAdapter(child: ContentLoading()),
          )
        else if (items.isEmpty)
          SliverPadding(
            padding: EdgeInsets.all(pad),
            sliver: SliverToBoxAdapter(
              child: PlaceholderPanel(
                icon: Icons.inbox_rounded,
                title: l10n.contentEmptySection,
                body: l10n.contentEmptySectionBody,
              ),
            ),
          ),
        for (final g in groups.entries)
          SliverMainAxisGroup(
            slivers: [
              // Non-pinned anchor for jump-to-category.
              SliverToBoxAdapter(child: SizedBox(key: _keyFor(g.key))),
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
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: tone.foreground,
                            borderRadius: AppRadius.fullAll,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            g.key,
                            key: ValueKey('group-${g.key}'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${g.value.length}',
                          style: AppTypography.labelS.copyWith(
                            color: c.textTertiary,
                            fontFeatures: AppTypography.tabular,
                          ),
                        ),
                      ],
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
          padding: EdgeInsetsDirectional.fromSTEB(pad, AppSpacing.xl, pad, 0),
          sliver: const SliverToBoxAdapter(
            child: UnofficialDisclaimer.compact(),
          ),
        ),
      ],
    );
  }
}
