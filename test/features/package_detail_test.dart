import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/core/widgets/trust/trust.dart';
import 'package:knowledge_hub/features/content/package_facts.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';

import '../helpers/pump_app.dart';

/// Fake packages in the shape (and label order) the data uses.
final _packages = jsonEncode({
  'section': 'packages',
  'as_of': '2026-11-22',
  'items': [
    {
      'id': 'pkg-full',
      'type': 'package',
      'category_ar': 'باقات تجريبية',
      'title_ar': 'باقة كاملة تجريبية 52',
      'title_en': 'Full Test Bundle 52',
      'summary_ar': 'باقة شهرية وهمية للاختبار، اشترك بـ *319*52#.',
      'body_ar': 'شرط أول.\n- ملاحظة أولى\n- ملاحظة ثانية',
      'facts': [
        {
          'label_ar': 'السعر (الخصم من الرصيد)',
          'value': '52',
          'unit': 'ج',
          'kind': 'price',
        },
        {
          'label_ar': 'السعر المطلوب شحنه/شامل الضريبة',
          'value': '74.29',
          'unit': 'ج',
          'kind': 'price',
        },
        {
          'label_ar': 'الحصة',
          'value': '1,900',
          'unit': 'ميكس',
          'kind': 'quantity',
        },
        {
          'label_ar': 'الصلاحية',
          'value': '30',
          'unit': 'يوم',
          'kind': 'duration',
        },
        {'label_ar': 'كود الاشتراك', 'value': '*319*52#', 'kind': 'code'},
        {'label_ar': 'التجديد', 'value': 'تلقائي كل شهر', 'kind': 'text'},
        {
          'label_ar': 'سعر ما بعد الباقة',
          'value': '0.25',
          'unit': 'ج/دقيقة',
          'kind': 'price',
        },
      ],
      'codes': ['*319*52#'],
      'status': 'confirmed',
      'sources': [
        {'name': 'دليل تجريبي', 'type': 'pdf_guide'},
      ],
      'pdf_pages': [71],
    },
    {
      'id': 'pkg-conflict',
      'type': 'package',
      'title_ar': 'باقة متعارضة',
      'summary_ar': 'سعرها مختلف بين مصدرين',
      'facts': [
        {'label_ar': 'السعر', 'value': '10', 'unit': 'ج', 'kind': 'price'},
        {
          'label_ar': 'السعر حسب مصدر آخر',
          'value': '12',
          'unit': 'ج',
          'kind': 'price',
        },
      ],
      'status': 'conflict',
    },
  ],
});

MemoryContentSource get _source =>
    MemoryContentSource({ContentSection.packages: _packages});

Future<void> _open(
  WidgetTester tester,
  String id, {
  Locale locale = ar,
  ThemeMode mode = ThemeMode.light,
  Size size = const Size(400, 1800),
  double textScale = 1.0,
}) async {
  await pumpApp(
    tester,
    content: _source,
    locale: locale,
    themeMode: mode,
    size: size,
    textScale: textScale,
  );
  GoRouter.of(tester.element(find.byType(HomeScreen))).push('/item/$id');
  await tester.pumpAndSettle();
}

Finder _inside(String key, Finder f) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: f);

