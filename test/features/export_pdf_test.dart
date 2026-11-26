import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/features/export/export_pdf.dart';
import 'package:knowledge_hub/features/export/export_sheet.dart';
import 'package:knowledge_hub/features/tools/package_info.dart';
import 'package:knowledge_hub/features/tools/value_logic.dart';
import 'package:knowledge_hub/l10n/app_localizations.dart';

/// Every kind of PDF builds from the real content, in Arabic and English.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ContentLibrary lib;

  setUpAll(() async {
    await initializeDateFormatting();
    lib = await ContentLoader.load(
      MemoryContentSource({
        for (final s in ContentSection.values)
          s: File(s.assetPath).readAsStringSync(),
      }),
    );
  });

  bool isPdf(List<int> b) =>
      b.length > 1000 && String.fromCharCodes(b.take(5)) == '%PDF-';

  for (final lang in ['ar', 'en']) {
    test('item, comparison and list PDFs ($lang)', () async {
      final l10n = lookupAppLocalizations(Locale(lang));
      final pdf = await PdfExport.create(l10n, now: DateTime(2026, 11, 26));
      final packages = [
        for (final i in lib.all)
          if (i.type == ItemType.package) PackageInfo.of(i),
      ];
      final procedure = lib.all.firstWhere((i) => i.steps.isNotEmpty);

      final one = await pdf.item(packages.first.item);
      final steps = await pdf.item(procedure);
      final hekaya = [
        for (final id in const [52, 69, 92, 120])
          packages.firstWhere((p) => p.item.id == 'pkg-hekaya-mixat-$id'),
      ];
      final value = compareValue(hekaya);
      expect(value, isNotNull);
      final compare = await pdf.comparison(hekaya, value: value);
      final list = await pdf.list(
        'Section',
        lib.itemsOf(ContentSection.numbers),
      );
      for (final b in [one, steps, compare, list]) {
        expect(isPdf(b), isTrue);
      }
      final out = Platform.environment['PDF_SAMPLES'];
      if (out != null) {
        File('$out/item-$lang.pdf').writeAsBytesSync(one);
        File('$out/steps-$lang.pdf').writeAsBytesSync(steps);
        File('$out/compare-$lang.pdf').writeAsBytesSync(compare);
        File('$out/list-$lang.pdf').writeAsBytesSync(list);
      }
    });
  }

  test('file names drop characters file systems refuse', () {
    expect(pdfFileName('باقة 5/10: "جديد"'), 'N-Core - باقة 510 جديد.pdf');
  });
}
