import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/settings/history.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/list_surface.dart';
import '../../core/widgets/masthead.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import '../content/package_family.dart';
import '../content/section_ui.dart';
import '../tools/recharge_rule.dart';
import '../tools/tool_routes.dart';
import '../tools/whats_new.dart';

/// Home: quick counter tools, favourites, the most-used hotlines and codes,
/// last opened items and a compact grid of sections.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.now});

  /// Injectable clock for the greeting (tests).
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      scrollKey: const ValueKey('home-scroll'),
      top: _Greeting(now: now),
      children: const [
        _WhatsNewBanner(),
        _QuickToolsStrip(),
        _Favorites(),
        _MustKnow(),
        _Recent(),
        _SectionGrid(),
        _AsOfNote(),
      ],
    );
  }
}

class _WhatsNewBanner extends ConsumerWidget {
  const _WhatsNewBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unseen = ref.watch(whatsNewUnseenProvider);
    if (!unseen) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: AppCard(
        key: const ValueKey('whats-new-banner'),
        role: CardRole.flat,
        color: c.primaryContainer,
        borderColor: c.primary.withValues(alpha: 0.25),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        onTap: () => context.push(ToolRoutes.whatsNew),
        child: Row(
          children: [
            Icon(
              AppIcons.toolWhatsNew,
              size: AppIconSize.action,
              color: c.onPrimaryContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.toolsWhatsNewBanner,
                style: AppTypography.labelL.copyWith(
                  color: c.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              AppIcons.chevron,
              size: AppIconSize.action,
              color: c.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickToolsStrip extends ConsumerWidget {
  const _QuickToolsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final calculator = ref.watch(rechargeCalculatorAvailableProvider);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: CapsuleRow(
        key: const ValueKey('home-quick-tools'),
        children: [
          Capsule(
            key: const ValueKey('home-tool-recommend'),
            icon: AppIcons.toolRecommend,
            label: l10n.toolRecommendShort,
            onTap: () => context.push(ToolRoutes.recommend),
          ),
          Capsule(
            key: const ValueKey('home-tool-compare'),
            icon: AppIcons.toolCompare,
            label: l10n.toolCompareShort,
            onTap: () => context.push(ToolRoutes.compare),
          ),
          if (calculator)
            Capsule(
              key: const ValueKey('home-tool-calculator'),
              icon: AppIcons.toolCalculator,
              label: l10n.toolCalculatorShort,
              onTap: () => context.push(ToolRoutes.calculator),
            ),
          Capsule(
            key: const ValueKey('home-tool-training'),
            icon: AppIcons.training,
            label: l10n.trainingTitle,
            onTap: () => context.push(ToolRoutes.training),
          ),
        ],
      ),
    );
  }
}

/// Greeting and date on one line.
class _Greeting extends StatelessWidget {
  const _Greeting({this.now});

  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = now ?? DateTime.now();
    final lang = Localizations.localeOf(context).languageCode;
    final dateText = (DateFormat(
      lang == 'ar' ? 'EEEE، d MMMM' : 'EEEE, d MMMM',
      lang,
    )..useNativeDigits = false).format(date);
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          MastheadTitle(
            date.hour < 12 ? l10n.greetingMorning : l10n.greetingEvening,
          ),
          Text(
            dateText,
            key: const ValueKey('home-date'),
            style: AppTypography.labelL.copyWith(
              color: context.colors.onHeaderMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Favorites extends ConsumerWidget {
  const _Favorites();

  static const _shown = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(favoriteItemsProvider);
    return Column(
      key: const ValueKey('home-favorites'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupHeader(
          l10n.favoritesTitle,
          trailing: items.length <= _shown
              ? null
              : _HeaderLink(
                  l10n.showAllCount(items.length),
                  onTap: () => context.push(ToolRoutes.favorites),
                ),
        ),
        if (items.isEmpty)
          AppCard(
            role: CardRole.flat,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                TintedIcon(AppIcons.toolFavoriteOff, tile: IconTile.sm),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.favoritesEmpty,
                    key: const ValueKey('favorites-empty'),
                    style: AppTypography.bodyM.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ListSurface(
            children: [
              for (final i in items.take(_shown)) ContentItemRow(item: i),
            ],
          ),
      ],
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: AppRadius.smAll,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      child: Text(
        label,
        style: AppTypography.labelL.copyWith(color: context.colors.primary),
      ),
    ),
  );
}

/// Hotlines and codes asked for most, in full, with dial and copy.
class _MustKnow extends ConsumerWidget {
  const _MustKnow();

  /// Codes the branch dials most; shown in this order when the content has
  /// them, then whatever confirmed code comes next.
  static const _preferredCodes = ['*838#', '*566#', '*947#', '*911#'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(sectionItemsProvider(ContentSection.numbers));
    bool trusted(ContentItem i) =>
        i.status == ItemStatus.confirmed || i.userEdited;

    final contacts = items
        .where(
          (i) =>
              i.type == ItemType.contact && i.phones.isNotEmpty && trusted(i),
        )
        .take(3);
    final codes = [
      for (final i in items)
        if (i.type == ItemType.code && i.codes.isNotEmpty && trusted(i)) i,
    ];
    int rank(ContentItem i) {
      final r = _preferredCodes.indexOf(i.codes.first);
      return r < 0 ? _preferredCodes.length : r;
    }

    final ordered = [...codes.indexed]
      ..sort((a, b) {
        final r = rank(a.$2).compareTo(rank(b.$2));
        return r != 0 ? r : a.$1.compareTo(b.$1);
      });
    // One row per code: items that share a code do not repeat it.
    final seen = <String>{};
    final rows = [
      for (final i in contacts) (i, i.phones.first),
      for (final (_, i)
          in ordered.where((e) => seen.add(e.$2.codes.first)).take(4))
        (i, i.codes.first),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const ValueKey('must-know-strip'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupHeader(
          l10n.homeMustKnowTitle,
          trailing: _HeaderLink(
            l10n.showAll,
            onTap: () => context.go(AppRoutes.codes),
          ),
        ),
        ListSurface(
          children: [
            for (final (item, value) in rows)
              KeyedSubtree(
                key: ValueKey('must-know-${item.id}'),
                child: CodeRow(item: item, value: value),
              ),
          ],
        ),
      ],
    );
  }
}

/// Last opened items (persisted locally when available).
class _Recent extends ConsumerWidget {
  const _Recent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(contentLibraryProvider);
    final items = [
      for (final id in ref.watch(recentItemsProvider)) ?library.byId(id),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupHeader(l10n.homeRecentTitle),
        CapsuleRow(
          key: const ValueKey('recent-strip'),
          children: [
            for (final i in items)
              Capsule(
                key: ValueKey('recent-${i.id}'),
                label: i.title,
                onTap: () => context.push(ContentRoutes.item(i.id)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Compact grid of sections: four per row, fewer at large text sizes.
class _SectionGrid extends ConsumerWidget {
  const _SectionGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(contentLibraryProvider);
    final tiles = [
      for (final s in ContentSection.values)
        _SectionTile(
          key: ValueKey('section-card-${s.key}'),
          icon: s.icon,
          label: s.title(l10n),
          count: library.itemsOf(s).length,
          onTap: () => switch (s) {
            ContentSection.packages => context.go(
              AppRoutes.packagesSegment(PackageSegment.mobile.name),
            ),
            ContentSection.internet => context.go(
              AppRoutes.packagesSegment(PackageSegment.mobileInternet.name),
            ),
            ContentSection.numbers => context.go(AppRoutes.codes),
            _ => context.push(ContentRoutes.section(s.key)),
          },
        ),
      _SectionTile(
        key: const ValueKey('section-card-training'),
        icon: AppIcons.training,
        label: l10n.trainingTitle,
        onTap: () => context.push(ToolRoutes.training),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupHeader(l10n.homeSectionsTitle),
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(1);
            final columns = constraints.maxWidth >= 720
                ? 8
                : scale > 1.6
                ? 2
                : scale > 1.15
                ? 3
                : 4;
            const gap = AppSpacing.xs;
            return Column(
              children: [
                for (var r = 0; r < tiles.length; r += columns) ...[
                  if (r > 0) const SizedBox(height: gap),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = r; i < r + columns; i++) ...[
                          if (i > r) const SizedBox(width: gap),
                          Expanded(
                            child: i < tiles.length
                                ? tiles[i]
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      role: CardRole.flat,
      semanticLabel: label,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TintedIcon(icon, tile: IconTile.sm),
          const SizedBox(height: AppSpacing.xxs + 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelS.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(height: 2),
            Text(
              '$count',
              style: AppTypography.labelS.copyWith(
                color: c.textTertiary,
                fontFeatures: AppTypography.tabular,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Content last updated" from the newest `as_of`; opens what changed.
class _AsOfNote extends ConsumerWidget {
  const _AsOfNote();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asOf = ref.watch(contentLibraryProvider).latestAsOf;
    if (asOf == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () => context.push(ToolRoutes.whatsNew),
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          l10n.contentAsOf(
            TrustFormat.date(asOf, Localizations.localeOf(context)),
          ),
          key: const ValueKey('content-as-of'),
          textAlign: TextAlign.center,
          style: AppTypography.labelS.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
