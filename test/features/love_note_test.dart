import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/features/search/love_note.dart';

import '../capsules_test.dart' show openSearch;
import '../helpers/pump_app.dart';

void main() {
  test('only that date opens the note, however it is typed', () {
    for (final q in ['18/09/2026', '18/9/2026', ' 18-09-2026 ', '١٨/٠٩/٢٠٢٦']) {
      expect(LoveNote.matches(q), isTrue, reason: q);
    }
    for (final q in ['18/09/2025', '19/09/2026', '18/09', 'حكاية']) {
      expect(LoveNote.matches(q), isFalse, reason: q);
    }
  });

  testWidgets('searching the date and pressing Enter shows the note', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSearch(tester);
    await tester.enterText(
      find.byKey(const ValueKey('search-field')),
      '18/09/2026',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('love-note')), findsOneWidget);
    final text = tester.widget<Text>(find.text('بحبك يا نوئتي'));
    expect(text.style?.color, const Color(0xFFE0123C));
    // Tapping anywhere closes it.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('love-note')), findsNothing);
  });
}
