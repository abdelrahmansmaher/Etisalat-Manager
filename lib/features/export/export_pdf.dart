// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/content/content_models.dart';
import '../../core/widgets/trust/trust_format.dart';
import '../../l10n/app_identity.dart';
import '../../l10n/app_localizations.dart';
import '../content/package_family.dart';
import '../tools/compare_logic.dart';
import '../tools/package_info.dart';
import '../tools/value_logic.dart';

/// Builds the app's PDF documents: one item, a package comparison, or a
/// list of items. Every page has the N-Core header band, the date it was
/// issued and page numbers; Arabic is laid out right to left in the app's
/// own fonts (IBM Plex Sans Arabic, IBM Plex Mono for codes).
class PdfExport {
  PdfExport._(this._l10n, this._fonts, this._issued);

  /// Loads the fonts once per export.
  static Future<PdfExport> create(
    AppLocalizations l10n, {
    DateTime? now,
  }) async {
    Future<pw.Font> font(String file) async =>
        pw.Font.ttf(await rootBundle.load('assets/fonts/$file'));
    final fonts = _Fonts(
      regular: await font('IBMPlexSansArabic-Regular.ttf'),
      medium: await font('IBMPlexSansArabic-SemiBold.ttf'),
      bold: await font('IBMPlexSansArabic-Bold.ttf'),
      mono: await font('IBMPlexMono-SemiBold.ttf'),
    );
    // The content is Arabic, so the page is always Arabic and right to
    // left, whatever language the app is shown in.
    final arabic = l10n.localeName.startsWith('ar')
        ? l10n
        : lookupAppLocalizations(const Locale('ar'));
    return PdfExport._(arabic, fonts, now ?? DateTime.now());
  }

  final AppLocalizations _l10n;
  final _Fonts _fonts;
  final DateTime _issued;

  String get _date {
    try {
      return TrustFormat.date(_issued, Locale(_l10n.localeName));
    } catch (_) {
      final d = _issued;
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
    }
  }

  bool get _rtl => _l10n.localeName.startsWith('ar');

  // ---- Palette (matches the app) ----------------------------------------
  static const _navy = PdfColor.fromInt(0xFF14246B);
  static const _navyDeep = PdfColor.fromInt(0xFF0A1340);
  static const _ink = PdfColor.fromInt(0xFF101828);
  static const _muted = PdfColor.fromInt(0xFF5B6478);
  static const _hair = PdfColor.fromInt(0xFFE3E7F0);
  static const _zebra = PdfColor.fromInt(0xFFF5F7FB);
  static const _gold = PdfColor.fromInt(0xFF9A6A00);
  static const _goldSoft = PdfColor.fromInt(0xFFFFF6DD);
  static const _green = PdfColor.fromInt(0xFF137A3A);
  static const _greenSoft = PdfColor.fromInt(0xFFE6F6EC);
  static const _bestSoft = PdfColor.fromInt(0xFFE8EEFF);

