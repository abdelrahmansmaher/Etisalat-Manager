import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../export/export_sheet.dart';
import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'content_widgets.dart';
import 'grouped_items.dart';
import 'package_facts.dart';
import 'section_ui.dart';

/// Groups [items] by [nameOf] in file order: the content files are already
/// ordered from most to least used at the counter. Only groups of unverified
/// items are moved to the end. Inside a group, packages go from cheapest to
/// most expensive.
Map<String, List<ContentItem>> groupInOrder(
  List<ContentItem> items,
  String Function(ContentItem) nameOf,
) {
  final groups = <String, List<ContentItem>>{};
  for (final i in items) {
    groups.putIfAbsent(nameOf(i), () => []).add(i);
  }
  bool isLast(List<ContentItem> g) =>
      g.every((i) => i.type == ItemType.unverified);
  return {
    for (final e in groups.entries)
      if (!isLast(e.value)) e.key: sortedByPrice(e.value),
    for (final e in groups.entries)
      if (isLast(e.value)) e.key: e.value,
  };
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
    final groups = groupInOrder(
      items,
      (i) => i.category.isEmpty ? section.title(l10n) : i.category,
    );

    return PageScaffold(
      scrollKey: const ValueKey('section-scroll'),
      controller: _jumper.scroll,
      title: section.title(l10n),
      actions: [
        if (items.isNotEmpty)
          ExportButton(
            title: section.title(l10n),
            pdf: (pdf) => pdf.list(section.title(l10n), items),
          ),
      ],
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