void main() {
  group('PackageFacts role detection', () {
    PackageFactRole role(String label, FactKind kind, [String value = '1']) =>
        PackageFacts.roleOf(Fact(label: label, value: value, kind: kind));

    test('prices: deducted vs recharge vs after-bundle vs extras', () {
      expect(
        role('السعر (الخصم من الرصيد)', FactKind.price),
        PackageFactRole.price,
      );
      expect(
        role('السعر الصافي (يُخصم من الرصيد)', FactKind.price),
        PackageFactRole.price,
      );
      expect(role('السعر قبل الضريبة', FactKind.price), PackageFactRole.price);
      expect(role('سعر الباقة', FactKind.price), PackageFactRole.price);
      expect(
        role('السعر المطلوب شحنه/شامل الضريبة', FactKind.price),
        PackageFactRole.rechargePrice,
      );
      expect(
        role('تحتاج تشحن تقريبًا (شاملة ضريبة الشحن)', FactKind.price),
        PackageFactRole.rechargePrice,
      );
      expect(
        role('سعر ما بعد الباقة', FactKind.price),
        PackageFactRole.afterBundle,
      );
      expect(
        role('بعد نفاد الباقة', FactKind.price),
        PackageFactRole.afterBundle,
      );
      expect(
        role('خط داتا عائلة إضافي', FactKind.price),
        PackageFactRole.other,
      );
    });

    test('quota, validity, code, renewal', () {
      expect(role('الحصة', FactKind.quantity), PackageFactRole.quota);
      expect(role('الإنترنت (ميجا)', FactKind.quantity), PackageFactRole.quota);
      expect(role('الصلاحيّة', FactKind.duration), PackageFactRole.validity);
      expect(
        role('الصلاحية', FactKind.text, '30 يوم'),
        PackageFactRole.validity,
      );
      expect(role('كود الاشتراك', FactKind.code), PackageFactRole.code);
      expect(role('التجديد', FactKind.text, 'تلقائي'), PackageFactRole.renewal);
    });

    test('grouping prefers the deducted price and the subscribe code', () {
      const item = ContentItem(
        id: 'x',
        section: ContentSection.packages,
        title: 't',
        type: ItemType.package,
        facts: [
          Fact(label: 'استهلاك الباقة', value: '*1#', kind: FactKind.code),
          Fact(label: 'سعر الباقة', value: '60', kind: FactKind.price),
          Fact(
            label: 'السعر (الخصم من الرصيد)',
            value: '52',
            kind: FactKind.price,
          ),
          Fact(label: 'كود الاشتراك', value: '*2#', kind: FactKind.code),
        ],
      );
      final pf = PackageFacts.of(item);
      expect(pf.price!.value, '52');
      expect(pf.code!.value, '*2#');
      expect(pf.others.map((f) => f.value), containsAll(['*1#', '60']));
    });
  });

  testWidgets('price hero, tax line and metrics', (tester) async {
    await _open(tester, 'pkg-full');

    expect(find.byKey(const ValueKey('package-hero')), findsOneWidget);
    // Price very large, digits LTR, unit separate.
    expect(_inside('package-price', find.text('52')), findsOneWidget);
    expect(_inside('package-price', find.text('ج')), findsOneWidget);
    expect(
      _inside('package-hero', find.text('السعر (الخصم من الرصيد)')),
      findsOneWidget,
    );
    // Tax-basis line under the price.
    expect(_inside('package-tax-line', find.text('74.29')), findsOneWidget);
    expect(
      _inside('package-tax-line', find.text('السعر المطلوب شحنه/شامل الضريبة')),
      findsOneWidget,
    );
    // Metric tiles in order: quota, validity, renewal, after-bundle.
    expect(_inside('metric-quota', find.text('1,900')), findsOneWidget);
    expect(_inside('metric-validity', find.text('30')), findsOneWidget);
    expect(
      _inside('metric-renewal', find.text('تلقائي كل شهر')),
      findsOneWidget,
    );
    expect(_inside('metric-afterBundle', find.text('0.25')), findsOneWidget);
    final quotaY = tester.getTopLeft(
      find.byKey(const ValueKey('metric-quota')),
    );
    final afterY = tester.getTopLeft(
      find.byKey(const ValueKey('metric-afterBundle')),
    );
    expect(afterY.dy, greaterThan(quotaY.dy));
    // Details table + notes.
    expect(find.byKey(const ValueKey('facts-table')), findsOneWidget);
    expect(find.byKey(const ValueKey('item-body')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('subscription code row copies the exact code', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await _open(tester, 'pkg-full');
    expect(_inside('package-code', find.text('*319*52#')), findsOneWidget);
    expect(_inside('package-code', find.text('كود الاشتراك')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('package-code-copy')));
    await tester.pump();
    expect(copied, ['*319*52#']);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('تم النسخ'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('conflicting price shows no single price', (tester) async {
    await _open(tester, 'pkg-conflict');
    expect(find.byKey(const ValueKey('package-price')), findsNothing);
    expect(
      find.byKey(const ValueKey('package-price-conflict')),
      findsOneWidget,
    );
    expect(find.byType(ConflictBanner), findsOneWidget);
    expect(find.text('10 ج'), findsOneWidget);
    expect(find.text('12 ج'), findsOneWidget);
  });

  for (final locale in [ar, en]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('package page has no overflow '
            '(${locale.languageCode}/${mode.name}/x$scale)', (tester) async {
          await _open(
            tester,
            'pkg-full',
            locale: locale,
            mode: mode,
            size: const Size(360, 640),
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          final list = find
              .byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
              )
              .last;
          for (var i = 0; i < 10; i++) {
            await tester.drag(list, const Offset(0, -500));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'step $i');
          }
        });
      }
    }
  }
}
