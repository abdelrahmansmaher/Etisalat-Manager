import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/widgets/ltr_text.dart';
import 'package:knowledge_hub/l10n/app_localizations_ar.dart';

import '../../helpers/pump_app.dart';

/// Visual x-position (left edge) of the character at [index] in the first
/// RenderParagraph under [finder].
double charLeft(WidgetTester tester, Finder finder, int index) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: finder, matching: find.byType(RichText)).first,
  );
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: index, extentOffset: index + 1),
  );
  expect(boxes, isNotEmpty);
  return boxes.first.left;
}

void main() {
  testWidgets('CodeText("*999#") renders LTR inside an RTL parent', (
    tester,
  ) async {
    await pumpLocalized(tester, const CodeText('*999#', key: ValueKey('code')));
    final code = find.byKey(const ValueKey('code'));

    // Inherited outer direction is RTL (Arabic)...
    expect(Directionality.of(tester.element(code)), TextDirection.rtl);

    // ...but the paragraph itself is LTR.
    final rich = tester.widget<RichText>(
      find.descendant(of: code, matching: find.byType(RichText)).first,
    );
    expect(rich.textDirection, TextDirection.ltr);

    // Visual order: '*' (index 0) left of '#' (index 4).
    final star = charLeft(tester, code, 0);
    final hash = charLeft(tester, code, 4);
    expect(star, lessThan(hash), reason: '"*" must render before "#"');
  });

  testWidgets('control: bare Text("*999#") in RTL renders reversed', (
    tester,
  ) async {
    await pumpLocalized(tester, const Text('*999#', key: ValueKey('bare')));
    final bare = find.byKey(const ValueKey('bare'));
    expect(
      charLeft(tester, bare, 0),
      greaterThan(charLeft(tester, bare, 4)),
      reason: 'proves the isolation test is sensitive to bidi reordering',
    );
  });

  testWidgets('LtrText keeps "+20 100 000 0000" and a decimal price LTR', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LtrText('+20 100 000 0000', key: ValueKey('phone')),
          LtrText('1,250.50', key: ValueKey('price')),
        ],
      ),
    );
    final phone = find.byKey(const ValueKey('phone'));
    expect(charLeft(tester, phone, 0), lessThan(charLeft(tester, phone, 4)));
    final price = find.byKey(const ValueKey('price'));
    expect(charLeft(tester, price, 0), lessThan(charLeft(tester, price, 7)));
  });

  test('Bidi.ltr wraps in LRI…PDI', () {
    final s = Bidi.ltr('*999#');
    expect(s.codeUnitAt(0), 0x2066);
    expect(s.codeUnitAt(s.length - 1), 0x2069);
    expect(s.substring(1, s.length - 1), '*999#');
  });

  test('CodeText.spell reads codes character by character', () {
    expect(CodeText.spell('*999#', AppLocalizationsAr()), 'نجمة 9 9 9 مربع');
  });

  testWidgets('copy puts the exact value on the clipboard + snackbar', (
    tester,
  ) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String?;
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

    String? copied;
    String? called;
    await pumpLocalized(
      tester,
      CodeText(
        '01000000000',
        onCopied: (v) => copied = v,
        onCall: (v) => called = v,
      ),
    );

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    expect(clipboard, '01000000000');
    expect(copied, '01000000000');
    expect(find.text('تم النسخ'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.call_outlined));
    expect(called, '01000000000');
  });

  testWidgets('no call button without onCall', (tester) async {
    await pumpLocalized(tester, const CodeText('*999#'));
    expect(find.byIcon(Icons.call_outlined), findsNothing);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
  });
}
