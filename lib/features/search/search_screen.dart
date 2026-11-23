import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/search_focus.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';

/// Search placeholder: the field is focused (keyboard opens) whenever the
/// user enters via the Search tab or the Home pill (doc 04 §4.1) - driven by
/// [searchFocusRequestProvider], not `autofocus`, because the branch is
/// preloaded for swiping and must not pop the keyboard at app start.
/// Below it: an illustrative answer card with FAKE data showing the trust
/// components. The real engine lives in lib/core/search (other owner).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode(debugLabel: 'search-field');

  @override
  void initState() {
    super.initState();
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
        Text(
          l10n.searchPlaceholderBody,
          style: AppTypography.bodyM.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(l10n.searchExampleTitle),
        const SizedBox(height: AppSpacing.sm),
        const _ExampleAnswerCard(),
      ],
    );
  }
}

/// Illustrative only — all values are fake placeholders.
class _ExampleAnswerCard extends StatelessWidget {
  const _ExampleAnswerCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TintedIcon(Icons.sell_outlined, size: 40),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.searchExampleItem,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PriceView(
            amount: 100,
            taxBasis: TaxBasis.inclusiveRechargeTax,
            validFrom: now.subtract(const Duration(days: 10)),
            validUntil: now.add(const Duration(days: 20)),
          ),
          const SizedBox(height: AppSpacing.sm),
          const CodeText('*999#'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const VerificationStatusBadge(VerificationStatus.verified),
              SourceBadge(
                sourceName: l10n.searchExampleSource,
                type: SourceType.officialPublic,
              ),
              LastVerifiedChip(
                verifiedAt: now.subtract(const Duration(days: 5)),
                contentType: TrustContentType.pricesOffers,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
