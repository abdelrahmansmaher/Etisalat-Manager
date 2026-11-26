import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/choice_sheet.dart';
import '../../core/widgets/glass_menu.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/list_surface.dart';
import '../../core/widgets/masthead.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import '../content/package_facts.dart';
import '../content/package_family.dart';

/// Packages tab: every package of one segment as a rate card, cheapest
/// first. Family capsules filter, the sort button reorders; compare,
/// recommend and the calculator open from the masthead.
class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key, this.segment});

  /// Comes from the route (`/packages?s=home`), so Home can open a segment.
  final PackageSegment? segment;

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  final _scroll = ScrollController();
  PackageSort _sort = PackageSort.priceUp;
  String? _family;

  PackageSegment get _segment => widget.segment ?? PackageSegment.mobile;

  @override
  void didUpdateWidget(PackagesScreen old) {
    super.didUpdateWidget(old);
    if (old.segment != widget.segment) {
      _family = null;
      _toTop();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(contentProvider);
    final library = ref.watch(contentLibraryProvider);
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final hPad = EdgeInsetsDirectional.symmetric(horizontal: pad);

    final all = [
      ...library.itemsOf(ContentSection.packages),
      ...library.itemsOf(ContentSection.internet),
    ].where((i) => PackageSegment.of(i) == _segment);
    final packages = [
      for (final i in all)
        if (i.type == ItemType.package) i,
    ];
    final families = {for (final i in packages) familyOf(i)}.toList();
    final family = families.contains(_family) ? _family : null;
    final shown = sortedPackages([
      for (final i in packages)
        if (family == null || familyOf(i) == family) i,
    ], _sort);
    // Rules, codes and answers that belong to these packages.
    final info = [
      for (final i in all)
        if (i.type != ItemType.package &&
            (family == null || familyOf(i) == family))
          i,
    ];

    // A sideways swipe moves between the segments of this page (the dock
    // tabs never change by swiping).
    void swipe(DragEndDetails d) {
      final v = d.primaryVelocity ?? 0;
      if (v.abs() < 350) return;
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final next = rtl ? v > 0 : v < 0;
      final all = PackageSegment.values;
      final i = all.indexOf(_segment) + (next ? 1 : -1);
      if (i < 0 || i >= all.length) return;
      HapticFeedback.selectionClick();
      context.go(AppRoutes.packagesSegment(all[i].name));
    }

    return GestureDetector(
      onHorizontalDragEnd: swipe,
      child: TabScaffold(
        controller: _scroll,
        scrollKey: const ValueKey('packages-scroll'),
        // Segment and families stay in the glass header while the list
        // scrolls under it.
        headerBottom: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedCapsule<PackageSegment>(
              key: const ValueKey('package-segments'),
              selected: _segment,
              onChanged: (s) => context.go(AppRoutes.packagesSegment(s.name)),
              segments: [
                for (final s in PackageSegment.values)
                  CapsuleSegment(
                    key: ValueKey('segment-${s.name}'),
                    value: s,
                    label: switch (s) {
                      PackageSegment.mobile => l10n.segmentMobile,
                      PackageSegment.mobileInternet =>
                        l10n.segmentMobileInternet,
                      PackageSegment.home => l10n.segmentHome,
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            // One filter button instead of a long row of families.
            Row(
              key: const ValueKey('family-capsules'),
              children: [
                if (families.length > 1)
                  Expanded(
                    child: Builder(
                      builder: (menuAnchor) => FilterPill(
                        expand: true,
                        key: const ValueKey('family-filter'),
                        label: family ?? l10n.filterFamiliesAll,
                        count: family == null ? null : shown.length,
                        active: family != null,
                        onTap: () async {
                          final counts = <String, int>{};
                          for (final p in packages) {
                            counts.update(
                              familyOf(p),
                              (n) => n + 1,
                              ifAbsent: () => 1,
                            );
                          }
                          final picked = await showGlassMenu<String>(
                            menuAnchor,
                            selected: family ?? '',
                            items: [
                              GlassMenuItem(
                                key: const ValueKey('family-all'),
                                value: '',
                                label: l10n.filterAll,
                                count: packages.length,
                                icon: AppIcons.layers,
                              ),
                              for (final f in families)
                                GlassMenuItem(
                                  key: ValueKey('family-$f'),
                                  value: f,
                                  label: f,
                                  count: counts[f],
                                  leading: FamilyTile(f),
                                ),
                            ],
                          );
                          if (picked == null || !mounted) return;
                          setState(() {
                            _family = picked.isEmpty ? null : picked;
                            _toTop();
                          });
                        },
                      ),
                    ),
                  ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _SortButton(
                    sort: _sort,
                    onChanged: (s) => setState(() {
                      _sort = s;
                      _toTop();
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
        slivers: [
          if (async.isLoading && async.value == null)
            SliverPadding(
              padding: hPad,
              sliver: const SliverToBoxAdapter(child: ContentLoading()),
            )
          else if (shown.isEmpty && info.isEmpty)
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
          if (shown.isNotEmpty)
            SliverPadding(
              padding: hPad,
              // Every package is a card of its own.
              sliver: SliverList.separated(
                key: const ValueKey('package-list'),
                itemCount: shown.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (_, i) => Entrance(
                  index: i,
                  child: AppCard(
                    role: CardRole.flat,
                    padding: EdgeInsets.zero,
                    child: PackageRow(item: shown[i]),
                  ),
                ),
              ),
            ),
          if (info.isNotEmpty) ...[
            SliverPadding(
              padding: hPad,
              sliver: SliverToBoxAdapter(
                child: GroupHeader(l10n.packagesInfoTitle, count: info.length),
              ),
            ),
            SliverPadding(
              padding: hPad,
              sliver: SliverListSurface(
                itemCount: info.length,
                itemBuilder: (_, i) => ContentItemRow(item: info[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Current order; opens a menu with the three choices.
class _SortButton extends StatelessWidget {
  const _SortButton({required this.sort, required this.onChanged});

  final PackageSort sort;
  final ValueChanged<PackageSort> onChanged;

  static String label(AppLocalizations l10n, PackageSort s) => switch (s) {
    PackageSort.priceUp => l10n.sortPriceUp,
    PackageSort.priceDown => l10n.sortPriceDown,
    PackageSort.quota => l10n.sortQuota,
  };

  static IconData iconOf(PackageSort s) => switch (s) {
    PackageSort.priceUp => AppIcons.sortPriceUp,
    PackageSort.priceDown => AppIcons.sortPriceDown,
    PackageSort.quota => AppIcons.sortQuota,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Builder(
      builder: (anchor) => FilterPill(
        key: const ValueKey('package-sort'),
        expand: true,
        icon: AppIcons.sort,
        label: label(l10n, sort),
        semanticsLabel: '${l10n.sortTitle}: ${label(l10n, sort)}',
        onTap: () async {
          final picked = await showGlassMenu<PackageSort>(
            anchor,
            selected: sort,
            items: [
              for (final s in PackageSort.values)
                GlassMenuItem(
                  key: ValueKey('sort-${s.name}'),
                  value: s,
                  label: label(l10n, s),
                  icon: iconOf(s),
                  hue: (s == PackageSort.quota ? Hue.blue : Hue.gold).of(c),
                ),
            ],
          );
          if (picked != null && picked != sort) onChanged(picked);
        },
      ),
    );
  }
}
