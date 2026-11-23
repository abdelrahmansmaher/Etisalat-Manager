import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';

import '../../core/router/search_focus.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import '../content/section_ui.dart';

/// Search placeholder: the field is focused (keyboard opens) whenever the
/// user enters via the Search tab or the Home pill (doc 04 §4.1) - driven by
/// [searchFocusRequestProvider], not `autofocus`, because the branch is
/// preloaded for swiping and must not pop the keyboard at app start.
/// Below it: instant (debounced) results from [contentSearchProvider].
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode(debugLabel: 'search-field');
  Timer? _debounce;
  String _query = '';
  ContentSection? _section;

  static const _debounceDelay = Duration(milliseconds: 120);

  void _onChanged() {
    final text = _controller.text;
    if (text == _query) return;
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() => _query = text);
      return;
    }
    _debounce = Timer(_debounceDelay, () {
      if (mounted) setState(() => _query = _controller.text);
    });
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

    return PageScaffold(
      title: l10n.searchTitle,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            boxShadow: AppShadows.card(c),
          ),
          child: TextField(
            key: const ValueKey('search-field'),
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            style: AppTypography.bodyL.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.searchFieldHint,
              fillColor: c.surfaceElevated,
              prefixIcon: Icon(Icons.search_rounded, color: c.primary),
              suffixIcon: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => _controller.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: l10n.searchClear,
                        icon: const Icon(Icons.close_rounded),
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
        ),
        const SizedBox(height: AppSpacing.md),
        ..._results(context, l10n),
      ],
    );
  }

  List<Widget> _results(BuildContext context, AppLocalizations l10n) {
    final c = context.colors;
    final library = ref.watch(contentLibraryProvider);
    final index = ref.watch(contentSearchProvider);
    final sections = [
      for (final s in ContentSection.values)
        if (library.itemsOf(s).isNotEmpty) s,
    ];
    final chips = sections.length < 2
        ? const <Widget>[]
        : [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                ChoiceChip(
                  key: const ValueKey('search-filter-all'),
                  label: Text(l10n.filterAll),
                  selected: _section == null,
                  onSelected: (_) => setState(() => _section = null),
                ),
                for (final s in sections)
                  ChoiceChip(
                    key: ValueKey('search-filter-${s.key}'),
                    label: Text(s.title(l10n)),
                    selected: _section == s,
                    onSelected: (_) =>
                        setState(() => _section = _section == s ? null : s),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ];

    if (_query.trim().isEmpty) {
      return [
        Text(
          l10n.searchIdleBody,
          style: AppTypography.bodyM.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: AppSpacing.md),
        ...chips,
      ];
    }

    final results = index.search(_query, section: _section, limit: 60);
    return [
      ...chips,
      if (results.isEmpty)
        PlaceholderPanel(
          key: const ValueKey('search-empty'),
          icon: Icons.search_off_rounded,
          title: l10n.searchEmptyTitle,
          body: l10n.searchEmptyBody,
        )
      else ...[
        Text(
          l10n.searchResultsCount(results.length),
          key: const ValueKey('search-count'),
          style: AppTypography.labelS.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final r in results) ...[
          ContentItemRow(
            item: r.item,
            showSection: true,
            snippet: r.snippet,
            highlights: r.highlights,
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],
      ],
      const SizedBox(height: AppSpacing.md),
      const UnofficialDisclaimer.compact(),
    ];
  }
}
