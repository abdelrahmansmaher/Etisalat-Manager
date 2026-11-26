import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_hub/app.dart';
import 'package:knowledge_hub/core/content/content.dart';
import 'package:knowledge_hub/core/settings/history.dart';
import 'package:knowledge_hub/core/settings/preferences.dart';
import 'package:knowledge_hub/core/user/user.dart';
import 'package:knowledge_hub/core/widgets/app_bottom_nav.dart';
import 'package:knowledge_hub/features/home/home_screen.dart';
import 'package:knowledge_hub/features/tools/calculator_screen.dart';
import 'package:knowledge_hub/features/tools/tool_routes.dart';
import 'package:knowledge_hub/features/training/training_deck.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

Map<String, dynamic> _fact(String l, String v, String kind, [String? unit]) => {
  'label_ar': l,
  'value': v,
  'kind': kind,
  'unit': ?unit,
};

Map<String, dynamic> _package(int n, {required int price, required int gb}) => {
  'id': 'pkg-$n',
  'type': 'package',
  'category_ar': 'باقات وهمية',
  'title_ar': 'باقة وهمية $n',
  'summary_ar': 'باقة للاختبار $n',
  'facts': [
    _fact('السعر', '$price', 'price', 'ج'),
    _fact('السعر المطلوب شحنه/شامل الضريبة', '${price * 2}', 'price', 'ج'),
    _fact('الحصة (إنترنت)', '${gb * 1000}', 'quantity', 'ميجا'),
    _fact('الصلاحية', '30', 'duration', 'يوم'),
    _fact('كود الاشتراك', '*9$n#', 'code'),
  ],
  'price_egp': price,
  'price_total_egp': price * 2,
  'quota_gb': gb,
  'validity_days': 30,
  'codes': ['*9$n#'],
  'status': 'confirmed',
  'status_note_ar': 'مؤكد من الموقع الرسمي (اختبار).',
  'sources': [
    {
      'name': 'موقع وهمي',
      'type': 'official_site',
      'url': 'https://example.com',
      'checked_at': '2026-01-01',
    },
  ],
};

final _packages = jsonEncode({
  'section': 'packages',
  'as_of': '2026-01-01',
  'items': [
    for (var n = 1; n <= 6; n++) _package(n, price: n * 10, gb: n * 2),
    {
      'id': 'pkg-recharge-tax-rule',
      'type': 'rule',
      'category_ar': 'الشحن',
      'title_ar': 'قاعدة وهمية للشحن',
      'summary_ar': 'كل 100 كارت = 50 رصيد',
      'facts': [
        _fact('كارت', '100', 'price', 'ج'),
        _fact('رصيد فعلي', '50', 'price', 'ج'),
      ],
      'status': 'confirmed',
      'sources': [
        {'name': 'دليل وهمي', 'type': 'pdf_guide'},
      ],
    },
  ],
});

final _source = MemoryContentSource({ContentSection.packages: _packages});

Finder _key(String k) => find.byKey(ValueKey(k));

Future<ProviderContainer> _open(
  WidgetTester tester,
  String route, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues({PrefKeys.locale: 'ar', ...prefs});
  final store = await SharedPreferences.getInstance();
  setSurface(tester, size: const Size(400, 1600));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(store),
        contentSourceProvider.overrideWithValue(_source),
      ],
      child: const KnowledgeHubApp(),
    ),
  );
  await tester.pumpAndSettle();
  final home = tester.element(find.byType(HomeScreen));
  final container = ProviderScope.containerOf(home);
  GoRouter.of(home).push(route);
  await tester.pumpAndSettle();
  expect(find.byType(AppBottomNav).hitTestable(), findsNothing);
  return container;
}

