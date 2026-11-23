import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/router/search_focus.dart';
import '../../core/settings/history.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import '../content/section_ui.dart';

/// Search: the field is focused (keyboard opens) whenever the user enters
/// via the Search tab or the Home pill (doc 04 §4.1) — driven by
/// [searchFocusRequestProvider], not `autofocus`, because the branch is
/// preloaded for swiping and must not pop the keyboard at app start.
/// Idle: recent searches as capsules. Typing: instant (debounced) results
/// with section capsule filters.
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

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    // A request made before this page was first built (lazy PageView page).
    if (ref.read(searchFocusRequestProvider).pending) _handleRequest(false);
  }

  void _handleRequest(bool clear) {
    if (clear) _controller.clear();
    // After goBranch has made this branch visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      ref.read(searchFocusRequestProvider.notifier).consume();
    });
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
    ref.listen<SearchFocusRequest>(searchFocusRequestProvider, (prev, next) {
      if (next.pending && next.tick != prev?.tick) _handleRequest(next.clear);
    });

    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final field = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.fullAll,
        boxShadow: AppShadows.raised(c),
      ),
      child: TextField(
        key: const ValueKey('search-field'),
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _commit(),
        style: AppTypography.bodyL.copyWith(color: c.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.searchFieldHint,
          fillColor: c.surfaceElevated,
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md + 2,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.md,
              end: AppSpacing.xs,
            ),
            child: Icon(AppIcons.search, color: c.primary),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => _controller.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: l10n.searchClear,
                    icon: const Icon(AppIcons.clear, size: AppIconSize.action),
                    color: c.textTertiary,
                    onPressed: _controller.clear,
                  ),
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.fullAll,
            borderSide: BorderSide(color: c.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.fullAll,
            borderSide: BorderSide(color: c.borderStrong),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.fullAll,
            borderSide: BorderSide(color: c.primary, width: 2),
          ),
        ),
      ),
    );

    return PageScaffold(
      title: l10n.searchTitle,
      header: field,
      slivers: _results(context, l10n),
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

    final filters = sections.length < 2
        ? const <Widget>[]
        : [
            SliverToBoxAdapter(
              child: CapsuleRow(
                key: const ValueKey('search-filters'),
                padding: hPad,
                children: [
                  Capsule(
                    key: const ValueKey('search-filter-all'),
                    label: l10n.filterAll,
                    dense: true,
                    selected: _section == null,
                    onTap: () => setState(() => _section = null),
                  ),
                  for (final s in sections)
                    Capsule(
                      key: ValueKey('search-filter-${s.key}'),
                      icon: s.icon,
                      label: s.title(l10n),
                      dense: true,
                      selected: _section == s,
                      onTap: () =>
                          setState(() => _section = _section == s ? null : s),
                    ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          ];

    if (_query.trim().isEmpty) {
      final recent = ref.watch(recentSearchesProvider);
      return [
        if (recent.isNotEmpty) ...[
          box(
            SectionHeader(
              l10n.searchRecentTitle,
              trailing: TextButton(
                key: const ValueKey('search-recent-clear'),
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clear(),
                child: Text(l10n.searchRecentClear),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
          SliverToBoxAdapter(
            child: CapsuleRow(
              key: const ValueKey('search-recent'),
              padding: hPad,
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
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ],
        box(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.offline, size: AppIconSize.chip, color: c.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.searchIdleBody,
                  style: AppTypography.bodyM.copyWith(color: c.textTertiary),
                ),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        ...filters,
      ];
    }

    final results = index.search(_query, section: _section, limit: 60);
    return [
      ...filters,
      if (results.isEmpty)
        box(
          PlaceholderPanel(
            key: const ValueKey('search-empty'),
            icon: AppIcons.emptySearch,
            title: l10n.searchEmptyTitle,
            body: l10n.searchEmptyBody,
          ),
        )
      else ...[
        box(
          Text(
            l10n.searchResultsCount(results.length),
            key: const ValueKey('search-count'),
            style: AppTypography.labelS.copyWith(color: c.textTertiary),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
        SliverPadding(
          padding: hPad,
          sliver: SliverList.separated(
            itemCount: results.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.cardGap),
            itemBuilder: (_, i) => ContentItemRow(
              item: results[i].item,
              showSection: true,
              snippet: results[i].snippet,
              highlights: results[i].highlights,
            ),
          ),
        ),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
    ];
  }
}
