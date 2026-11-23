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

  testWidgets('code inside RTL prose keeps * before # visually', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(child: ProseText('اشترك بـ *999#.')),
        ),
      ),
    );
    // The code is a left-to-right row of runs: '*', '999', '#'.
    final row = find.byKey(const ValueKey('code-runs-*999#'));
    expect(row, findsOneWidget);
    final star = tester.getCenter(
      find.descendant(of: row, matching: find.text('*')),
    );
    final digits = tester.getCenter(
      find.descendant(of: row, matching: find.text('999')),
    );
    final hash = tester.getCenter(
      find.descendant(of: row, matching: find.text('#')),
    );
    expect(star.dx, lessThan(digits.dx));
    expect(digits.dx, lessThan(hash.dx));
    expect(tester.getSemantics(row).label, contains('*999#'));
  });
}
