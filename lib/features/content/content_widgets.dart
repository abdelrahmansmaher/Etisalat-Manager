import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';
import '../tools/dial.dart';
import 'package_facts.dart';
import 'package_family.dart';
import 'section_ui.dart';

/// Tiny mark after a title in lists: a check for confirmed items, "edited by
/// you" for the owner's own changes, nothing otherwise (an unknown status
/// never looks confirmed).
class ItemMark extends StatelessWidget {
  const ItemMark(this.item, {super.key});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    if (item.userEdited) {
      return Text(
        l10n.editedByYou,
        key: ValueKey('edited-${item.id}'),
        style: AppTypography.labelS.copyWith(color: c.primary),
      );
    }
    if (item.status != ItemStatus.confirmed) return const SizedBox.shrink();
    return Icon(
      AppIcons.confirmed,
      key: ValueKey('confirmed-${item.id}'),
      size: 14,
      color: c.verified,
      semanticLabel: item.officiallyVerified
          ? l10n.statusConfirmedOfficial
          : l10n.statusConfirmedGuide,
    );
  }
}

/// One quiet line on the detail page: where the information stands.
class TrustLine extends StatelessWidget {
  const TrustLine(this.item, {super.key});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.trustColors;
    final (IconData icon, String text, Color color) = switch (item) {
      ContentItem(userEdited: true) => (
        AppIcons.edit,
        l10n.editedByYouOn(
          TrustFormat.date(item.editedAt!, Localizations.localeOf(context)),
        ),
        c.primary,
      ),
      ContentItem(status: ItemStatus.confirmed, verifiedOn: final d?) => (
        AppIcons.confirmed,
        '${l10n.statusConfirmedOfficial} · '
            '${TrustFormat.date(d, Localizations.localeOf(context))}',
        c.verified,
      ),
      ContentItem(status: ItemStatus.confirmed) => (
        AppIcons.document,
        l10n.statusPerGuide,
        c.textTertiary,
      ),
      _ => (
        AppIcons.unconfirmed,
        l10n.statusUnconfirmedReview,
        t.needsReview.foreground,
      ),
    };
    return Row(
      key: const ValueKey('trust-line'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 2),
          child: Icon(icon, size: AppIconSize.inline, color: color),
        ),
        const SizedBox(width: AppSpacing.xxs + 2),
        Expanded(
          child: Text(
            text,
            style: AppTypography.labelL.copyWith(color: color),
          ),
        ),
      ],
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
  });

  final String text;
  final List<Highlight> highlights;
  final TextStyle? style;

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
    return Text.rich(TextSpan(style: style, children: spans));
  }
}

/// Shortens prose to about [max] characters at a word boundary. A number,
/// price or code is kept whole or dropped, never cut.
String clipWords(String text, {int max = 72}) {
  final t = text.trim();
  if (t.length <= max) return t;
  final words = t.split(RegExp(r'\s+'));
  final out = <String>[];
  var length = 0;
  for (final w in words) {
    if (length + w.length > max) break;
    out.add(w);
    length += w.length + 1;
  }
  if (out.isEmpty) out.add(words.first);
  // Never end on a bare preposition before a dropped number.
  while (out.length > 1 &&
      const {'بـ', 'ب', 'من', 'كل', 'حتى', 'و', '-', '–', '—'}.contains(
        out.last,
      )) {
    out.removeLast();
  }
  return '${out.join(' ').replaceAll(RegExp(r'[،,:؛.\-–—]+$'), '')}…';
}

const double _rowMinHeight = 60;

/// Shared frame of every dense row.
class _RowFrame extends StatelessWidget {
  const _RowFrame({
    required this.item,
    required this.child,
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
  });

  final ContentItem item;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('item-row-${item.id}'),
      onTap: () => context.push(ContentRoutes.item(item.id)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowMinHeight),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Title with its mark flowing right after the last word.
class _RowTitle extends StatelessWidget {
  const _RowTitle(this.item, {this.title});

  final ContentItem item;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: AppSpacing.xxs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ProseText(
          title ?? item.title,
          style: AppTypography.titleS.copyWith(
            color: c.textPrimary,
            fontSize: 15,
            height: 22 / 15,
          ),
        ),
        ItemMark(item),
      ],
    );
  }
}

/// Price in gold, tabular and whole, with its currency.
class PriceText extends StatelessWidget {
  const PriceText(this.amount, {super.key, this.size = 19});

  final String amount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Semantics(
      label: '$amount ${l10n.currencyEgp}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          LtrText(
            amount,
            style: AppTypography.price.copyWith(
              color: c.accentText,
              fontSize: size,
              height: 24 / size,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            l10n.currencyShort,
            style: AppTypography.labelS.copyWith(color: c.accentText),
          ),
        ],
      ),
    );
  }
}

/// Dense package row: family tile, name, "quota · validity", and the price
/// column with the subscription code under it.
class PackageRow extends StatelessWidget {
  const PackageRow({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final line = PackageLine.of(item, l10n);
    final large = MediaQuery.textScalerOf(context).scale(1) > 1.35;

    final name = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RowTitle(item),
        if (line.details.isNotEmpty)
          ProseText(
            line.details,
            style: AppTypography.bodyS.copyWith(
              color: c.textSecondary,
              fontFeatures: AppTypography.tabular,
            ),
          ),
      ],
    );

