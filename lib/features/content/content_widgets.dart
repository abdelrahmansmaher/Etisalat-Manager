import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';
import 'section_ui.dart';

/// Icon, label and colours for an item status. Colour is never the only
/// signal: every status UI pairs it with an icon or dot **and** a label.
({IconData icon, String label, StatusColors colors}) statusVisual(
  BuildContext context,
  ItemStatus status, {
  bool official = false,
}) {
  final l10n = AppLocalizations.of(context);
  final t = context.trustColors;
  return switch (status) {
    ItemStatus.confirmed => (
      icon: Icons.verified_rounded,
      label: official
          ? l10n.statusConfirmedOfficial
          : l10n.statusConfirmedGuide,
      colors: t.verified,
    ),
    ItemStatus.unconfirmed => (
      icon: Icons.help_rounded,
      label: l10n.statusUnconfirmedReview,
      colors: t.needsReview,
    ),
    ItemStatus.conflict => (
      icon: Icons.report_rounded,
      label: l10n.statusConflict,
      colors: t.conflict,
    ),
  };
}

/// Status pill for a content item (detail headers): icon + label on a soft
/// tinted capsule.
class ContentStatusPill extends StatelessWidget {
  const ContentStatusPill(this.status, {super.key, this.official = false});

  final ItemStatus status;

  /// Confirmed on the official site (shows "confirmed from official site").
  final bool official;

  @override
  Widget build(BuildContext context) {
    final v = statusVisual(context, status, official: official);
    return TrustPill(
      key: ValueKey('status-${status.name}'),
      icon: v.icon,
      label: v.label,
      foreground: v.colors.foreground,
      background: v.colors.container,
    );
  }
}

/// Compact status for list rows: coloured dot + label.
class StatusDot extends StatelessWidget {
  const StatusDot(this.status, {super.key, this.official = false});

  final ItemStatus status;

  /// Confirmed on the official site.
  final bool official;

  @override
  Widget build(BuildContext context) {
    final v = statusVisual(context, status, official: official);
    final fg = v.colors.foreground;
    return Semantics(
      key: ValueKey('status-${status.name}'),
      label: v.label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: fg.withValues(alpha: 0.35), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs - 2),
          Flexible(
            child: Text(
              v.label,
              style: AppTypography.labelS.copyWith(color: fg),
            ),
          ),
        ],
      ),
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

/// Soft banner for one trust state: icon disc, title, body lines.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.colors,
    this.lines = const [],
  });

  final IconData icon;
  final String title;
  final StatusColors colors;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final fg = colors.foreground;
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: fg.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fg.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: fg, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleM.copyWith(color: fg)),
                  for (final l in lines) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    ProseText(
                      l,
                      style: AppTypography.bodyM.copyWith(color: fg),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
    return StatusBanner(
      key: const ValueKey('unconfirmed-banner'),
      icon: Icons.help_rounded,
      title: l10n.unconfirmedBannerTitle,
      colors: context.trustColors.needsReview,
      lines: [?note, l10n.unconfirmedBannerBody],
    );
  }
}

/// Square icon tile tinted with the section's accent (soft gradient).
class SectionIconTile extends StatelessWidget {
  const SectionIconTile(this.section, {super.key, this.size = 44});

  final ContentSection section;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tone = section.tone(context);
    return TintedIcon(
      section.icon,
      size: size,
      color: tone.foreground,
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [tone.container, tone.glow],
      ),
    );
  }
}

/// The fact worth showing in a list row (first price, code or phone).
Fact? leadFact(ContentItem item) {
  for (final f in item.facts) {
    if ((f.kind == FactKind.price ||
            f.kind == FactKind.code ||
            f.kind == FactKind.phone) &&
        f.rendersLtr &&
        !f.isBlank) {
      return f;
    }
  }
  return null;
}

/// LTR value capsule for list rows: prices in warm gold (value + unit as
/// separate runs so "ج" sits naturally in Arabic), codes in monospace.
class ValuePill extends StatelessWidget {
  const ValuePill({
    super.key,
    required this.value,
    this.unit,
    this.isPrice = false,
  });

  final String value;
  final String? unit;
  final bool isPrice;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = isPrice ? c.onAccentContainer : c.textPrimary;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isPrice ? c.accentContainer : c.surfaceVariant,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: fg.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: LtrText(
              value,
              maxLines: 1,
              style:
                  (isPrice
                          ? AppTypography.titleS.copyWith(
                              fontFeatures: AppTypography.tabular,
                            )
                          : AppTypography.code.copyWith(fontSize: 13))
                      .copyWith(color: fg),
            ),
          ),
          if (unit != null) ...[
            const SizedBox(width: 3),
            Text(unit!, style: AppTypography.labelS.copyWith(color: fg)),
          ],
        ],
      ),
    );
  }
}

/// List row for an item: section tile, title, one-line summary (or the
/// highlighted search snippet), status dot + label and a value capsule.
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
    final lead = leadFact(item);
    final copyable =
        item.section == ContentSection.numbers &&
        (item.codes.isNotEmpty || item.phones.isNotEmpty);
    final body = snippet ?? item.summary;
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: c.textSecondary,
    );

    Widget? value;
    if (copyable) {
      value = Wrap(
        spacing: AppSpacing.xxs,
        children: [
          for (final v in [...item.codes, ...item.phones].take(2))
            CodeText(v, dense: true),
        ],
      );
    } else if (lead != null) {
      value = ValuePill(
        value: lead.value,
        unit: lead.unit,
        isPrice: lead.kind == FactKind.price,
      );
    } else if (item.codes.isNotEmpty || item.phones.isNotEmpty) {
      value = ValuePill(value: [...item.codes, ...item.phones].first);
    }

    return AppCard(
      key: ValueKey('item-row-${item.id}'),
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md - 2,
        AppSpacing.md - 2,
        AppSpacing.md - 2,
        AppSpacing.sm,
      ),
      onTap: () => context.push(ContentRoutes.item(item.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionIconTile(item.section, size: 40),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSection)
                  Text(
                    item.section.title(l10n),
                    style: AppTypography.labelS.copyWith(
                      color: item.section.tone(context).foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ProseText(
                  item.title,
                  maxLines: 2,
                  style: theme.textTheme.titleMedium,
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  if (snippet == null)
                    ProseText(body, maxLines: 1, style: bodyStyle)
                  else
                    HighlightedText(
                      body,
                      highlights: highlights,
                      maxLines: 2,
                      style: bodyStyle,
                    ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusDot(item.status, official: item.officiallyVerified),
                    ?value,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder for content screens (static skeleton rows).
class ContentLoading extends StatelessWidget {
  const ContentLoading({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: SkeletonList(),
  );
}

/// Shows a snackbar placeholder until a dialer is wired.
void showCallPlaceholder(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.callPlaceholder)));
}
