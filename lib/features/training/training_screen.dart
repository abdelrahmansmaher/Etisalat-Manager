import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Training placeholder (v1.1 per doc 00 §6) plus the review entry.
class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final count = ref.watch(contentLibraryProvider).needsReview.length;
    return PageScaffold(
      title: l10n.trainingTitle,
      children: [
        PlaceholderPanel(
          icon: Icons.school_rounded,
          title: l10n.contentComingSoon,
          body: l10n.trainingPlaceholderBody,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          key: const ValueKey('training-review-entry'),
          semanticLabel:
              '${l10n.trainingReviewTitle}، ${l10n.trainingReviewSubtitle(count)}',
          onTap: () => context.push(ContentRoutes.review),
          child: Row(
            children: [
              TintedIcon(
                Icons.fact_check_rounded,
                background: c.warningContainer,
                color: c.onWarningContainer,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.trainingReviewTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      l10n.trainingReviewSubtitle(count),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: c.textTertiary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