    final price = line.price;
    final code = line.code;
    final end = [
      if (price != null)
        PriceText(price, key: ValueKey('price-${item.id}'))
      else
        Text(
          l10n.packageNoPriceShort,
          style: AppTypography.labelS.copyWith(color: c.textTertiary),
        ),
      if (code != null)
        CodeValue(
          code,
          key: ValueKey('code-${item.id}'),
          style: AppTypography.code.copyWith(
            color: c.textSecondary,
            fontSize: 12,
            height: 16 / 12,
            letterSpacing: 0,
          ),
        ),
    ];

    return _RowFrame(
      item: item,
      child: Row(
        children: [
          FamilyTile(familyOf(item)),
          const SizedBox(width: AppSpacing.sm),
          // Large text: price and code drop under the name.
          if (large)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  name,
                  Wrap(
                    spacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: end,
                  ),
                ],
              ),
            )
          else ...[
            Expanded(child: name),
            const SizedBox(width: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: end,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The value a code / hotline row shows: the first phone of a contact, the
/// first code otherwise.
String? leadCode(ContentItem i) {
  final values = i.type == ItemType.contact
      ? [...i.phones, ...i.codes]
      : [...i.codes, ...i.phones];
  return values.firstOrNull;
}

/// Dense code / hotline row: name, the whole value, dial and copy.
class CodeRow extends StatelessWidget {
  const CodeRow({super.key, required this.item, required this.value});

  final ContentItem item;
  final String value;

  /// `*777*1# — تحويل أموال` repeats the code; show the words only.
  static String nameOf(ContentItem i) {
    final parts = i.title.split(RegExp(r'\s+[—–-]\s+'));
    return parts.length > 1 && RegExp(r'^[*#0-9]+$').hasMatch(parts.first)
        ? parts.skip(1).join(' — ')
        : i.title;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _RowFrame(
      item: item,
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.sm,
        AppSpacing.xxs + 2,
        AppSpacing.xxs,
        AppSpacing.xxs + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RowTitle(item, title: nameOf(item)),
                CodeValue(
                  value,
                  style: AppTypography.code.copyWith(
                    color: c.primary,
                    fontSize: 17,
                    height: 24 / 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          CodeActions(value, onCall: (v) => launchDial(context, v)),
        ],
      ),
    );
  }
}

/// First price fact worth quoting next to a title (fees, services).
Fact? _leadPrice(ContentItem item) {
  for (final f in item.facts) {
    if (f.kind == FactKind.price && f.rendersLtr && !f.isBlank) return f;
  }
  return null;
}

/// Dense row of any other item: title, short summary, price at the end.
class ArticleRow extends StatelessWidget {
  const ArticleRow({
    super.key,
    required this.item,
    this.snippet,
    this.highlights = const [],
    this.sectionLabel,
  });

  final ContentItem item;
  final String? snippet;
  final List<Highlight> highlights;
  final String? sectionLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final price = _leadPrice(item);
    final style = AppTypography.bodyS.copyWith(
      color: c.textSecondary,
      fontSize: 13,
      height: 20 / 13,
    );
    return _RowFrame(
      item: item,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RowTitle(item),
                if (snippet != null)
                  HighlightedText(snippet!, highlights: highlights, style: style)
                else if (item.summary.isNotEmpty)
                  ProseText(clipWords(item.summary), style: style),
                if (sectionLabel != null)
                  Text(
                    sectionLabel!,
                    style: AppTypography.labelS.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          if (price != null)
            PriceText(price.value, size: 17)
          else
            Icon(
              AppIcons.chevron, // mirrors in RTL
              size: AppIconSize.action,
              color: c.textTertiary,
            ),
        ],
      ),
    );
  }
}

/// The right dense row for [item]: package, code / hotline, or article.
/// Meant to sit inside a `ListSurface`.
class ContentItemRow extends StatelessWidget {
  const ContentItemRow({
    super.key,
    required this.item,
    this.showSection = false,
    this.snippet,
    this.highlights = const [],
  });

  final ContentItem item;

  /// Name the section (mixed lists such as search results).
  final bool showSection;

  /// Search snippet replacing the summary of an article row.
  final String? snippet;
  final List<Highlight> highlights;

  @override
  Widget build(BuildContext context) {
    if (item.type == ItemType.package) return PackageRow(item: item);
    final code = leadCode(item);
    if (code != null &&
        (item.type == ItemType.code || item.type == ItemType.contact)) {
      return CodeRow(item: item, value: code);
    }
    return ArticleRow(
      item: item,
      snippet: snippet,
      highlights: highlights,
      sectionLabel: showSection
          ? item.section.title(AppLocalizations.of(context))
          : null,
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

/// Header of a group of rows: name and count on one line.
class GroupHeader extends StatelessWidget {
  const GroupHeader(this.title, {super.key, this.count, this.trailing});

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Flexible(
            child: Semantics(
              header: true,
              child: Text(
                title,
                key: ValueKey('group-$title'),
                style: AppTypography.titleM.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$count',
              key: ValueKey('group-count-$title'),
              style: AppTypography.labelL.copyWith(
                color: c.textTertiary,
                fontFeatures: AppTypography.tabular,
              ),
            ),
          ],
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}
