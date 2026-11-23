import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/trust_colors.dart';
import '../ltr_text.dart';
import 'trust_format.dart';
import '../../theme/app_icons.dart';

/// One side of a conflict: the value as a source states it.
@immutable
class ConflictEntry {
  const ConflictEntry({
    required this.value,
    required this.sourceName,
    this.sourceDate,
  });

  /// Rendered LTR-isolated (prices, codes, numbers).
  final String value;
  final String sourceName;
  final DateTime? sourceDate;
}

/// Solid conflict banner (doc 04 §3.4). Never glass. The app never picks a
/// value on the user's behalf — both values are shown side by side.
class ConflictBanner extends StatelessWidget {
  const ConflictBanner({super.key, this.entries = const [], this.onReview});

  final List<ConflictEntry> entries;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sc = context.trustColors.conflict;
    final locale = Localizations.localeOf(context);
    final fg = sc.foreground;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: sc.container,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: fg.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(AppIcons.conflict, color: fg),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.conflictTitle,
                    style: AppTypography.titleM.copyWith(color: fg),
                  ),
                ),
              ],
            ),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final e in entries)
                    _EntryTile(entry: e, color: fg, locale: locale),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.conflictGuidance,
              style: AppTypography.bodyM.copyWith(color: fg),
            ),
            if (onReview != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: onReview,
                  style: TextButton.styleFrom(foregroundColor: fg),
                  child: Text(l10n.conflictAction),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.color,
    required this.locale,
  });

  final ConflictEntry entry;
  final Color color;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final date = entry.sourceDate;
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xsAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LtrText(
            entry.value,
            style: AppTypography.titleM.copyWith(color: color),
          ),
          Text(
            date == null
                ? entry.sourceName
                : '${entry.sourceName} · ${TrustFormat.date(date, locale)}',
            style: AppTypography.labelS.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
