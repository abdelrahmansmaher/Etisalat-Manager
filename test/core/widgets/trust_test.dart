import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/widgets/trust/trust.dart';

import '../../helpers/pump_app.dart';

final now = DateTime(2026, 11, 22, 10);

void main() {
  group('VerificationStatusBadge shows icon + text (never colour alone)', () {
    const arLabels = {
      VerificationStatus.verified: 'تم التحقق',
      VerificationStatus.needsReview: 'يحتاج مراجعة',
      VerificationStatus.expired: 'منتهي',
      VerificationStatus.unverified: 'بدون مصدر معتمد',
      VerificationStatus.conflict: 'تعارض',
      VerificationStatus.private: 'خاص',
    };
    for (final e in arLabels.entries) {
      testWidgets(e.key.name, (tester) async {
        await pumpLocalized(tester, VerificationStatusBadge(e.key));
        expect(find.text(e.value), findsOneWidget);
        expect(find.byIcon(e.key.icon), findsOneWidget);
      });
    }

    testWidgets('English labels', (tester) async {
      await pumpLocalized(
        tester,
        const VerificationStatusBadge(VerificationStatus.needsReview),
        locale: en,
        brightness: Brightness.dark,
      );
      expect(find.text('Needs review'), findsOneWidget);
    });
  });

  test('status priority: private > expired > conflict > needsReview > '
      'unverified > verified', () {
    expect(
      VerificationStatus.highest([
        VerificationStatus.verified,
        VerificationStatus.needsReview,
        VerificationStatus.conflict,
      ]),
      VerificationStatus.conflict,
    );
    expect(
      VerificationStatus.highest([
        VerificationStatus.conflict,
        VerificationStatus.expired,
      ]),
      VerificationStatus.expired,
    );
    expect(
      VerificationStatus.highest([
        VerificationStatus.expired,
        VerificationStatus.private,
      ]),
      VerificationStatus.private,
    );
    expect(VerificationStatus.highest([]), VerificationStatus.verified);
  });

  group('freshness thresholds (doc 04 §3.2)', () {
    test('prices/offers: ≤14 fresh, 15–30 aging, >30 stale', () {
      const t = TrustContentType.pricesOffers;
      expect(t.freshnessForAge(14), Freshness.fresh);
      expect(t.freshnessForAge(15), Freshness.aging);
      expect(t.freshnessForAge(30), Freshness.aging);
      expect(t.freshnessForAge(31), Freshness.stale);
    });
    test(
      'contact numbers 60/90, mobile services 60/120, procedures 90/180',
      () {
        expect(
          TrustContentType.contactNumbers.freshnessForAge(61),
          Freshness.aging,
        );
        expect(
          TrustContentType.contactNumbers.freshnessForAge(91),
          Freshness.stale,
        );
        expect(
          TrustContentType.mobileServices.freshnessForAge(120),
          Freshness.aging,
        );
        expect(
          TrustContentType.mobileServices.freshnessForAge(121),
          Freshness.stale,
        );
        expect(
          TrustContentType.branchProcedures.freshnessForAge(180),
          Freshness.aging,
        );
        expect(
          TrustContentType.branchProcedures.freshnessForAge(181),
          Freshness.stale,
        );
      },
    );
    test('siebel concepts: no aging band', () {
      const t = TrustContentType.siebelConcepts;
      expect(t.freshnessForAge(365), Freshness.fresh);
      expect(t.freshnessForAge(366), Freshness.stale);
    });
  });

  testWidgets('LastVerifiedChip: fresh relative text', (tester) async {
    await pumpLocalized(
      tester,
      LastVerifiedChip(
        verifiedAt: now.subtract(const Duration(days: 5)),
        contentType: TrustContentType.pricesOffers,
        now: now,
      ),
    );
    expect(find.text('آخر تحقق: منذ 5 أيام'), findsOneWidget);
  });

  testWidgets('LastVerifiedChip: stale becomes Needs review', (tester) async {
    await pumpLocalized(
      tester,
      LastVerifiedChip(
        verifiedAt: now.subtract(const Duration(days: 45)),
        contentType: TrustContentType.pricesOffers,
        now: now,
      ),
      locale: en,
    );
    expect(find.textContaining('Needs review'), findsOneWidget);
    expect(find.textContaining('45 days ago'), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
  });

  testWidgets('SourceBadge shows name, chevron only when tappable', (
    tester,
  ) async {
    var tapped = false;
    await pumpLocalized(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SourceBadge(
            sourceName: '[Public website]',
            type: SourceType.officialPublic,
          ),
          SourceBadge(
            sourceName: '[Guide v3]',
            type: SourceType.training,
            onTap: () => tapped = true,
          ),
        ],
      ),
    );
    expect(find.text('[Public website]'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.text('[Guide v3]'));
    expect(tapped, isTrue);
  });

  testWidgets('PrivateBadge text', (tester) async {
    await pumpLocalized(tester, const PrivateBadge());
    expect(find.text('ملاحظة خاصة — للمالك فقط'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('ConflictBanner shows both values with sources', (tester) async {
    await pumpLocalized(
      tester,
      ConflictBanner(
        entries: [
          ConflictEntry(
            value: '100',
            sourceName: 'A',
            sourceDate: DateTime(2026, 11, 1),
          ),
          const ConflictEntry(value: '120', sourceName: 'B'),
        ],
        onReview: () {},
      ),
    );
    expect(find.text('يوجد تعارض بين مصدرين حول هذه المعلومة'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('A · 1 نوفمبر 2026'), findsOneWidget);
    expect(find.text('مراجعة المصادر'), findsOneWidget);
    expect(find.byIcon(Icons.report_outlined), findsOneWidget);
  });

  testWidgets('UnofficialDisclaimer compact + full', (tester) async {
    await pumpLocalized(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [UnofficialDisclaimer.compact(), UnofficialDisclaimer.full()],
      ),
    );
    expect(find.textContaining('غير رسمي'), findsNWidgets(2));
  });

  group('PriceView', () {
    testWidgets('active: amount, currency, tax basis, validity range', (
      tester,
    ) async {
      await pumpLocalized(
        tester,
        PriceView(
          amount: 1250.5,
          taxBasis: TaxBasis.inclusiveRechargeTax,
          validFrom: DateTime(2026, 11, 1),
          validUntil: DateTime(2026, 12, 31),
          now: now,
        ),
      );
      expect(find.text('1,250.5'), findsOneWidget);
      expect(find.text('ج.م'), findsOneWidget);
      expect(find.text('شامل ضريبة الشحن'), findsOneWidget);
      expect(
        find.text('ساري من 1 نوفمبر 2026 حتى 31 ديسمبر 2026'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });

    testWidgets('expired: struck through, Expired pill, no copy', (
      tester,
    ) async {
      await pumpLocalized(
        tester,
        PriceView(
          amount: 100,
          taxBasis: TaxBasis.exclusiveVat,
          validUntil: DateTime(2026, 11, 1),
          now: now,
        ),
        locale: en,
      );
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('Excl. VAT'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsNothing);
      final text = tester.widget<Text>(find.text('100'));
      expect(text.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('ending soon / upcoming / no end date', (tester) async {
      await pumpLocalized(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PriceView(
              amount: 10,
              taxBasis: TaxBasis.unknown,
              validUntil: DateTime(2026, 11, 24),
              now: now,
            ),
            PriceView(
              amount: 20,
              taxBasis: TaxBasis.unknown,
              validFrom: DateTime(2026, 12, 5),
              now: now,
            ),
            PriceView(amount: 30, taxBasis: TaxBasis.unknown, now: now),
          ],
        ),
        locale: en,
      );
      expect(find.text('Ends in 2 days'), findsOneWidget);
      expect(
        find.text('Starts on 5 Dec 2026 — not the current price'),
        findsOneWidget,
      );
      expect(find.text('No announced end date'), findsOneWidget);
      expect(find.text('Tax basis not stated'), findsNWidgets(3));
    });

    test('validity state machine', () {
      expect(
        priceValidityFor(validUntil: DateTime(2026, 11, 22), now: now),
        PriceValidity.endingSoon,
      );
      expect(
        priceValidityFor(validUntil: DateTime(2026, 11, 21), now: now),
        PriceValidity.expired,
      );
      expect(
        priceValidityFor(validUntil: DateTime(2026, 12, 22), now: now),
        PriceValidity.active,
      );
    });
  });

  testWidgets('TrustFormat.date uses Western digits and month names', (
    tester,
  ) async {
    // Inside a localized app so intl date symbols are initialised.
    late String arDate;
    late String enDate;
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) {
          arDate = TrustFormat.date(DateTime(2026, 11, 22), ar);
          enDate = TrustFormat.date(DateTime(2026, 11, 22), en);
          return const SizedBox();
        },
      ),
    );
    expect(arDate, '22 نوفمبر 2026');
    expect(enDate, '22 Nov 2026');
  });
}
