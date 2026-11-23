import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/router/search_focus.dart';
import '../../core/settings/history.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/prose_text.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../core/widgets/trust/trust_format.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_identity.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import '../content/section_ui.dart';

/// Home (doc 04 §5.1): hero (greeting, date, big search), quick-access
/// capsules (sections, hotlines & codes), recently opened, section grid.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.now});

  /// Injectable clock for the greeting (tests).
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final pad = AppSpacing.screenPaddingFor(width);
    final hPad = EdgeInsetsDirectional.symmetric(horizontal: pad);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          bottom: AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _Hero(now: now),
          const SizedBox(height: AppSpacing.lg),
          _QuickAccess(padding: hPad),
          const _MustKnowStrip(),
          const _RecentStrip(),
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
    final date = now ?? DateTime.now();
    final greeting = date.hour < 12
        ? l10n.greetingMorning
        : l10n.greetingEvening;
    final lang = Localizations.localeOf(context).languageCode;
    final dateText = (DateFormat(
      lang == 'ar' ? 'EEEE، d MMMM y' : 'EEEE, d MMMM y',
      lang,
    )..useNativeDigits = false).format(date);
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);

    // Static gradient: painted once, no animation, no blur (cheap).
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.55, 1],
          colors: [c.heroGradientStart, c.heroGradientMid, c.heroGradientEnd],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            pad,
            AppSpacing.md,
            pad,
            AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.smAll,
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: [c.capsuleSelected, c.primaryPressed],
                      ),
                      boxShadow: AppShadows.primaryGlow(c),
                    ),
                    child: Icon(
                      AppIcons.brand,
                      size: AppIconSize.action,
                      color: c.onCapsuleSelected,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      AppIdentity.of(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                dateText,
                key: const ValueKey('home-date'),
                style: AppTypography.labelL.copyWith(color: c.primary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(greeting, style: theme.textTheme.displayLarge),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.homeHeroSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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
                constraints: const BoxConstraints(minHeight: 60),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.xs,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.capsuleSelected,
                          boxShadow: AppShadows.primaryGlow(c),
                        ),
                        child: Icon(
                          AppIcons.search,
                          color: c.onCapsuleSelected,
                        ),
                      ),
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

/// Quick access: one capsule per section (horizontal, swipe-safe).
class _QuickAccess extends ConsumerWidget {
  const _QuickAccess({required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(contentLibraryProvider);
    final sections = [
      for (final s in ContentSection.values)
        if (library.isEmpty || library.itemsOf(s).isNotEmpty) s,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: padding, child: SectionHeader(l10n.homeQuickAccess)),
        const SizedBox(height: AppSpacing.sm),
        CapsuleRow(
          key: const ValueKey('quick-sections'),
          padding: padding,
          children: [
            for (final s in sections)
              Capsule(
                key: ValueKey('quick-section-${s.key}'),
                icon: s.icon,
                label: s.title(l10n),
                onTap: () => context.push(ContentRoutes.section(s.key)),
              ),
          ],
        ),
      ],
    );
  }
}

/// "Numbers to know by heart": hotlines and the most-used codes from
/// numbers.json, as compact two-line capsules.
class _MustKnowStrip extends ConsumerWidget {
  const _MustKnowStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(sectionItemsProvider(ContentSection.numbers));
    final contacts = items
        .where(
          (i) =>
              i.type == ItemType.contact &&
              i.phones.isNotEmpty &&
              i.status == ItemStatus.confirmed,
        )
        .take(4)
        .toList();
    final codes = items
        .where(
          (i) =>
              i.type == ItemType.code &&
              i.codes.isNotEmpty &&
              i.status == ItemStatus.confirmed,
        )
        .take(4)
        .toList();
    if (contacts.isEmpty && codes.isEmpty) return const SizedBox.shrink();
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final c = context.colors;

