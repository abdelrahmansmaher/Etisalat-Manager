import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// A phone number or code at the counter must never be cut: the must-know
/// list shows every number in full (scaled down if needed, never
/// ellipsized, never past the screen edge).
void main() {
  for (final locale in [ar, en]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets(
        'must-know numbers are never cut (${locale.languageCode} x$scale)',
        (tester) async {
          await pumpApp(tester, locale: locale, textScale: scale);
          final strip = find.byKey(const ValueKey('must-know-strip'));
          await tester.scrollUntilVisible(
            strip,
            200,
            scrollable: find
                .byWidgetPredicate(
                  (w) =>
                      w is Scrollable && w.axisDirection == AxisDirection.down,
                )
                .hitTestable()
                .first,
          );
          expect(strip, findsOneWidget);
          for (final value in ['7777', '01000000000', '*555#']) {
            final text = find.descendant(of: strip, matching: find.text(value));
            await tester.ensureVisible(text);
            await tester.pumpAndSettle();
            expect(text, findsOneWidget, reason: value);
            final widget = tester.widget<Text>(text);
            expect(widget.overflow, isNot(TextOverflow.ellipsis));
            expect(widget.maxLines, isNull, reason: value);
            final paragraph = tester.renderObject<RenderParagraph>(
              find.descendant(of: text, matching: find.byType(RichText)),
            );
            expect(paragraph.didExceedMaxLines, isFalse, reason: value);
            final rect = tester.getRect(text);
            expect(rect.left, greaterThanOrEqualTo(0), reason: value);
            expect(rect.right, lessThanOrEqualTo(360), reason: value);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
