import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/settings/history.dart';
import '../../core/theme/theme.dart';
import '../../core/user/user.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_mark.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/masthead.dart';
import '../../core/widgets/sim_shape.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_identity.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_provider.dart';
import '../content/content_widgets.dart';
import '../content/section_ui.dart';
import '../tools/recharge_rule.dart';
import '../tools/tool_routes.dart';
import '../tools/tool_widgets.dart';

/// "More" tab: the app card with what the database holds, the tools as a
/// grid of tiles, the other sections, and appearance and language.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(contentLibraryProvider);
    final calculator = ref.watch(rechargeCalculatorAvailableProvider);

    final tools = <_Tile>[
      (
        'training',
        AppIcons.training,
        l10n.trainingTitle,
        l10n.moreTrainingSub,
        ToolRoutes.training,
        7,
      ),
      (
        'recommend',
        AppIcons.toolRecommend,
        l10n.toolsRecommendTitle,
        l10n.moreRecommendSub,
        ToolRoutes.recommend,
        2,
      ),
      (
        'compare',
        AppIcons.toolCompare,
        l10n.toolsCompareTitle,
        l10n.moreCompareSub,
        ToolRoutes.compare,
        1,
      ),
      if (calculator)
        (
          'calculator',
          AppIcons.toolCalculator,
          l10n.toolsCalcTitle,
          l10n.moreCalculatorSub,
          ToolRoutes.calculator,
          5,
        ),
      (
        'favorites',
        AppIcons.toolFavorite,
        l10n.toolsFavoritesTitle,
        l10n.moreFavoritesSub,
        ToolRoutes.favorites,
        3,
      ),
      (
        'notes',
        AppIcons.toolNotes,
        l10n.moreNotes,
        l10n.moreNotesSub,
        ToolRoutes.notes,
        6,
      ),
      (
        'editor',
        AppIcons.toolEdits,
        l10n.moreEditor,
        l10n.moreEditorSub,
        ToolRoutes.editor,
        4,
      ),
      (
        'whats-new',
        AppIcons.toolWhatsNew,
        l10n.moreWhatsNew,
        l10n.moreWhatsNewSub,
        ToolRoutes.whatsNew,
        0,
      ),
    ];
    final sections = [
      for (final (i, s) in const [
        ContentSection.procedures,
        ContentSection.wallet,
        ContentSection.glossary,
        ContentSection.company,
      ].indexed)
        (
          s.key,
          s.icon,
          s.title(l10n),
          l10n.moreItemsCount(library.itemsOf(s).length),
          ContentRoutes.section(s.key),
          [0, 5, 2, 4][i],
        ),
    ];

    return TabScaffold(
      scrollKey: const ValueKey('more-scroll'),
      children: [
        const _AppCard(),
        GroupHeader(l10n.moreToolsTitle, icon: AppIcons.toolRecommend),
        _TileGrid(tiles: tools),
        GroupHeader(l10n.homeSectionsTitle, icon: AppIcons.layers),
        _TileGrid(tiles: sections),
        GroupHeader(l10n.moreSettingsTitle, icon: AppIcons.appearance),
        const _Settings(),
      ],
    );
  }
}

/// A tool or a section: key, icon, title, one line, route, palette hue.
typedef _Tile = (String, IconData, String, String, String, int);

class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.tiles});

  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      const gap = AppSpacing.xs;
      final columns = box.maxWidth >= 600 ? 3 : 2;
      final w = (box.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final t in tiles)
            SizedBox(
              width: w,
              child: _ToolTile(tile: t),
            ),
        ],
      );
    },
  );
}

