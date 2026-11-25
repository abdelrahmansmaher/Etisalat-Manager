import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/list_surface.dart';
import '../../core/widgets/masthead.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import '../content/package_facts.dart';
import '../content/package_family.dart';
import '../tools/recharge_rule.dart';
import '../tools/tool_routes.dart';

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

    return TabScaffold(
      controller: _scroll,
      scrollKey: const ValueKey('packages-scroll'),
      top: _PackagesTop(title: l10n.navPackages),
      slivers: [
        SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(pad, AppSpacing.sm, pad, 0),
          sliver: SliverToBoxAdapter(
            child: SegmentedCapsule<PackageSegment>(
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
          ),
        ),
        PinnedHeaderSliver(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: CapsuleRow(
              key: const ValueKey('family-capsules'),
              padding: hPad,
              children: [
                _SortButton(
                  sort: _sort,
                  onChanged: (s) => setState(() {
                    _sort = s;
                    _toTop();
                  }),
                ),
                if (families.length > 1) ...[
                  Capsule(
                    key: const ValueKey('family-all'),
                    label: l10n.filterAll,
                    dense: true,
                    selected: family == null,
                    onTap: () => setState(() => _family = null),
                  ),
                  for (final f in families)
                    Capsule(
                      key: ValueKey('family-$f'),
                      label: f,
                      dense: true,
                      selected: family == f,
                      onTap: () => setState(() {
                        _family = family == f ? null : f;
                        _toTop();
                      }),
                    ),
                ],
              ],
            ),
          ),
        ),
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
            sliver: SliverListSurface(
              key: const ValueKey('package-list'),
              itemCount: shown.length,
              itemBuilder: (_, i) => PackageRow(item: shown[i]),
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
    );
  }
}

/// Title and the three tools on one line (wrapping at large text).
class _PackagesTop extends ConsumerWidget {
  const _PackagesTop({required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final calculator = ref.watch(rechargeCalculatorAvailableProvider);
    return Row(
      children: [
        MastheadTitle(title),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CapsuleRow(
              key: const ValueKey('package-tools'),
              spacing: AppSpacing.xs - 2,
              children: [
                _ToolButton(
                  key: const ValueKey('tool-compare'),
                  icon: AppIcons.toolCompare,
                  label: l10n.toolCompareShort,
                  onTap: () => context.push(ToolRoutes.compare),
                ),
                _ToolButton(
                  key: const ValueKey('tool-recommend'),
                  icon: AppIcons.toolRecommend,
                  label: l10n.toolRecommendShort,
                  onTap: () => context.push(ToolRoutes.recommend),
                ),
                if (calculator)
                  _ToolButton(
                    key: const ValueKey('tool-calculator'),
                    icon: AppIcons.toolCalculator,
                    label: l10n.toolCalculatorShort,
                    onTap: () => context.push(ToolRoutes.calculator),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: c.onMasthead.withValues(alpha: 0.10),
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppIconSize.inline, color: c.onMasthead),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    label,
                    style: AppTypography.labelL.copyWith(color: c.onMasthead),
                  ),
                ],
              ),
            ),
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuAnchor(
      menuChildren: [
        for (final s in PackageSort.values)
          MenuItemButton(
            key: ValueKey('sort-${s.name}'),
            leadingIcon: Icon(
              AppIcons.selected,
              size: AppIconSize.action,
              color: s == sort ? context.colors.primary : Colors.transparent,
            ),
            onPressed: () => onChanged(s),
            child: Text(label(l10n, s), style: AppTypography.labelL),
          ),
      ],
      builder: (context, menu, _) => Capsule(
        key: const ValueKey('package-sort'),
        icon: AppIcons.sort,
        label: label(l10n, sort),
        dense: true,
        semanticsLabel: '${l10n.sortTitle}: ${label(l10n, sort)}',
        onTap: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}
