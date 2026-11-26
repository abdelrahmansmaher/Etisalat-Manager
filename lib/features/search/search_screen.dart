import 'love_note.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/settings/history.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/choice_sheet.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/list_surface.dart';
import '../../core/widgets/liquid_glass.dart';
import '../../core/widgets/masthead.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import '../content/section_ui.dart';
import '../tools/tool_routes.dart';

/// Full search, pushed from the pill of any tab with the keyboard up.
/// Idle: recent searches. Typing: instant (debounced) results with section
/// capsules.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode(debugLabel: 'search-field');
  Timer? _debounce;
  Timer? _remember;
  String _query = '';
  ContentSection? _section;

  /// What customers ask for most at the counter.
  static const _quickQueries = [
    'خدمة العملاء',
    'حكاية',
    'إيميرالد',
    'سلفني',
    'بدل فاقد',
    'نقل الرقم',
    'المحفظة',
    'eSIM',
    'تجوال',
    'راوتر',
  ];

  static const _debounceDelay = Duration(milliseconds: 120);

  /// A query is remembered once the user pauses on it with results.
  static const _rememberDelay = Duration(milliseconds: 1500);

  void _onChanged() {
    final text = _controller.text;
    if (text == _query) return;
    _debounce?.cancel();
    _remember?.cancel();
    if (text.trim().isEmpty) {
      setState(() => _query = text);
      return;
    }
    _debounce = Timer(_debounceDelay, () {
      if (mounted) setState(() => _query = _controller.text);
    });
    _remember = Timer(_rememberDelay, _commit);
  }

  void _commit() {
    if (!mounted) return;
    final q = _controller.text.trim();
    if (q.length < 2) return;
    final results = ref.read(contentSearchProvider).search(q, limit: 1);
    if (results.isNotEmpty) ref.read(recentSearchesProvider.notifier).add(q);
  }

  void _useQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    _debounce?.cancel();
    setState(() => _query = q);
    ref.read(recentSearchesProvider.notifier).add(q);
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _remember?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final border = OutlineInputBorder(
      borderRadius: AppRadius.fullAll,
      borderSide: BorderSide(color: c.glassEdge),
    );

    final field = TextField(
      key: const ValueKey('search-field'),
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: (text) {
        if (LoveNote.matches(text)) {
          LoveNote.show(context);
          return;
        }
        _commit();
      },
      style: AppTypography.bodyL.copyWith(color: c.textPrimary),
      decoration: InputDecoration(
        hintText: l10n.searchFieldHint,
        hintMaxLines: 2,
        hintStyle: AppTypography.bodyL.copyWith(color: c.textTertiary),
        fillColor: c.headerField,
        isDense: true,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        suffixIcon: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _controller.text.isEmpty
              ? Icon(AppIcons.search, color: c.primary)
              : IconButton(
                  tooltip: l10n.searchClear,
                  icon: const Icon(AppIcons.clear, size: AppIconSize.action),
                  color: c.textTertiary,
                  onPressed: _controller.clear,
                ),
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: c.primaryUi, width: 2),
        ),
      ),
    );

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Masthead(
              field: Row(
                children: [
                  BackButton(onPressed: _back, color: c.onHeader),
                  const SizedBox(width: AppSpacing.xxs),
                  Expanded(child: field),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                key: const ValueKey('search-scroll'),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  ..._results(context, l10n),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom:
                          AppSpacing.md + MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(BuildContext context, AppLocalizations l10n) {
    final c = context.colors;
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final hPad = EdgeInsetsDirectional.symmetric(horizontal: pad);
    final library = ref.watch(contentLibraryProvider);
    final index = ref.watch(contentSearchProvider);
    final sections = [
      for (final s in ContentSection.values)
        if (library.itemsOf(s).isNotEmpty) s,
    ];

    Widget box(Widget child) => SliverPadding(
      padding: hPad,
      sliver: SliverToBoxAdapter(child: child),
    );

    if (_query.trim().isEmpty) {
      final recent = ref.watch(recentSearchesProvider);
      // Only words that find something in the current content.
      final quick = [
        for (final q in _quickQueries)
          if (index.search(q, limit: 1).isNotEmpty) q,
      ];
      return [
        if (quick.isNotEmpty) ...[
          box(GroupHeader(l10n.searchQuickTitle)),
          box(
            Wrap(
              key: const ValueKey('search-quick'),
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final q in quick)
                  Capsule(
                    key: ValueKey('quick-search-$q'),
                    label: q,
                    dense: true,
                    onTap: () => _useQuery(q),
                  ),
              ],
            ),
          ),
        ],
        if (recent.isNotEmpty) ...[
          box(
            GroupHeader(
              l10n.searchRecentTitle,
              trailing: TextButton(
                key: const ValueKey('search-recent-clear'),
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clear(),
                child: Text(l10n.searchRecentClear),
              ),
            ),
          ),
          box(
            Wrap(
              key: const ValueKey('search-recent'),
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final q in recent)
                  Capsule(
                    key: ValueKey('recent-search-$q'),
                    icon: AppIcons.history,
                    label: q,
                    dense: true,
                    onTap: () => _useQuery(q),
                  ),
              ],
            ),
          ),
        ],
        box(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              l10n.searchIdleBody,
              style: AppTypography.bodyM.copyWith(color: c.textSecondary),
            ),
          ),
        ),
      ];
    }

    final results = index.search(_query, section: _section, limit: 60);
    return [
      if (sections.length > 1)
        // Where to search: one button and a sheet, not a row of capsules.
        PinnedHeaderSliver(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              hPad.start,
              AppSpacing.xs,
              hPad.end,
              AppSpacing.xxs,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilterPill(
                key: const ValueKey('search-filters'),
                floating: true,
                label:
                    _section?.title(l10n) ??
                    '${l10n.searchScopeTitle}: ${l10n.filterAll}',
                active: _section != null,
                onTap: () async {
                  final picked = await showChoiceSheet<String>(
                    context,
                    title: l10n.searchScopeTitle,
                    selected: _section?.key ?? '',
                    choices: [
                      Choice(
                        key: const ValueKey('search-filter-all'),
                        value: '',
                        label: l10n.filterAll,
                        leading: const TintedIcon(
                          AppIcons.layers,
                          tile: IconTile.sm,
                        ),
                      ),
                      for (final s in sections)
                        Choice(
                          key: ValueKey('search-filter-${s.key}'),
                          value: s.key,
                          label: s.title(l10n),
                          leading: TintedIcon(s.icon, tile: IconTile.sm),
                        ),
                    ],
                  );
                  if (picked == null || !mounted) return;
                  setState(
                    () => _section = picked.isEmpty
                        ? null
                        : sections.firstWhere((s) => s.key == picked),
                  );
                },
              ),
            ),
          ),
        ),
      if (results.isEmpty)
        box(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: PlaceholderPanel(
              key: const ValueKey('search-empty'),
              icon: AppIcons.emptySearch,
              title: l10n.searchEmptyTitle,
              body: l10n.searchEmptyBody,
              action: _section != null
                  ? FilledButton(
                      key: const ValueKey('search-all-sections'),
                      onPressed: () => setState(() => _section = null),
                      child: Text(l10n.searchAllSections),
                    )
                  : OutlinedButton.icon(
                      key: const ValueKey('search-add-item'),
                      onPressed: () => context.push(ToolRoutes.newItem),
                      icon: const Icon(AppIcons.toolAdd),
                      label: Text(l10n.editorAdd),
                    ),
            ),
          ),
        )
      else ...[
        SliverPadding(
          padding: hPad,
          sliver: SliverListSurface(
            key: const ValueKey('search-results'),
            itemCount: results.length,
            itemBuilder: (_, i) => ContentItemRow(
              item: results[i].item,
              showSection: true,
              snippet: results[i].snippet,
              highlights: results[i].highlights,
            ),
          ),
        ),
        box(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              l10n.searchResultsCount(results.length),
              key: const ValueKey('search-count'),
              textAlign: TextAlign.center,
              style: AppTypography.labelS.copyWith(color: c.textTertiary),
            ),
          ),
        ),
      ],
    ];
  }
}
