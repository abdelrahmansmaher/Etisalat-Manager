import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/masthead.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import '../content/grouped_items.dart';

/// Hotlines first, then every code by group (wallet codes included), then
/// the notes of the numbers section.
Map<String, List<ContentItem>> codeGroups(
  ContentLibrary library, {
  required String hotlines,
  required String notes,
}) {
  final out = <String, List<ContentItem>>{hotlines: []};
  final rest = <ContentItem>[];
  for (final i in library.itemsOf(ContentSection.numbers)) {
    if (i.type == ItemType.contact && i.phones.isNotEmpty) {
      out[hotlines]!.add(i);
    } else if (i.type == ItemType.code && leadCode(i) != null) {
      out.putIfAbsent(i.category, () => []).add(i);
    } else {
      rest.add(i);
    }
  }
  for (final i in library.itemsOf(ContentSection.wallet)) {
    if (i.type == ItemType.code && leadCode(i) != null) {
      out.putIfAbsent(i.category, () => []).add(i);
    }
  }
  if (rest.isNotEmpty) out[notes] = rest;
  out.removeWhere((_, v) => v.isEmpty);
  return out;
}

/// "Codes and numbers" tab: every row has the whole value, dial and copy.
class CodesScreen extends ConsumerStatefulWidget {
  const CodesScreen({super.key});

  @override
  ConsumerState<CodesScreen> createState() => _CodesScreenState();
}

class _CodesScreenState extends ConsumerState<CodesScreen> {
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
    final async = ref.watch(contentProvider);
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final groups = codeGroups(
      ref.watch(contentLibraryProvider),
      hotlines: l10n.hotlinesTitle,
      notes: l10n.codesNotesTitle,
    );
    return TabScaffold(
      controller: _jumper.scroll,
      scrollKey: const ValueKey('codes-scroll'),
      slivers: [
        if (async.isLoading && async.value == null)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            sliver: const SliverToBoxAdapter(child: ContentLoading()),
          )
        else if (groups.isEmpty)
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