/// Glass tile: a coloured icon squircle, the name and what it is for.
class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tile});

  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (key, icon, title, sub, route, hue) = tile;
    return AppCard(
      key: ValueKey('more-$key'),
      role: CardRole.flat,
      semanticLabel: title,
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: () => context.push(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Same colour as the tool everywhere (home, its page).
          TintedIcon(icon, tile: IconTile.md),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 2,
            style: AppTypography.titleS.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 2,
            style: AppTypography.bodyS.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The app on a navy glass card: its mark, its name, how much it holds and
/// what was checked on the official site, and clearing the history.
class _AppCard extends ConsumerWidget {
  const _AppCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final library = ref.watch(contentLibraryProvider);
    final official = library.all.where((i) => i.officiallyVerified).length;
    final edits = ref.watch(overridesProvider).length;
    final asOf = library.latestAsOf;
    final hasHistory =
        ref.watch(recentItemsProvider).isNotEmpty ||
        ref.watch(recentSearchesProvider).isNotEmpty;

    Widget stat(String key, int n, String label, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: AppRadius.smAll,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text(
              '$n',
              key: ValueKey('stat-$key'),
              style: AppTypography.headlineM.copyWith(
                color: color,
                fontFeatures: AppTypography.tabular,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelS.copyWith(color: c.onMastheadMuted),
            ),
          ],
        ),
      ),
    );

    return Container(
      key: const ValueKey('content-stats'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: simGlassDecoration(c, cut: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppMark(size: 52),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppIdentity.of(context),
                      style: AppTypography.titleL.copyWith(
                        color: c.onMasthead,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (asOf != null)
                      Text(
                        l10n.contentAsOf(
                          TrustFormat.date(
                            asOf,
                            Localizations.localeOf(context),
                          ),
                        ),
                        style: AppTypography.bodyS.copyWith(
                          color: c.onMastheadMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              stat('items', library.length, l10n.moreStatItems, c.onMasthead),
              const SizedBox(width: AppSpacing.xs),
              stat(
                'official',
                official,
                l10n.moreStatOfficial,
                const Color(0xFF7BE3B4),
              ),
              const SizedBox(width: AppSpacing.xs),
              stat('edits', edits, l10n.editorMyEdits, const Color(0xFF9DB8FF)),
            ],
          ),
          if (hasHistory) ...[
            const SizedBox(height: AppSpacing.xs),
            TextButton.icon(
              key: const ValueKey('clear-history'),
              style: TextButton.styleFrom(foregroundColor: c.onMasthead),
              onPressed: () {
                ref.read(recentItemsProvider.notifier).clear();
                ref.read(recentSearchesProvider.notifier).clear();
                showToolMessage(context, l10n.moreHistoryCleared);
              },
              icon: const Icon(AppIcons.history, size: AppIconSize.action),
              label: Text(l10n.moreClearHistory),
            ),
          ],
        ],
      ),
    );
  }
}

/// Appearance and language, grouped like iOS settings.
class _Settings extends ConsumerWidget {
  const _Settings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    Widget label(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          TintedIcon(icon, tile: IconTile.xs),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              text,
              style: AppTypography.titleS.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    return AppCard(
      role: CardRole.flat,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label(AppIcons.themeSystem, l10n.settingsAppearance),
          SegmentedCapsule<ThemeMode>(
            key: const ValueKey('theme-segments'),
            selected: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).setMode(m),
            segments: [
              CapsuleSegment(
                key: const ValueKey('theme-system'),
                value: ThemeMode.system,
                label: l10n.themeSystem,
                icon: AppIcons.themeSystem,
              ),
              CapsuleSegment(
                key: const ValueKey('theme-light'),
                value: ThemeMode.light,
                label: l10n.themeLight,
                icon: AppIcons.themeLight,
              ),
              CapsuleSegment(
                key: const ValueKey('theme-dark'),
                value: ThemeMode.dark,
                label: l10n.themeDark,
                icon: AppIcons.themeDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: c.hairline),
          const SizedBox(height: AppSpacing.md),
          label(AppIcons.language, l10n.settingsLanguage),
          SegmentedCapsule<String>(
            key: const ValueKey('lang-segments'),
            selected: locale?.languageCode ?? 'system',
            onChanged: (code) => ref
                .read(localeProvider.notifier)
                .setLocale(code == 'system' ? null : Locale(code)),
            segments: [
              CapsuleSegment(
                key: const ValueKey('lang-system'),
                value: 'system',
                label: l10n.languageSystem,
              ),
              CapsuleSegment(
                key: const ValueKey('lang-ar'),
                value: 'ar',
                label: l10n.languageArabic,
              ),
              CapsuleSegment(
                key: const ValueKey('lang-en'),
                value: 'en',
                label: l10n.languageEnglish,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