    // A vertical list, not a scrolling strip: a phone number or code is
    // never cut at the screen edge (a truncated number at the counter is a
    // wrong number).
    return Padding(
      key: const ValueKey('must-know-strip'),
      padding: EdgeInsetsDirectional.fromSTEB(pad, AppSpacing.lg, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(l10n.homeMustKnowTitle),
          const SizedBox(height: AppSpacing.sm),
          if (contacts.isNotEmpty)
            AppCard(
              role: CardRole.flat,
              padding: EdgeInsetsDirectional.zero,
              child: Column(
                children: [
                  for (final (i, item) in contacts.indexed) ...[
                    if (i > 0) Divider(color: c.hairline, height: 1),
                    _HotlineRow(
                      key: ValueKey('must-know-${item.id}'),
                      item: item,
                      number: item.phones.first,
                    ),
                  ],
                ],
              ),
            ),
          if (codes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final item in codes)
                  _CodeCapsule(
                    key: ValueKey('must-know-${item.id}'),
                    item: item,
                    code: item.codes.first,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Hotline row: the number in full (scaled down if needed, never cut), its
/// name (which may shorten), and a copy action.
class _HotlineRow extends StatelessWidget {
  const _HotlineRow({super.key, required this.item, required this.number});

  final ContentItem item;
  final String number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return InkWell(
      onTap: () => context.push(ContentRoutes.item(item.id)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.xxs,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            const TintedIcon(AppIcons.call, tile: IconTile.sm),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: LtrText(
                      number,
                      key: const ValueKey('must-know-number'),
                      style: AppTypography.code.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                      semanticsLabel: CodeText.spell(number, l10n),
                    ),
                  ),
                  ProseText(
                    item.title,
                    maxLines: 1,
                    style: AppTypography.labelS.copyWith(color: c.textTertiary),
                  ),
                ],
              ),
            ),
            IconButton(
              key: ValueKey('must-know-copy-${item.id}'),
              tooltip: l10n.copyValueSemantics(number),
              icon: const Icon(AppIcons.copy, size: AppIconSize.action),
              color: c.textSecondary,
              onPressed: () => CodeText.copyToClipboard(context, number),
            ),
          ],
        ),
      ),
    );
  }
}

/// Code capsule: the whole code is always shown (no width cap, no
/// ellipsis); capsules wrap onto new lines instead of scrolling off-screen.
class _CodeCapsule extends StatelessWidget {
  const _CodeCapsule({super.key, required this.item, required this.code});

  final ContentItem item;
  final String code;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: '${item.title}، $code',
      excludeSemantics: true,
      child: PressableScale(
        pressedScale: 0.96,
        child: Material(
          color: c.surfaceElevated,
          shape: StadiumBorder(side: BorderSide(color: c.hairline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(ContentRoutes.item(item.id)),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.code, size: AppIconSize.chip, color: c.primary),
                  const SizedBox(width: AppSpacing.xs - 2),
                  LtrText(
                    code,
                    style: AppTypography.code.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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

/// Recently opened items (persisted locally when available).
class _RecentStrip extends ConsumerWidget {
  const _RecentStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(contentLibraryProvider);
    final items = [
      for (final id in ref.watch(recentItemsProvider)) ?library.byId(id),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final hPad = EdgeInsetsDirectional.symmetric(horizontal: pad);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: hPad, child: SectionHeader(l10n.homeRecentTitle)),
          const SizedBox(height: AppSpacing.sm),
          CapsuleRow(
            key: const ValueKey('recent-strip'),
            padding: hPad,
            spacing: AppSpacing.cardGap,
            children: [
              for (final i in items)
                SizedBox(
                  width: 200,
                  child: AppCard(
                    role: CardRole.flat,
                    key: ValueKey('recent-${i.id}'),
                    semanticLabel: i.title,
                    padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                    onTap: () => context.push(ContentRoutes.item(i.id)),
                    child: Row(
                      children: [
                        SectionIconTile(
                          i.section,
                          icon: i.icon,
                          tile: IconTile.sm,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: ProseText(
                            i.title,
                            maxLines: 2,
                            style: AppTypography.labelL.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
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
                    // null while loading: no misleading "no items".
                    count: library.isEmpty ? null : library.itemsOf(s).length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Section card: tone icon tile, title, two-line subtitle, item count.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.section, this.count});

  final ContentSection section;

  /// Item count; null while content is loading (count line hidden).
  final int? count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final tone = section.tone(context);
    final title = section.title(l10n);
    final subtitle = section.subtitle(l10n);
    final countText = count == null ? null : l10n.itemCount(count!);

    return AppCard(
      key: ValueKey('section-card-${section.key}'),
      semanticLabel: [title, subtitle, ?countText].join('، '),
      onTap: () => context.push(ContentRoutes.section(section.key)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionIconTile(section, tile: IconTile.lg),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
          if (countText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              countText,
              style: AppTypography.labelS.copyWith(
                color: tone.foreground,
                fontWeight: FontWeight.w600,
                fontFeatures: AppTypography.tabular,
              ),
            ),
          ],
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
