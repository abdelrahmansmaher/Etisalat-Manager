import 'package:flutter/material.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/capsules.dart';
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
  final page = Theme.of(context).scaffoldBackgroundColor;
  final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
  final hPad = EdgeInsetsDirectional.symmetric(horizontal: pad);
  return [
    if (groups.length > 1)
      // Pinned, so groups stay one tap away while scrolling; the group
      // headers pin right under it.
      PinnedHeaderSliver(
        child: Container(
          color: page,
          padding: const EdgeInsets.only(top: AppSpacing.xxs),
          child: CapsuleRow(
            key: const ValueKey('category-capsules'),
            padding: hPad,
            children: [
              for (final g in groups.keys)
                Capsule(
                  key: ValueKey('jump-$g'),
                  label: g,
                  dense: true,
                  selected: active == g,
                  semanticsLabel: l10n.sectionJumpTo(g),
                  onTap: () => onJump(g),
                ),
            ],
          ),
        ),
      ),
    for (final g in groups.entries)
      SliverMainAxisGroup(
        slivers: [
          // Non-pinned anchor for jumps.
          SliverToBoxAdapter(child: SizedBox(key: jumper.keyFor(g.key))),
          PinnedHeaderSliver(
            child: Container(
              color: page,
              padding: hPad,
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
