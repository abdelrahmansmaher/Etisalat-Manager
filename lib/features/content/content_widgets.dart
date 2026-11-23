import 'package:flutter/material.dart';

import '../../core/widgets/prose_text.dart';

import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';
import 'section_ui.dart';

/// Status pill for a content item: confirmed (green), unconfirmed (amber),
/// conflict (red). Icon + text, never colour alone.
class ContentStatusPill extends StatelessWidget {
  const ContentStatusPill(this.status, {super.key});

  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.trustColors;
    final (icon, label, sc) = switch (status) {
      ItemStatus.confirmed => (
        Icons.verified_outlined,
        l10n.statusConfirmedGuide,
        t.verified,
      ),
      ItemStatus.unconfirmed => (
        Icons.help_outline,
        l10n.statusUnconfirmedReview,
        t.needsReview,
      ),
      ItemStatus.conflict => (
        Icons.report_outlined,
        l10n.statusConflict,
        t.conflict,
      ),
    };
    return TrustPill(
      key: ValueKey('status-${status.name}'),
      icon: icon,
      label: label,
      foreground: sc.foreground,
      background: sc.container,
    );
  }
}

/// Snippet with highlighted ranges.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    super.key,
    this.highlights = const [],
    this.style,
    this.maxLines,
  });

  final String text;
  final List<Highlight> highlights;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hl = (style ?? const TextStyle()).copyWith(
      color: c.onPrimaryContainer,
      backgroundColor: c.primaryContainer,
      fontWeight: FontWeight.w700,
    );
    final spans = <TextSpan>[];
    var pos = 0;
    for (final h in highlights) {
      if (h.start < pos || h.end > text.length) continue;
      if (h.start > pos) {
        spans.add(TextSpan(text: text.substring(pos, h.start)));
      }
      spans.add(TextSpan(text: text.substring(h.start, h.end), style: hl));
      pos = h.end;
    }
    if (pos < text.length) spans.add(TextSpan(text: text.substring(pos)));
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

/// Amber banner for unconfirmed items, with the guide's own note.
class UnconfirmedBanner extends StatelessWidget {
  const UnconfirmedBanner({super.key, this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sc = context.trustColors.needsReview;
    final fg = sc.foreground;
    return Semantics(
      container: true,
      child: Container(
        key: const ValueKey('unconfirmed-banner'),
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: sc.container,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: fg.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.help_outline, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.unconfirmedBannerTitle,
                    style: AppTypography.titleM.copyWith(color: fg),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  if (note != null)
                    ProseText(
                      note!,
                      style: AppTypography.bodyM.copyWith(color: fg),
                    ),
                  Text(
                    l10n.unconfirmedBannerBody,
                    style: AppTypography.bodyM.copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List row for an item: title, summary, status pill, first code/price.
class ContentItemRow extends StatelessWidget {
  const ContentItemRow({
    super.key,
    required this.item,
    this.showSection = false,
    this.snippet,
    this.highlights = const [],
  });

  final ContentItem item;
  final bool showSection;

  /// Search snippet replacing the summary.
  final String? snippet;
  final List<Highlight> highlights;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final lead = item.leadValue;
    final copyable =
        item.section == ContentSection.numbers &&
        (item.codes.isNotEmpty || item.phones.isNotEmpty);
    final body = snippet ?? item.summary;

    return AppCard(
      key: ValueKey('item-row-${item.id}'),
      onTap: () => context.push(ContentRoutes.item(item.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSection) ...[
            Row(
              children: [
                Icon(item.section.icon, size: 16, color: c.primary),
                const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    item.section.title(l10n),
                    style: AppTypography.labelS.copyWith(color: c.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
          ],
          ProseText(item.title, style: theme.textTheme.titleMedium),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 2),
            if (snippet == null)
              ProseText(
                body,
                maxLines: 3,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              )
            else
              HighlightedText(
                body,
                highlights: highlights,
                maxLines: 3,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ContentStatusPill(item.status),
              if (copyable)
                for (final v in [...item.codes, ...item.phones].take(2))
                  CodeText(v, dense: true)
              else if (lead != null)
                LtrText(
                  lead,
                  style: AppTypography.code.copyWith(color: c.textPrimary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Centered loading indicator for content screens.
class ContentLoading extends StatelessWidget {
  const ContentLoading({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.xl),
    child: Center(child: CircularProgressIndicator()),
  );
}

/// Shows a snackbar placeholder until a dialer is wired.
void showCallPlaceholder(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.callPlaceholder)));
}