  /// One item: title, price, every stated value, steps, codes, source.
  Future<Uint8List> item(ContentItem item) async {
    final doc = _doc(item.title);
    final facts = [
      for (final f in item.facts)
        if (!f.isBlank) f,
    ];
    final price = item.type == ItemType.package ? PackageInfo.of(item) : null;
    final summary = _strip(item.summary);
    final body = item.body == null ? '' : _plain(item.body!);
    final stated = facts.map((f) => f.display).join(' ');
    final extra = [
      for (final v in [...item.codes, ...item.phones])
        if (!stated.contains(v) && !summary.contains(v)) v,
    ];
    final source = item.sources.isEmpty ? null : item.sources.first;

    doc.addPage(
      _page(
        build: (context) => [
          _titleBlock(
            item.title,
            [
              if (item.category.isNotEmpty) _plain(item.category),
              if (item.family != null && item.family!.isNotEmpty)
                _plain(item.family!),
            ].join('  •  '),
            confirmed: item.status == ItemStatus.confirmed && !item.userEdited,
          ),
          if (price?.priceText != null) ...[
            pw.SizedBox(height: 14),
            _priceBox(price!),
          ],
          if (summary.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _paragraph(_plain(item.summary)),
          ],
          if (facts.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _heading(_l10n.exportDetails),
            pw.SizedBox(height: 6),
            _factTable([
              for (final f in facts)
                (
                  _plain(f.label),
                  f.rendersLtr ? _strip(f.display) : _plain(f.display),
                  f.rendersLtr,
                ),
            ]),
          ],
          if (item.steps.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _heading(_l10n.exportSteps),
            pw.SizedBox(height: 6),
            for (final (i, s) in item.steps.indexed) _step(i + 1, _plain(s)),
          ],
          if (extra.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _heading(_l10n.exportCodes),
            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final v in extra) _codeChip(v)],
            ),
          ],
          if (body.isNotEmpty) ...[pw.SizedBox(height: 18), _paragraph(body)],
          if (source != null) ...[pw.SizedBox(height: 22), _sourceLine(source)],
        ],
      ),
    );
    return doc.save();
  }

  /// Packages side by side, the best value of each row marked.
  Future<Uint8List> comparison(
    List<PackageInfo> packages, {
    ValueRanking? value,
  }) async {
    final doc = _doc(_l10n.toolsCompareTitle);
    final rows = compareRows(packages);
    final differs = periodsDiffer(packages);
    final wide = packages.length > 3;
    doc.addPage(
      _page(
        landscape: wide,
        build: (context) => [
          _titleBlock(
            _l10n.toolsCompareTitle,
            packages.map((p) => _plain(p.item.title)).join('  •  '),
          ),
          pw.SizedBox(height: 16),
          if (value != null) ...[_valueBox(value), pw.SizedBox(height: 14)],
          _compareTable(packages, rows),
          if (differs) ...[
            pw.SizedBox(height: 10),
            _note(_l10n.toolsComparePeriods),
          ],
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Container(
                width: 10,
                height: 10,
                decoration: const pw.BoxDecoration(
                  color: _bestSoft,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                _l10n.exportBestMark,
                style: pw.TextStyle(fontSize: 9, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  /// A list of items (a section, favourites): each with its key values.
  Future<Uint8List> list(String title, List<ContentItem> items) async {
    final doc = _doc(title);
    doc.addPage(
      _page(
        build: (context) => [
          _titleBlock(title, _l10n.exportItemCount(items.length)),
          pw.SizedBox(height: 14),
          for (final item in items) _listEntry(item),
        ],
      ),
    );
    return doc.save();
  }

  // ---- Page frame --------------------------------------------------------

  pw.Document _doc(String title) => pw.Document(
    title: '$title · ${AppIdentity.nameEn}',
    author: AppIdentity.nameEn,
    creator: AppIdentity.nameEn,
  );

  pw.MultiPage _page({
    required pw.BuildListCallback build,
    bool landscape = false,
  }) {
    final format = landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
    return pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: format,
        margin: const pw.EdgeInsets.fromLTRB(36, 0, 36, 28),
        textDirection: _rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme:
            pw.ThemeData.withFont(
              base: _fonts.regular,
              bold: _fonts.bold,
              fontFallback: [_fonts.mono],
            ).copyWith(
              defaultTextStyle: pw.TextStyle(
                font: _fonts.regular,
                fontBold: _fonts.bold,
                fontSize: 11,
                color: _ink,
                lineSpacing: 3,
                // Arabic letters that end a word (ر، د، و...) reach into
                // the gap after them; a wider gap keeps words apart.
                wordSpacing: _rtl ? 2.2 : 1,
              ),
            ),
      ),
      header: (context) => _header(),
      footer: (context) => _footer(context),
      build: build,
    );
  }

  pw.Widget _header() => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 20),
    padding: const pw.EdgeInsets.fromLTRB(18, 26, 18, 14),
    decoration: const pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [_navy, _navyDeep],
        begin: pw.Alignment.topLeft,
        end: pw.Alignment.bottomRight,
      ),
      borderRadius: pw.BorderRadius.only(
        bottomLeft: pw.Radius.circular(14),
        bottomRight: pw.Radius.circular(14),
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _mark(),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${AppIdentity.nameAr}  ·  ${AppIdentity.nameEn}',
                style: pw.TextStyle(
                  font: _fonts.bold,
                  fontSize: 15,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                _l10n.exportTagline,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColor.fromInt(0xCCFFFFFF),
                ),
              ),
            ],
          ),
        ),
        _rich(
          _date,
          const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xCCFFFFFF)),
        ),
      ],
    ),
  );

  /// The app's N mark: a rounded tile with a bold N.
  pw.Widget _mark() => pw.Container(
    width: 30,
    height: 30,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      color: const PdfColor.fromInt(0xFF2B3C8F),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(9)),
      border: pw.Border.all(color: const PdfColor.fromInt(0xFF5566B0)),
    ),
    child: pw.Text(
      'N',
      textDirection: pw.TextDirection.ltr,
      style: pw.TextStyle(
        font: _fonts.bold,
        fontSize: 16,
        color: PdfColors.white,
      ),
    ),
  );

  pw.Widget _footer(pw.Context context) => pw.Container(
    padding: const pw.EdgeInsets.only(top: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _hair)),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            _l10n.exportFooter(AppIdentity.nameAr),
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ),
        pw.Text(
          _l10n.exportPage(context.pageNumber, context.pagesCount),
          style: const pw.TextStyle(fontSize: 8, color: _muted),
        ),
      ],
    ),
  );

  // ---- Blocks ------------------------------------------------------------

  pw.Widget _titleBlock(String title, String sub, {bool confirmed = false}) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _rich(
                  _plain(title),
                  pw.TextStyle(font: _fonts.bold, fontSize: 20, color: _ink),
                ),
              ),
              if (confirmed) ...[
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: const pw.BoxDecoration(
                    color: _greenSoft,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text(
                    _l10n.exportConfirmed,
                    style: pw.TextStyle(
                      font: _fonts.medium,
                      fontSize: 9,
                      color: _green,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (sub.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            _rich(sub, const pw.TextStyle(fontSize: 10, color: _muted)),
          ],
        ],
      );

  pw.Widget _priceBox(PackageInfo p) {
    pw.Widget cell(
      String label,
      String value, {
      bool main = false,
      bool ltr = false,
    }) => pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _rich(label, const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            textDirection: ltr ? pw.TextDirection.ltr : null,
            style: pw.TextStyle(
              font: ltr ? _fonts.mono : _fonts.bold,
              fontFallback: [_fonts.bold],
              fontSize: main ? 22 : 15,
              color: main ? _gold : (ltr ? _navy : _ink),
            ),
          ),
        ],
      ),
    );
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _goldSoft,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: const PdfColor.fromInt(0x339A6A00)),
      ),
      child: pw.Row(
        children: [
          cell(_l10n.toolsRowPrice, _plain(p.priceText!), main: true),
          if (p.totalText != null && p.totalText != p.priceText)
            cell(_l10n.toolsRowTotal, _plain(p.totalText!)),
          if (p.validityText != null)
            cell(_l10n.toolsRowValidity, _plain(p.validityText!)),
          if (p.codeText != null)
            cell(_l10n.toolsRowCode, _strip(p.codeText!), ltr: true),
        ],
      ),
    );
  }

  pw.Widget _heading(String text) => pw.Row(
    children: [
      pw.Container(
        width: 4,
        height: 14,
        decoration: const pw.BoxDecoration(
          color: _navy,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
        ),
      ),
      pw.SizedBox(width: 6),
      _rich(text, pw.TextStyle(font: _fonts.bold, fontSize: 13, color: _navy)),
    ],
  );

  pw.Widget _paragraph(String text) => _rich(
    text,
    const pw.TextStyle(fontSize: 11, color: _ink, lineSpacing: 4),
  );

  pw.Widget _factTable(List<(String, String, bool)> rows) => pw.Container(
    decoration: pw.BoxDecoration(
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      border: pw.Border.all(color: _hair),
    ),
    padding: const pw.EdgeInsets.all(1),
    child: pw.Column(
      children: [
        for (final (i, (label, value, ltr)) in rows.indexed)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: pw.BoxDecoration(
              color: i.isOdd ? _zebra : null,
              border: i == 0
                  ? null
                  : const pw.Border(top: pw.BorderSide(color: _hair)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 150,
                  child: _rich(
                    label,
                    const pw.TextStyle(fontSize: 10, color: _muted),
                  ),
                ),
                pw.Expanded(
                  child: ltr
                      ? pw.Align(
                          alignment: _rtl
                              ? pw.Alignment.centerRight
                              : pw.Alignment.centerLeft,
                          child: pw.Text(
                            value,
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(
                              font: _fonts.mono,
                              fontFallback: [_fonts.medium],
                              fontSize: 11,
                              color: _navy,
                            ),
                          ),
                        )
                      : _rich(
                          value,
                          pw.TextStyle(font: _fonts.medium, fontSize: 11),
                        ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  pw.Widget _step(int n, String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 20,
          height: 20,
          alignment: pw.Alignment.center,
          decoration: const pw.BoxDecoration(
            color: _navy,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Text(
            '$n',
            style: pw.TextStyle(
              font: _fonts.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _paragraph(text)),
      ],
    ),
  );

  pw.Widget _codeChip(String v) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: pw.BoxDecoration(
      color: _zebra,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: _hair),
    ),
    child: pw.Text(
      _strip(v),
      textDirection: pw.TextDirection.ltr,
      style: pw.TextStyle(font: _fonts.mono, fontSize: 11, color: _navy),
    ),
  );

  pw.Widget _note(String text) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: const PdfColor.fromInt(0xFFFFF4E5),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: const PdfColor.fromInt(0x33C2560C)),
    ),
    child: _rich(
      text,
      const pw.TextStyle(fontSize: 9.5, color: PdfColor.fromInt(0xFF7A3A06)),
    ),
  );

  pw.Widget _sourceLine(Source s) => pw.Text(
    [
      '${_l10n.exportSource}: ${_plain(s.name)}',
      if (s.checkedAt != null) '${_l10n.exportVerified}: ${s.checkedAt}',
    ].join('   •   '),
    style: const pw.TextStyle(fontSize: 8.5, color: _muted),
  );

  /// The value-for-money verdict: winner, unit price, lead, and a bar per
  /// package.
  pw.Widget _valueBox(ValueRanking r) {
    const violet = PdfColor.fromInt(0xFF6D28D9);
    const violetSoft = PdfColor.fromInt(0xFFF3EEFF);
    final best = r.best;
    final lead = r.leadOverNext;
    String line(ValueScore s) {
      final cost = unitCostText(r, s);
      return switch (r.basis) {
        ValueBasis.gb => _l10n.valuePerGb(cost),
        ValueBasis.minute => _l10n.valuePerMinute(cost),
        ValueBasis.mix => _l10n.valuePerMix(cost),
      };
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: violetSoft,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFD9CCFB)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _rich(
            _l10n.valueTitle,
            pw.TextStyle(font: _fonts.bold, fontSize: 13, color: violet),
          ),
          pw.SizedBox(height: 4),
          _rich(
            best.package.item.title,
            pw.TextStyle(font: _fonts.bold, fontSize: 15, color: _ink),
          ),
          _rich(
            [
              line(best),
              if (r.tie)
                _l10n.valueTie
              else if (lead != null && lead >= 0.005)
                _l10n.valueLead('${(lead * 100).round()}'),
            ].join('  •  '),
            pw.TextStyle(font: _fonts.medium, fontSize: 10.5, color: _ink),
          ),
          pw.SizedBox(height: 8),
          for (final s in r.scores)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 150,
                    child: _rich(
                      s.package.item.title,
                      pw.TextStyle(
                        font: identical(s, best) ? _fonts.bold : _fonts.regular,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.LayoutBuilder(
                      builder: (context, box) => pw.Stack(
                        children: [
                          pw.Container(
                            height: 7,
                            decoration: const pw.BoxDecoration(
                              color: PdfColor.fromInt(0xFFE6DDFB),
                              borderRadius: pw.BorderRadius.all(
                                pw.Radius.circular(4),
                              ),
                            ),
                          ),
                          pw.Container(
                            width:
                                box!.maxWidth *
                                (best.unitCost / s.unitCost).clamp(0.06, 1.0),
                            height: 7,
                            decoration: pw.BoxDecoration(
                              color: identical(s, best)
                                  ? violet
                                  : const PdfColor.fromInt(0xFFB39BEF),
                              borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.SizedBox(
                    width: 60,
                    child: _rich(
                      unitCostText(r, s),
                      pw.TextStyle(font: _fonts.medium, fontSize: 9.5),
                    ),
                  ),
                ],
              ),
            ),
          pw.SizedBox(height: 2),
          _rich(
            [
              switch (r.basis) {
                ValueBasis.gb => _l10n.valueBasisGb,
                ValueBasis.minute => _l10n.valueBasisMinute,
                ValueBasis.mix => _l10n.valueBasisMix,
              },
              r.paysTotal ? _l10n.valuePriceTotal : _l10n.valuePriceBefore,
            ].join(' · '),
            const pw.TextStyle(fontSize: 8.5, color: _muted),
          ),
        ],
      ),
    );
  }

  pw.Widget _compareTable(
    List<PackageInfo> packages,
    List<CompareValues> rows,
  ) {
    const labelWidth = 92.0;
    pw.Widget cell(pw.Widget child, {PdfColor? color, bool label = false}) =>
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          color: color,
          child: child,
        );
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _hair),
      ),
      child: pw.Table(
        columnWidths: {
          0: const pw.FixedColumnWidth(labelWidth),
          for (var i = 0; i < packages.length; i++)
            i + 1: const pw.FlexColumnWidth(),
        },
        border: const pw.TableBorder(
          horizontalInside: pw.BorderSide(color: _hair),
          verticalInside: pw.BorderSide(color: _hair),
        ),
        children: [
          pw.TableRow(
            children: [
              cell(
                pw.Text(
                  _l10n.toolsRowPackage,
                  style: const pw.TextStyle(fontSize: 9, color: _muted),
                ),
              ),
              for (final p in packages)
                cell(
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(
                            FamilyStyle.of(p.family).color.toARGB32(),
                          ),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(6),
                          ),
                        ),
                        child: _rich(
                          _plain(p.family),
                          pw.TextStyle(
                            font: _fonts.medium,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      _rich(
                        _plain(p.item.title),
                        pw.TextStyle(
                          font: _fonts.bold,
                          fontSize: 10.5,
                          color: _navy,
                        ),
                      ),
                    ],
                  ),
                  color: _zebra,
                ),
            ],
          ),
          for (final r in rows)
            pw.TableRow(
              children: [
                cell(
                  _rich(
                    compareRowLabel(_l10n, r.row),
                    const pw.TextStyle(fontSize: 9.5, color: _muted),
                  ),
                ),
                for (var i = 0; i < packages.length; i++)
                  cell(
                    _compareValue(r, i),
                    color: r.best.contains(i) ? _bestSoft : null,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  pw.Widget _compareValue(CompareValues r, int i) {
    final text = r.texts[i];
    final best = r.best.contains(i);
    final isPrice = r.row == CompareRow.price || r.row == CompareRow.total;
    final badge = best ? compareBestBadge(_l10n, r.row) : null;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _rich(
          text == null ? '—' : _plain(text),
          pw.TextStyle(
            font: best || isPrice ? _fonts.bold : _fonts.medium,
            fontSize: 10.5,
            color: text == null ? _muted : (isPrice ? _gold : _ink),
          ),
        ),
        if (badge != null)
          _rich(
            badge,
            pw.TextStyle(font: _fonts.medium, fontSize: 8, color: _navy),
          ),
      ],
    );
  }

  pw.Widget _listEntry(ContentItem item) {
    final p = item.type == ItemType.package ? PackageInfo.of(item) : null;
    final facts = [
      for (final f in item.facts)
        if (!f.isBlank) '${_plain(f.label)}: ${_plain(f.display)}',
    ].take(4).toList();
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _hair),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _rich(
                  _plain(item.title),
                  pw.TextStyle(font: _fonts.bold, fontSize: 11.5),
                ),
                if (facts.isEmpty && item.summary.isNotEmpty)
                  _rich(
                    item.summary,
                    const pw.TextStyle(fontSize: 9.5, color: _muted),
                  ),
                for (final f in facts)
                  _rich(f, const pw.TextStyle(fontSize: 9.5, color: _muted)),
              ],
            ),
          ),
          if (p?.priceText != null) ...[
            pw.SizedBox(width: 10),
            _rich(
              _plain(p!.priceText!),
              pw.TextStyle(font: _fonts.bold, fontSize: 14, color: _gold),
            ),
          ],
        ],
      ),
    );
  }

  /// Without the invisible direction marks used on screen: the PDF lays
  /// codes out itself and the fonts have no glyph for them.
  static String _strip(String s) =>
      s.replaceAll(RegExp('[\u200E\u200F\u202A-\u202E\u2066-\u2069]'), '');

  String _plain(String s) => _strip(s);

  /// Text that may hold codes. Inside Arabic, the PDF engine's bidi pass
  /// would print `*319*52#` as `#52*319*`, so each code is set as its own
  /// left-to-right piece within the sentence.
  pw.Widget _rich(String text, pw.TextStyle style) {
    final t = _strip(text);
    if (!_rtl || !_arabic.hasMatch(t) || !_ltrRun.hasMatch(t)) {
      return pw.Text(t, style: style);
    }
    final spans = <pw.InlineSpan>[];
    var at = 0;
    for (final m in _ltrRun.allMatches(t)) {
      if (m.start > at) {
        spans.add(pw.TextSpan(text: t.substring(at, m.start)));
      }
      final run = m[0]!;
      final code = _code.hasMatch(run) && !run.contains(RegExp('[A-Za-z]'));
      spans.add(
        pw.WidgetSpan(
          // Sits on the Arabic line, not above it.
          baseline: -(style.fontSize ?? 11) * 0.42,
          child: pw.Text(
            run,
            textDirection: pw.TextDirection.ltr,
            style: code
                ? style.copyWith(
                    font: _fonts.mono,
                    fontFallback: [_fonts.medium],
                    color: _navy,
                  )
                : style,
          ),
        ),
      );
      at = m.end;
    }
    if (at < t.length) spans.add(pw.TextSpan(text: t.substring(at)));
    return pw.RichText(
      text: pw.TextSpan(style: style, children: spans),
    );
  }

  static final RegExp _arabic = RegExp('[\u0600-\u06FF]');
  static final RegExp _code = RegExp(
    r'[*#][0-9*#]*[0-9][0-9*#]*|[0-9][0-9*]*[*#][0-9*#]*',
  );

  /// Pieces that read left to right inside Arabic: codes (`*319*52#`) and
  /// Latin names with `&` (`My e&`), which bidi would scramble.
  static final RegExp _ltrRun = () {
    // One English word or name piece: e&, eHome, 5G, Smart...
    const word = r"&?[A-Za-z0-9][A-Za-z0-9&'+._-]*";
    // Words joined by spaces or / + : , stay one run: eHome DSL: 16511,
    // eHome / ADSL / DSL, twist Music.
    const latin =
        r"&?[A-Za-z][A-Za-z0-9&'+._-]*(?:(?:\s*[/+:,]\s*|\s+)" + word + r')*';
    return RegExp(
      // Codes: *319*52#, 9*1#
      r'[*#][0-9*#]*[0-9][0-9*#]*|[0-9][0-9*]*[*#][0-9*#]*'
              // Phone numbers with + or dashes: +201111234778, 02-35346333
              r'|\+\d[\d -]*\d|\d+(?:-\d+)+'
              // English in brackets keeps its brackets: (e& money)
              r'|\(' +
          latin +
          r'\)'
              r'|' +
          latin +
          r'|\d+[A-Za-z][A-Za-z0-9]*',
    );
  }();
}

class _Fonts {
  const _Fonts({
    required this.regular,
    required this.medium,
    required this.bold,
    required this.mono,
  });

  final pw.Font regular;
  final pw.Font medium;
  final pw.Font bold;
  final pw.Font mono;
}
