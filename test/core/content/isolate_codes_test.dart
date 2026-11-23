import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content_models.dart';
import 'package:knowledge_hub/core/search/arabic_normalizer.dart';

void main() {
  const lri = '\u200E';
  const pdi = '\u200E';

  test('codes inside Arabic prose are wrapped in LTR isolates', () {
    expect(isolateCodes('اشترك بـ *999#.'), 'اشترك بـ $lri*999#$pdi.');
    expect(
      isolateCodes('الغي بـ *999*1# أو ##002#'),
      'الغي بـ $lri*999*1#$pdi أو $lri##002#$pdi',
    );
  });

  test('plain numbers and prices are untouched', () {
    expect(isolateCodes('السعر 74 ج و 1,900 ميكس'), 'السعر 74 ج و 1,900 ميكس');
  });

  test('normalizer strips the isolates so search is unaffected', () {
    expect(
      normalizeArabic(isolateCodes('اشترك بـ *999#')),
      normalizeArabic('اشترك بـ *999#'),
    );
  });
}
