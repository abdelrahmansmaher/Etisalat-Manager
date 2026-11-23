import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_localizations.dart';
import '../content/section_ui.dart';

/// Browse: every content section with its item count.
class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final library = ref.watch(contentLibraryProvider);

    return PageScaffold(
      title: l10n.browseTitle,
      subtitle: l10n.browseSubtitle,
      children: [
        for (final s in ContentSection.values) ...[
          AppCard(
            key: ValueKey('browse-${s.key}'),
            semanticLabel:
                '${s.title(l10n)}، ${l10n.itemCount(library.itemsOf(s).length)}',
            onTap: () => context.push(ContentRoutes.section(s.key)),
            child: Row(
              children: [
                TintedIcon(s.icon),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title(l10n), style: theme.textTheme.titleMedium),
                      Text(
                        s.subtitle(l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                      Text(
                        l10n.itemCount(library.itemsOf(s).length),
                        style: AppTypography.labelS.copyWith(color: c.primary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],
        const SizedBox(height: AppSpacing.md),
        const UnofficialDisclaimer.compact(),
      ],
    );
  }
}