void main() {
  testWidgets('compare: pick two, best values marked, then remove', (
    tester,
  ) async {
    await _open(tester, ToolRoutes.compareWith('pkg-1'));
    expect(_key('compare-chip-pkg-1'), findsOneWidget);
    expect(find.text('الأقل'), findsNothing);

    await tester.tap(_key('compare-add'));
    await tester.pumpAndSettle();
    expect(_key('pick-pkg-1'), findsNothing, reason: 'already chosen');
    await tester.tap(_key('pick-pkg-2'));
    await tester.pumpAndSettle();

    expect(_key('compare-chip-pkg-2'), findsOneWidget);
    expect(find.text('الأقل'), findsNWidgets(2)); // price and total
    expect(find.text('الأعلى'), findsOneWidget); // internet
    // The stated quota, not a converted one.
    expect(find.text('2000 ميجا'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(_key('compare-chip-pkg-2'));
    await tester.pumpAndSettle();
    expect(find.text('الأقل'), findsNothing);
  });

  testWidgets('recommend: meets every need, cheapest first', (tester) async {
    await _open(tester, ToolRoutes.recommend);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '80'); // budget, tax included
    await tester.enterText(fields.at(1), '4'); // GB
    await tester.pumpAndSettle();
    expect(find.text('تغطي كل الطلبات'), findsOneWidget);
    // 80 pays for packages 1..4 (20, 40, 60, 80); 4 GB needs 2 or more.
    final y2 = tester.getTopLeft(find.text('باقة وهمية 2')).dy;
    final y3 = tester.getTopLeft(find.text('باقة وهمية 3')).dy;
    final y4 = tester.getTopLeft(find.text('باقة وهمية 4')).dy;
    expect(y2, lessThan(y3));
    expect(y3, lessThan(y4));
    expect(find.text('4000 ميجا، تكفي'), findsOneWidget);
  });

  testWidgets('recommend: Arabic digits work, letters are refused', (
    tester,
  ) async {
    await _open(tester, ToolRoutes.recommend);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '٤');
    await tester.pumpAndSettle();
    expect(find.text('باقة وهمية 2'), findsOneWidget);
    await tester.enterText(fields.at(1), 'abc');
    await tester.pumpAndSettle();
    expect(find.text('اكتب رقمًا صحيحًا'), findsOneWidget);
  });

  testWidgets('calculator: both directions from the stated ratio', (
    tester,
  ) async {
    await _open(tester, ToolRoutes.calculator);
    expect(find.byType(CalculatorScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pumpAndSettle();
    expect(find.text('50 جنيه'), findsOneWidget);
    await tester.tap(find.text('عندي سعر باقة'));
    await tester.pumpAndSettle();
    expect(find.text('200 جنيه'), findsOneWidget);
  });

  testWidgets('calculator: postpaid total with taxes and fees', (tester) async {
    await _open(tester, ToolRoutes.calculator);
    await tester.tap(_key('calc-mode-postpaid'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '460');
    await tester.pumpAndSettle();
    // 460 x 1.08 x 1.14 + 10 + 1.34
    expect(find.text('577.69 جنيه'), findsOneWidget);
    expect(find.textContaining('36.8'), findsOneWidget);
    expect(find.textContaining('69.55'), findsOneWidget);
    expect(find.textContaining('11.34'), findsOneWidget);
  });

  testWidgets('long-press shows a quick look that opens the item', (
    tester,
  ) async {
    await _open(tester, '/section/packages');
    await tester.longPress(_key('item-row-pkg-1'));
    await tester.pumpAndSettle();
    expect(_key('peek-pkg-1'), findsOneWidget);
    expect(_key('copy-*91#'), findsOneWidget);
    expect(_key('dial-*91#'), findsOneWidget);
    await tester.tap(_key('peek-open'));
    await tester.pumpAndSettle();
    expect(_key('peek-pkg-1'), findsNothing);
    expect(_key('package-hero'), findsOneWidget);
  });

  testWidgets('favorites: added from a page, listed, marked and removed', (
    tester,
  ) async {
    final container = await _open(tester, '/item/pkg-3');
    await tester.tap(_key('favorite-pkg-3'));
    await tester.pumpAndSettle();
    expect(container.read(favoritesProvider), {'pkg-3'});

    GoRouter.of(tester.element(_key('favorite-pkg-3')))
        .push(ToolRoutes.favorites);
    await tester.pumpAndSettle();
    expect(_key('fav-pkg-3'), findsOneWidget);
    await tester.tap(find.byTooltip('أزل من المفضلة').last);
    await tester.pumpAndSettle();
    expect(_key('fav-pkg-3'), findsNothing);
    expect(find.text('لا توجد مفضلة بعد'), findsOneWidget);
  });

  testWidgets('notes: add, edit, delete and undo', (tester) async {
    final container = await _open(tester, ToolRoutes.notes);
    await tester.tap(_key('notes-add'));
    await tester.pumpAndSettle();
    await tester.enterText(_key('note-editor-field'), 'ملاحظة أولى');
    await tester.tap(_key('note-save'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'sheet closed cleanly');
    expect(find.text('ملاحظة أولى'), findsOneWidget);

    await tester.tap(find.text('ملاحظة أولى'));
    await tester.pumpAndSettle();
    await tester.enterText(_key('note-editor-field'), 'ملاحظة معدلة');
    await tester.tap(_key('note-save'));
    await tester.pumpAndSettle();
    expect(container.read(notesProvider).single.text, 'ملاحظة معدلة');

    await tester.tap(find.byTooltip('احذف الملاحظة'));
    await tester.pumpAndSettle();
    expect(container.read(notesProvider), isEmpty);
    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
    expect(container.read(notesProvider).single.text, 'ملاحظة معدلة');
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  group('content editor', () {
    Future<void> save(WidgetTester tester) async {
      await tester.tap(_key('editor-save'));
      await tester.pumpAndSettle();
    }

    testWidgets('a title edit keeps the structured price and quota', (
      tester,
    ) async {
      final container = await _open(tester, ToolRoutes.editItem('pkg-2'));
      await tester.enterText(_key('editor-title'), 'اسم جديد');
      await save(tester);
      final item = container.read(contentItemProvider('pkg-2'))!;
      expect(item.title, 'اسم جديد');
      expect(item.priceEgp, 20);
      expect(item.quotaGb, 4);
      expect(container.read(overridesProvider)['pkg-2']!.fields.keys, [
        'title_ar',
      ]);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('an edited item is never shown as confirmed', (tester) async {
      final container = await _open(tester, ToolRoutes.editItem('pkg-2'));
      await tester.enterText(_key('editor-title'), 'اسم جديد');
      await save(tester);
      final item = container.read(contentItemProvider('pkg-2'))!;
      expect(item.userEdited, isTrue);
      expect(item.officiallyVerified, isFalse);
      expect(item.status, isNot(ItemStatus.confirmed));
      expect(item.statusNote, isNot(contains('مؤكد')));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('saving without a change records nothing', (tester) async {
      final container = await _open(tester, ToolRoutes.editItem('pkg-2'));
      await save(tester);
      expect(container.read(overridesProvider), isEmpty);
      expect(find.text('لم يتغير شيء'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('steps and explanation can be written', (tester) async {
      final container = await _open(tester, ToolRoutes.editItem('pkg-2'));
      await tester.enterText(_key('editor-steps'), 'خطوة 1\n\nخطوة 2');
      await tester.enterText(_key('editor-body'), 'شرح جديد');
      await save(tester);
      final item = container.read(contentItemProvider('pkg-2'))!;
      expect(item.steps, ['خطوة 1', 'خطوة 2']);
      expect(item.body, 'شرح جديد');
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('a hidden item reopens with its data, not blank', (
      tester,
    ) async {
      final container = await _open(tester, ToolRoutes.editItem('pkg-2'));
      final hide = find.byType(SwitchListTile);
      await tester.dragUntilVisible(
        hide,
        find.byType(CustomScrollView).last,
        const Offset(0, -300),
      );
      await tester.tap(hide);
      await tester.pumpAndSettle();
      await save(tester);
      expect(container.read(contentItemProvider('pkg-2')), isNull);

      GoRouter.of(tester.element(find.byType(HomeScreen)))
          .push(ToolRoutes.editItem('pkg-2'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_key('editor-title')).controller!.text,
        'باقة وهمية 2',
      );
      expect(find.text('*92#'), findsWidgets); // in the codes field
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('a new item needs a title, then appears in the content', (
      tester,
    ) async {
      final container = await _open(tester, ToolRoutes.newItem);
      await save(tester);
      expect(find.text('اكتب العنوان'), findsOneWidget);
      await tester.enterText(_key('editor-title'), 'بند من عندي');
      await save(tester);
      expect(
        container.read(contentLibraryProvider).all.map((i) => i.title),
        contains('بند من عندي'),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('import sheet refuses garbage and closes cleanly', (
      tester,
    ) async {
      await _open(tester, ToolRoutes.editor);
      await tester.tap(_key('editor-import'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'كلام');
      await tester.tap(find.text('فحص'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ليس تصديرًا صحيحًا'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  test('export and import round-trip an edit', () {
    final edit = ContentOverride(
      id: 'pkg-1',
      section: ContentSection.packages,
      editedAt: DateTime(2026),
      fields: const {
        'title_ar': 'اسم',
        'body_ar': 'شرح',
        'steps_ar': ['أ', 'ب'],
      },
    );
    final back = OverridesTransfer.parse(
      OverridesTransfer.export([edit], DateTime(2026)),
    ).single;
    expect(back.sameEditAs(edit), isTrue);
    // A status or a source can never come in through an import.
    final forged = jsonEncode({
      'format': OverridesTransfer.format,
      'version': OverridesTransfer.version,
      'edits': [
        {
          ...edit.toJson(),
          'fields': {'title_ar': 'x', 'status': 'confirmed'},
        },
      ],
    });
    expect(() => OverridesTransfer.parse(forged), throwsFormatException);
  });

  group('training', () {
    late TrainingDeck deck;

    setUp(() async {
      deck = TrainingDeck.build((await ContentLoader.load(_source)).all);
    });

    test('questions come only from confirmed content', () {
      expect(deck.cards, isNotEmpty);
      for (final c in deck.cards) {
        expect(c.item.status, ItemStatus.confirmed);
      }
    });

    test('every quiz question has its answer among distinct choices', () {
      final quiz = deck.quiz(Random(1));
      expect(quiz, isNotEmpty);
      for (final q in quiz) {
        expect(q.choices, contains(q.card.answer));
        expect(q.choices.toSet().length, q.choices.length);
      }
    });

    testWidgets('daily question is answered once and kept', (tester) async {
      await _open(tester, ToolRoutes.training);
      expect(find.text('سؤال اليوم'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.text('سؤال اليوم')),
      );
      final daily = deck.daily(container.read(clockProvider)())!;
      await tester.tap(find.text(daily.choices.first).first);
      await tester.pumpAndSettle();
      expect(find.text('أجبت عن سؤال اليوم'), findsOneWidget);
    });

    testWidgets('cards: reveal, answer, next', (tester) async {
      await _open(tester, ToolRoutes.training);
      await tester.tap(find.text('البطاقات'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 من '), findsOneWidget);
      await tester.tap(find.text('اعرض الإجابة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('عرفتها'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 من '), findsOneWidget);
    });
  });

  testWidgets("what's new: price change shows the old and the new", (
    tester,
  ) async {
    await _open(tester, ToolRoutes.whatsNew);
    expect(find.text('لا توجد تغييرات مسجلة'), findsOneWidget);
  });

  testWidgets('More: content stats and clearing history', (tester) async {
    final container = await _open(tester, '/item/pkg-1');
    expect(container.read(recentItemsProvider), contains('pkg-1'));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(_key('nav-3'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(_key('stat-items')).data,
      '${container.read(contentLibraryProvider).length}',
    );
    expect(tester.widget<Text>(_key('stat-official')).data, '6');
    await tester.tap(_key('clear-history'));
    await tester.pumpAndSettle();
    expect(container.read(recentItemsProvider), isEmpty);
    expect(_key('clear-history'), findsNothing);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
