import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/router/search_focus.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_identity.dart';
import '../../l10n/app_localizations.dart';
import '../encyclopedia/encyclopedia_sections.dart';

/// Home placeholder (doc 04 §5.1): hero (greeting + search pill) and the
/// encyclopedia grid. Latest updates / favourites / recents arrive with data.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.now});

  /// Injectable clock for the greeting (tests).
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final pad = AppSpacing.screenPaddingFor(width);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          bottom: AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _Hero(now: now),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(pad, AppSpacing.xl, pad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  l10n.homeSectionsTitle,
                  subtitle: l10n.homeSectionsSubtitle,
                ),
                const SizedBox(height: AppSpacing.md),
                const _SectionGrid(),
                const SizedBox(height: AppSpacing.xxl),
                const UnofficialDisclaimer.compact(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({this.now});

  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final hour = (now ?? DateTime.now()).hour;
    final greeting = hour < 12 ? l10n.greetingMorning : l10n.greetingEvening;
    final width = MediaQuery.sizeOf(context).width;
    final pad = AppSpacing.screenPaddingFor(width);

    // Static gradient: painted once, no animation, no blur (cheap).
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.heroGradientStart, c.heroGradientEnd],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            pad,
            AppSpacing.xl,
            pad,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TintedIcon(
                    Icons.auto_stories_rounded,
                    size: 36,
                    background: c.surfaceElevated,
                    color: c.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      AppIdentity.of(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(greeting, style: theme.textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.homeHeroSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SearchPill(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large pill "search field" that jumps to the Search tab with the keyboard
/// open (doc 04 §5.1 item 2).
class _SearchPill extends ConsumerWidget {
  const _SearchPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;

    return Semantics(
      button: true,
      textField: true,
      label: l10n.homeSearchHint,
      excludeSemantics: true,
      child: PressableScale(
        pressedScale: 0.98,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            boxShadow: AppShadows.raised(c),
          ),
          child: Material(
            key: const ValueKey('home-search-pill'),
            color: c.surfaceElevated,
            shape: StadiumBorder(side: BorderSide(color: c.hairline)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                ref.read(searchFocusRequestProvider.notifier).request();
                context.go(AppRoutes.search);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: c.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.homeSearchHint,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-column grid (four on wide screens) built with Wrap so tiles grow with
/// text scale instead of overflowing fixed cells.
class _SectionGrid extends StatelessWidget {
  const _SectionGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        const gap = AppSpacing.cardGap;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final s in EncyclopediaSection.values)
              SizedBox(
                width: tileWidth,
                child: StaggeredFadeIn(
                  index: s.index,
                  child: SectionCard(section: s),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Elegant section card: tinted rounded-square icon, title, one-line subtitle.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.section});

  final EncyclopediaSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final title = section.title(l10n);
    final subtitle = section.subtitle(l10n);

    return AppCard(
      semanticLabel: '$title، $subtitle',
      onTap: () => context.go(AppRoutes.browse),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TintedIcon(section.icon),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}
