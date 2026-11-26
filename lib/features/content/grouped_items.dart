import 'package:flutter/material.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/choice_sheet.dart';
import '../../core/widgets/list_surface.dart';
import '../../l10n/app_localizations.dart';
import 'content_widgets.dart';

/// Scrolls a lazily built grouped list to a group's header.
class GroupJumper {
  final ScrollController scroll = ScrollController();
  final Map<String, GlobalKey> _keys = {};

  GlobalKey keyFor(String group) =>
      _keys.putIfAbsent(group, () => GlobalKey(debugLabel: group));

  void dispose() => scroll.dispose();

  /// Scrolls until the header of [group] exists, then aligns it to the top.
  Future<void> jumpTo(BuildContext context, String group) async {
    final key = keyFor(group);
    if (!scroll.hasClients) return;
    final duration = AppMotion.resolve(context, AppMotion.emphasized);
    if (key.currentContext == null) {
      scroll.jumpTo(0);
      await WidgetsBinding.instance.endOfFrame;
      for (var i = 0; i < 60 && key.currentContext == null; i++) {
        if (!scroll.hasClients) return;
        final p = scroll.position;
        if (p.pixels >= p.maxScrollExtent) break;
        scroll.jumpTo(
          (p.pixels + p.viewportDimension * 0.8).clamp(0, p.maxScrollExtent),
        );
        await WidgetsBinding.instance.endOfFrame;
      }
    }
    final target = key.currentContext;
    if (target == null || !target.mounted) return;
    await Scrollable.ensureVisible(
      target,
      duration: duration,
      curve: AppMotion.enter,
    );
  }
}

/// Pinned row of jump capsules plus one surface of dense rows per group.
List<Widget> groupedSlivers(
  BuildContext context, {
  required Map<String, List<ContentItem>> groups,
  required GroupJumper jumper,
  required String? active,
  required ValueChanged<String> onJump,
}) {
  final l10n = AppLocalizations.of(context);
  final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
  final hPad = EdgeInsetsDirectional.symmetric(horizontal: pad);
  return [
    if (groups.length > 1)
      // One "groups" button, pinned, instead of a long row of capsules.
      PinnedHeaderSliver(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(pad, AppSpacing.xxs, pad, 0),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilterPill(
              key: const ValueKey('category-capsules'),
              floating: true,
              icon: AppIcons.jump,
              label: active ?? l10n.jumpPill,
              count: groups.length,
              onTap: () async {
                final g = await showChoiceSheet<String>(
                  context,
                  title: l10n.jumpTitle,
                  selected: active,
                  choices: [
                    for (final e in groups.entries)
                      Choice(
                        key: ValueKey('jump-${e.key}'),
                        value: e.key,
                        label: e.key,
                        count: e.value.length,
                      ),
                  ],
                );
                if (g != null && context.mounted) onJump(g);
              },
            ),
          ),
        ),
      ),
    for (final g in groups.entries)
      SliverMainAxisGroup(
        slivers: [
          // Non-pinned anchor for jumps.
          SliverToBoxAdapter(child: SizedBox(key: jumper.keyFor(g.key))),
          SliverPadding(
            padding: hPad,
            sliver: SliverToBoxAdapter(
              child: GroupHeader(g.key, count: g.value.length),
            ),
          ),
          SliverPadding(
            padding: hPad,
            sliver: SliverListSurface(
              itemCount: g.value.length,
              itemBuilder: (_, i) => ContentItemRow(item: g.value[i]),
            ),
          ),
        ],
      ),
  ];
}
