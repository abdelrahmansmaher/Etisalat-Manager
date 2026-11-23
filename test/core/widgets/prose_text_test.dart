import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/widgets/prose_text.dart';

void main() {
  test('segments split codes out of Arabic prose', () {
    expect(ProseText.segments('اشترك بـ *999#.'), [
      ('اشترك بـ ', false),
      ('*999#', true),
      ('.', false),
    ]);
    expect(ProseText.segments('السعر 74 ج').single, ('السعر 74 ج', false));
  });

  testWidgets('code inside RTL prose keeps * before # visually',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: ProseText('اشترك بـ *999#.')),
      ),
    ));
    final code = find.text('*999#');
    expect(code, findsOneWidget);
    final dir = tester.widget<Directionality>(find
        .ancestor(of: code, matching: find.byType(Directionality))
        .first);
    expect(dir.textDirection, TextDirection.ltr);
  });
}
