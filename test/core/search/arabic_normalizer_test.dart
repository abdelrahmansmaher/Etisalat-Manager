import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/search/arabic_normalizer.dart';

void main() {
  String n(String s) => normalizeArabic(s);

  group('golden fixture (shared with SQL)', () {
    final file = File('test/core/search/fixtures/normalizer_cases.json');
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final cases = (data['cases'] as List).cast<Map<String, dynamic>>();

    test('fixture is non-trivial and names are unique', () {
      expect(cases.length, greaterThanOrEqualTo(40));
      final names = cases.map((c) => c['name']).toSet();
      expect(names.length, cases.length);
    });

    for (final c in cases) {
      final input = c['input'] as String;
      final expected = c['expected'] as String;
      test('${c['name']}', () {
        expect(n(input), expected);
        // Expected outputs must themselves be fixed points.
        expect(n(expected), expected);
      });
    }
  });

  group('alef / yeh / teh / hamza folding', () {
    test('all alef variants become bare alef', () {
      expect(n('أ إ آ ٱ ا'), 'ا ا ا ا ا');
    });
    test('alef maqsura and farsi yeh become yeh', () {
      expect(n('على'), 'علي');
      expect(n('فی'), 'في');
    });
    test('teh marbuta becomes heh', () {
      expect(n('شريحة'), 'شريحه');
      expect(n('شريحة'), n('شريحه'));
    });
    test('hamza on carriers folds, standalone hamza stays', () {
      expect(n('سؤال'), 'سوال');
      expect(n('طائرة'), 'طايره');
      expect(n('جزء'), 'جزء');
    });
    test('common spelling variants meet', () {
      expect(n('إنترنت'), n('انترنت'));
      expect(n('الفاتورة'), n('الفاتوره'));
      expect(n('مستشفى'), n('مستشفي'));
    });
  });

  group('marks and invisible characters', () {
    test('every tashkeel mark U+064B..U+065F is removed', () {
      for (var c = 0x064B; c <= 0x065F; c++) {
        expect(
          n('ب${String.fromCharCode(c)}ت'),
          'بت',
          reason: 'U+${c.toRadixString(16)}',
        );
      }
    });
    test('quranic marks range removed', () {
      for (var c = 0x06D6; c <= 0x06ED; c++) {
        expect(
          n('ب${String.fromCharCode(c)}ت'),
          'بت',
          reason: 'U+${c.toRadixString(16)}',
        );
      }
    });
    test('tatweel removed, including inside elongated words', () {
      expect(n('مـــرحـــبـــا'), 'مرحبا');
    });
    test('invisible format characters removed', () {
      const invisible = [
        0x200B, 0x200C, 0x200D, 0x200E, 0x200F, 0x202A, 0x202B, 0x202C, //
        0x202D, 0x202E, 0x2066, 0x2067, 0x2068, 0x2069, 0xFEFF,
      ];
      for (final c in invisible) {
        expect(
          n('ن${String.fromCharCode(c)}ت'),
          'نت',
          reason: 'U+${c.toRadixString(16)}',
        );
      }
    });
  });

  group('digits', () {
    test('arabic-indic and persian digits map to ascii', () {
      for (var d = 0; d < 10; d++) {
        expect(n(String.fromCharCode(0x0660 + d)), '$d');
        expect(n(String.fromCharCode(0x06F0 + d)), '$d');
      }
    });
    test('mixed digit scripts in one number', () {
      expect(n('٠1۲3'), '0123');
    });
    test('arabic decimal separator is left for the classifier', () {
      expect(n('١٫٥'), '1٫5');
    });
    test('franco-arabic digits inside words are not converted', () {
      expect(n('7elw 3ala 2ad'), '7elw 3ala 2ad');
      expect(n('4G 5G'), '4g 5g');
    });
    test('long digit runs are never collapsed', () {
      expect(n('1000000'), '1000000');
      expect(n('٠٠٠٠'), '0000');
    });
  });

  group('punctuation, case and whitespace', () {
    test('arabic punctuation converted, other punctuation kept', () {
      expect(n('أ، ب؛ ج؟'), 'ا, ب; ج?');
      expect(n('*#+&.-'), '*#+&.-');
    });
    test('latin is lowercased, including accented letters', () {
      expect(n('Internet DATA'), 'internet data');
      expect(n('ÉCOLE'), 'école');
    });
    test('whitespace is collapsed and trimmed', () {
      expect(n('\t a \n\n b \r\n'), 'a b');
      expect(n('a 　b'), 'a b');
    });
    test('zero width space joins rather than splits', () {
      expect(n('ab​cd'), 'abcd');
    });
    test('empty and whitespace-only input', () {
      expect(n(''), '');
      expect(n('   '), '');
      expect(n('​‏'), '');
      expect(n('ـــ'), '');
    });
  });

  group('elongation', () {
    test('three or more identical arabic letters collapse to one', () {
      expect(n('جمييييل'), 'جميل');
      expect(n('ممم'), 'م');
    });
    test('two identical letters are kept', () {
      expect(n('مدد'), 'مدد');
      expect(n('للتحويل'), 'للتحويل');
    });
    test('runs do not cross spaces', () {
      expect(n('اا ا'), 'اا ا');
    });
  });

  group('presentation forms', () {
    test('every letter shape in U+FE80..U+FEF4 maps to an arabic letter', () {
      for (var c = 0xFE80; c <= 0xFEF4; c++) {
        final out = n(String.fromCharCode(c));
        expect(out.length, 1, reason: 'U+${c.toRadixString(16)}');
        final u = out.codeUnitAt(0);
        expect(
          u >= 0x0621 && u <= 0x064A,
          isTrue,
          reason: 'U+${c.toRadixString(16)}',
        );
      }
    });
    test('alef/teh/yeh shapes are folded too', () {
      expect(n('ﺃ'), 'ا'); // isolated alef hamza
      expect(n('ﺓ'), 'ه'); // isolated teh marbuta
      expect(n('ﻯ'), 'ي'); // isolated alef maqsura
    });
    test('all lam-alef ligatures become لا', () {
      for (var c = 0xFEF5; c <= 0xFEFC; c++) {
        expect(n(String.fromCharCode(c)), 'لا');
      }
    });
    test('allah ligature and spacing tashkeel forms', () {
      expect(n('ﷲ'), 'الله');
      expect(n('بﹰت'), 'ب ت');
      expect(n('بﹱت'), 'بت');
    });
  });

  group('idempotency', () {
    const samples = [
      'أَهْلًا بِكُمْ فِي الـبـاقـــة الجديدة!!',
      'عااااجل: رصيد ٥٠ ج.م، *٩٩٩# أو +٢٠ ١٠٠ ٠٠٠ ٠٠٠٠',
      'اأإآ ههههه ىیيى',
      'ﻻﻷ ﷲ ＳＩＭ',
      'Mixed Arabic عربي and ENGLISH   text‏',
      'ئؤء ة ک ٱ',
      '',
      '   ',
    ];
    for (final s in samples) {
      test('normalize(normalize(x)) == normalize(x) for "$s"', () {
        final once = n(s);
        expect(n(once), once);
      });
    }
    test(
      'every BMP character, alone and tripled, is a fixed point after one pass',
      () {
        for (var c = 0; c < 0xD800; c++) {
          final ch = String.fromCharCode(c);
          final once = n('$ch$ch$ch a$ch');
          expect(n(once), once, reason: 'U+${c.toRadixString(16)}');
        }
      },
    );
  });
}
