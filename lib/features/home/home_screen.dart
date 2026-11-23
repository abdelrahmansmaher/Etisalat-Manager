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
import '../../core/content/content.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/trust/trust_format.dart';
import '../content/section_ui.dart';

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
                const _MustKnowStrip(),
                const SizedBox(height: AppSpacing.xxl),
                const _AsOfNote(),
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
class _SectionGrid extends ConsumerWidget {
  const _SectionGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(contentLibraryProvider);
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
            for (final s in ContentSection.values)
              SizedBox(
                width: tileWidth,
                child: StaggeredFadeIn(
                  index: s.index,
                  child: SectionCard(
                    section: s,
                    count: library.itemsOf(s).length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Section card: tinted icon, title, two-line subtitle, item count.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.section, this.count = 0});

  final ContentSection section;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final title = section.title(l10n);
    final subtitle = section.subtitle(l10n);
    final countText = l10n.itemCount(count);

    return AppCard(
      key: ValueKey('section-card-${section.key}'),
      semanticLabel: '$title، $subtitle، $countText',
      onTap: () => context.push(ContentRoutes.section(section.key)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TintedIcon(section.icon),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            countText,
            style: AppTypography.labelS.copyWith(color: c.primary),
          ),
        ],
      ),
    );
  }
}

/// "Numbers to know by heart": top contact items from numbers.json.
class _MustKnowStrip extends ConsumerWidget {
  const _MustKnowStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final contacts = ref
        .watch(sectionItemsProvider(ContentSection.numbers))
        .where((i) => i.type == ItemType.contact && i.phones.isNotEmpty)
        .take(8)
        .toList();
    if (contacts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(l10n.homeMustKnowTitle),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            key: const ValueKey('must-know-strip'),
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in contacts) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 140,
                      maxWidth: 200,
                    ),
                    child: AppCard(
                      key: ValueKey('must-know-${item.id}'),
                      semanticLabel: '${item.title}، ${item.phones.first}',
                      onTap: () => context.push(ContentRoutes.item(item.id)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LtrText(
                            item.phones.first,
                            style: AppTypography.price.copyWith(
                              color: c.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.cardGap),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Content last updated" from the newest `as_of`.
class _AsOfNote extends ConsumerWidget {
  const _AsOfNote();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asOf = ref.watch(contentLibraryProvider).latestAsOf;
    if (asOf == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Text(
        l10n.contentAsOf(
          TrustFormat.date(asOf, Localizations.localeOf(context)),
        ),
        key: const ValueKey('content-as-of'),
        textAlign: TextAlign.center,
        style: AppTypography.labelS.copyWith(color: c.textTertiary),
      ),
    );
  }
}
