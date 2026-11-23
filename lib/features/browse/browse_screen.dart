import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../encyclopedia/encyclopedia_sections.dart';

/// Browse placeholder: every encyclopedia as a list card.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;

    return PageScaffold(
      title: l10n.browseTitle,
      subtitle: l10n.browseSubtitle,
      children: [
        for (final s in EncyclopediaSection.values) ...[
          AppCard(
            semanticLabel: '${s.title(l10n)}، ${l10n.contentComingSoon}',
            onTap: () {},
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
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.contentComingSoon,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary),
        ),
      ],
    );
  }
}
