import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'content_widgets.dart';
import 'grouped_items.dart';
import 'package_facts.dart';
import 'section_ui.dart';

/// Usefulness rank of an item type at the counter (lower = earlier).
int usefulnessRank(ItemType t) => switch (t) {
  ItemType.package => 0,
  ItemType.service ||
  ItemType.code ||
  ItemType.contact ||
  ItemType.fee ||
  ItemType.limit ||
  ItemType.procedure => 1,
  ItemType.article || ItemType.faq || ItemType.rule || ItemType.glossary => 2,
  ItemType.unverified => 3,
};

/// Groups [items] by [nameOf] (first-seen order) and orders the groups by
/// the usefulness of their dominant item type: packages first, then
/// services / codes / fees / limits / procedures, then articles / FAQ /
/// rules, and anything unverified last. Ties keep the original order.
/// Inside a group, packages go from cheapest to most expensive.
Map<String, List<ContentItem>> groupByUsefulness(
  List<ContentItem> items,
  String Function(ContentItem) nameOf,
) {
  final groups = <String, List<ContentItem>>{};
  for (final i in items) {
    groups.putIfAbsent(nameOf(i), () => []).add(i);
  }
  int rankOf(List<ContentItem> g) {
    final counts = <int, int>{};
    for (final i in g) {
      final r = usefulnessRank(i.type);
      counts[r] = (counts[r] ?? 0) + 1;
    }
    final best = counts.values.reduce((a, b) => a > b ? a : b);
    return counts.entries
        .where((e) => e.value == best)
        .map((e) => e.key)
        .reduce((a, b) => a < b ? a : b);
  }

  final keys = groups.keys.toList();
  final ranks = {for (final k in keys) k: rankOf(groups[k]!)};
  final order = [...keys.indexed]
    ..sort((a, b) {
      final r = ranks[a.$2]!.compareTo(ranks[b.$2]!);
      return r != 0 ? r : a.$1.compareTo(b.$1);
    });
  return {for (final (_, k) in order) k: sortedByPrice(groups[k]!)};
}

/// Items of one section, grouped by `category_ar`: one surface of dense rows
/// per group and a pinned row of jump capsules.
class SectionScreen extends ConsumerStatefulWidget {
  const SectionScreen({super.key, required this.sectionKey});

  final String sectionKey;

  @override
  ConsumerState<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends ConsumerState<SectionScreen> {
  final _jumper = GroupJumper();
  String? _active;

  @override
  void dispose() {
    _jumper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final section = ContentSection.fromKey(widget.sectionKey);
    final async = ref.watch(contentProvider);
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);

    if (section == null) {
      return PageScaffold(
        title: l10n.detailNotFound,
        children: [
          PlaceholderPanel(
            icon: AppIcons.emptySearch,
            title: l10n.detailNotFound,
            body: l10n.detailNotFoundBody,
          ),
        ],
      );
    }

    final items = async.value?.itemsOf(section) ?? const <ContentItem>[];
    final groups = groupByUsefulness(
      items,
      (i) => i.category.isEmpty ? section.title(l10n) : i.category,
    );

    return PageScaffold(
      scrollKey: const ValueKey('section-scroll'),
      controller: _jumper.scroll,
      title: section.title(l10n),
      slivers: [
        if (async.isLoading && async.value == null)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            sliver: const SliverToBoxAdapter(child: ContentLoading()),
          )
        else if (items.isEmpty)
          SliverPadding(
            padding: EdgeInsets.all(pad),
            sliver: SliverToBoxAdapter(
              child: PlaceholderPanel(
                icon: AppIcons.emptySection,
                title: l10n.contentEmptySection,
                body: l10n.contentEmptySectionBody,
              ),
            ),
          ),
        ...groupedSlivers(
          context,
          groups: groups,
          jumper: _jumper,
          active: _active,
          onJump: (g) {
            setState(() => _active = g);
            _jumper.jumpTo(context, g);
          },
        ),
      ],
    );
  }
}
