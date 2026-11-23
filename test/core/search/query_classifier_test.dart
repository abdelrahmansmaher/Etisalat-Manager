// All codes and numbers here are obviously fake test values.
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/search/query_classifier.dart';

void main() {
  QueryClassification c(String s) => QueryClassifier.classify(s);

  group('empty', () {
    for (final s in ['', '   ', '‏', '\t\n']) {
      test('"$s" is empty', () => expect(c(s).kind, QueryKind.empty));
    }
  });

  group('USSD', () {
    const complete = {
      '*999#': '*999#',
      '#999#': '#999#',
      '*999*1#': '*999*1#',
      '*999*1*2#': '*999*1*2#',
      '*٩٩٩#': '*999#',
      '*۹۹۹#': '*999#',
      '* 999 #': '*999#',
      ' *999# ': '*999#',
      '*‏999#': '*999#',
      '٭٩٩٩#': '*999#',
      '＊９９９＃': '*999#',
      '*#06#': '*#06#',
      '*999*01000000000#': '*999*01000000000#',
    };
    complete.forEach((input, canonical) {
      test('"$input" → $canonical (complete)', () {
        final r = c(input);
        expect(r.kind, QueryKind.ussd);
        expect(r.canonical, canonical);
        expect(r.lookupKeys.first, canonical);
        expect(r.isComplete, isTrue);
      });
    });

    test('missing trailing # is tolerated and added', () {
      final r = c('*999');
      expect(r.kind, QueryKind.ussd);
      expect(r.canonical, '*999#');
      expect(r.lookupKeys, ['*999#', '*999']);
      expect(r.isComplete, isFalse);
    });
    test('arabic digits with missing #', () {
      final r = c('* ٩٩٩ * ١');
      expect(r.canonical, '*999*1#');
      expect(r.isComplete, isFalse);
    });
    test('code still being typed after a star', () {
      final r = c('*999*');
      expect(r.kind, QueryKind.ussd);
      expect(r.canonical, '*999*');
      expect(r.isComplete, isFalse);
    });
    test('hash-prefixed without closing hash', () {
      expect(c('#999').canonical, '#999#');
    });

    for (final s in [
      '*',
      '#',
      '**',
      '*#',
      '#عروض',
      '*abc#',
      'كود *999#',
      '999#',
    ]) {
      test('"$s" is not a USSD code', () {
        expect(c(s).kind, isNot(QueryKind.ussd));
      });
    }
  });

  group('phone numbers', () {
    const mobiles = [
      '01000000000',
      '010 0000 0000',
      '010-0000-0000',
      '(010) 0000-0000',
      '٠١٠٠٠٠٠٠٠٠٠',
      '٠١٠ ٠٠٠٠ ٠٠٠٠',
      '+201000000000',
      '+20 100 000 0000',
      '+20 100-000-0000',
      '+٢٠١٠٠٠٠٠٠٠٠٠',
      '00201000000000',
      '0020 100 000 0000',
      '201000000000',
      '1000000000',
      '+20 01000000000',
    ];
    for (final s in mobiles) {
      test('"$s" is mobile 01000000000', () {
        final r = c(s);
        expect(r.kind, QueryKind.phone);
        expect(r.phoneType, PhoneType.mobile);
        expect(r.canonical, '01000000000');
        expect(r.lookupKeys, ['01000000000', '201000000000']);
        expect(r.isComplete, isTrue);
      });
    }

    test('other mobile prefix', () {
      expect(c('01200000000').phoneType, PhoneType.mobile);
      expect(c('01511111111').canonical, '01511111111');
    });

    const landlines = {
      '0200000000': '0200000000',
      '02 0000 0000': '0200000000',
      '02-00000000': '0200000000',
      '+20 2 0000 0000': '0200000000',
      '0400000000': '0400000000',
      '٠٤٠٠٠٠٠٠٠': '040000000',
    };
    landlines.forEach((input, canonical) {
      test('"$input" is landline $canonical', () {
        final r = c(input);
        expect(r.kind, QueryKind.phone);
        expect(r.phoneType, PhoneType.landline);
        expect(r.canonical, canonical);
        expect(r.lookupKeys[1], '20${canonical.substring(1)}');
      });
    });

    const shorts = ['999', '9999', '19999', '١٩٩٩٩', '19 999'];
    for (final s in shorts) {
      test('"$s" is a short number (also a number)', () {
        final r = c(s);
        expect(r.kind, QueryKind.phone);
        expect(r.phoneType, PhoneType.shortNumber);
        expect(r.isComplete, isTrue);
        expect(r.number, r.canonical);
      });
    }

    const partials = {
      '010': '010',
      '0100': '0100',
      '٠١٠٠٠٠': '010000',
      '0100000000': '0100000000',
      '02000': '02000',
    };
    partials.forEach((input, canonical) {
      test('"$input" is a partial number', () {
        final r = c(input);
        expect(r.kind, QueryKind.phone);
        expect(r.phoneType, PhoneType.partial);
        expect(r.canonical, canonical);
        expect(r.isComplete, isFalse);
      });
    });

    test('foreign number keeps country code digits', () {
      final r = c('+44 0000 000000');
      expect(r.phoneType, PhoneType.foreign);
      expect(r.canonical, '440000000000');
    });

    for (final s in [
      '010000000000', // 12 digits
      '0', '05', '1', '12',
      '010 abc',
      'رقم 01000000000',
      '01000000000 01000000000x',
      '123456789012',
    ]) {
      test('"$s" is not a phone number', () {
        expect(c(s).kind, isNot(QueryKind.phone));
      });
    }
  });

  group('price-like numbers', () {
    const cases = {
      '50 جنيه': ('50', true),
      '٥٠ جنيه': ('50', true),
      '50ج': ('50', true),
      '50 ج.م': ('50', true),
      '50 ج م': ('50', true),
      'جنيه 50': ('50', true),
      '50 جنيهات': ('50', true),
      '٥٠ جنيهًا': ('50', true),
      '50 EGP': ('50', true),
      '50 LE': ('50', true),
      '50 L.E.': ('50', true),
      '50£': ('50', true),
      '1,500 جنيه': ('1500', true),
      '١٬٥٠٠ جنيه': ('1500', true),
      '12.50': ('12.5', false),
      '١٫٥': ('1.5', false),
      '12.0 جنيه': ('12', true),
      '5': ('5', false),
      '50': ('50', false),
      '123456': ('123456', false),
      '1,500': ('1500', false),
    };
    cases.forEach((input, expected) {
      test('"$input" → ${expected.$1} (currency: ${expected.$2})', () {
        final r = c(input);
        expect(r.kind, QueryKind.number);
        expect(r.canonical, expected.$1);
        expect(r.number, expected.$1);
        expect(r.hasCurrency, expected.$2);
      });
    });

    for (final s in [
      '50 دقيقه',
      '1,50',
      '12.5.3',
      'جنيه',
      '١٠ جيجا',
      '123456789012345',
    ]) {
      test('"$s" is not a number', () {
        expect(c(s).kind, QueryKind.text);
      });
    }
  });

  group('free text', () {
    for (final s in [
      'باقة نت',
      'رصيد',
      'sim',
      'تحويل رصيد ٥٠',
      'e& money',
      'كود *999#',
    ]) {
      test('"$s" is text', () {
        final r = c(s);
        expect(r.kind, QueryKind.text);
        expect(r.canonical, isNull);
        expect(r.lookupKeys, isEmpty);
      });
    }
    test('text keeps the normalized query', () {
      expect(c('باقة  الإنترنت').normalized, 'باقه الانترنت');
    });
  });

  group('extractCodes', () {
    test('finds ussd codes and phones in arabic prose', () {
      final codes = QueryClassifier.extractCodes(
        'للاشتراك اطلب *٩٩٩*١# أو اتصل على ٠١٠ ٠٠٠٠ ٠٠٠٠ والسعر ٥٠ جنيه',
      );
      expect(codes, {'*999*1#', '01000000000', '201000000000'});
    });
    test('spaced code and missing hash', () {
      expect(QueryClassifier.extractCodes('اطلب * 999 # الآن'), {'*999#'});
      expect(QueryClassifier.extractCodes('اطلب *999 الآن'), {'*999#'});
    });
    test('a number after a closed code is not glued to it', () {
      expect(QueryClassifier.extractCodes('اطلب *999# 5 مرات'), {'*999#'});
    });
    test('international and landline numbers', () {
      expect(
        QueryClassifier.extractCodes('call +20 100-000-0000 or 02 0000 0000'),
        {'01000000000', '201000000000', '0200000000', '20200000000'},
      );
    });
    test('short numbers only on request', () {
      const text = 'الخط الساخن 19999 والسعر 100 جنيه';
      expect(QueryClassifier.extractCodes(text), isEmpty);
      expect(QueryClassifier.extractCodes(text, includeShortNumbers: true), {
        '19999',
        '100',
      });
    });
    test('hashtags and plain text produce nothing', () {
      expect(QueryClassifier.extractCodes('#عروض باقه نت'), isEmpty);
      expect(QueryClassifier.extractCodes(''), isEmpty);
    });
    test('phone inside a ussd code is not extracted separately', () {
      expect(QueryClassifier.extractCodes('*999*01000000000#'), {
        '*999*01000000000#',
      });
    });
  });
}
