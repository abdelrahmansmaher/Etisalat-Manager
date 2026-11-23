import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_localizations.dart';
import 'content_widgets.dart';
import 'section_ui.dart';

/// Every unconfirmed / conflicting item across sections.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(contentProvider);
    final items = async.value?.needsReview ?? const <ContentItem>[];

    final children = <Widget>[];
    if (async.value == null) {
      children.add(const ContentLoading());
    } else if (items.isEmpty) {
      children.add(
        PlaceholderPanel(
          icon: AppIcons.allReviewed,
          title: l10n.trainingReviewSubtitle(0),
          body: l10n.reviewScreenSubtitle,
        ),
      );
    }
    ContentSection? current;
    for (final i in items) {
      if (i.section != current) {
        current = i.section;
        children.addAll([
          const SizedBox(height: AppSpacing.sm),
          SectionHeader(i.section.title(l10n)),
          const SizedBox(height: AppSpacing.sm),
        ]);
      }
      children.addAll([
        ContentItemRow(item: i),
        const SizedBox(height: AppSpacing.cardGap),
      ]);
    }
    children.addAll([
      const SizedBox(height: AppSpacing.xl),
      const UnofficialDisclaimer.compact(),
    ]);

    return PageScaffold(
      title: l10n.reviewScreenTitle,
      subtitle: l10n.reviewScreenSubtitle,
      children: children,
    );
  }
}
