import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_hub/core/content/content_models.dart';
import 'package:knowledge_hub/core/theme/theme.dart';
import 'package:knowledge_hub/features/content/section_ui.dart';

void main() {
  test('no widget uses Icons.* directly (registry only)', () {
    final offenders = <String>[];
    final pattern = RegExp(r'(?<![A-Za-z])Icons\.');
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(r'\', '/');
      if (p.endsWith('core/theme/app_icons.dart')) continue;
      if (pattern.hasMatch(f.readAsStringSync())) offenders.add(p);
    }
    expect(offenders, isEmpty);
  });

  test('directional icons mirror in RTL', () {
    for (final icon in [
      AppIcons.back,
      AppIcons.arrowForward,
      AppIcons.chevron,
    ]) {
      expect(icon.matchTextDirection, isTrue);
    }
  });

  test('nav: outlined when inactive, filled when active', () {
    expect(AppIcons.navHome, isNot(AppIcons.navHomeActive));
    expect(AppIcons.navBrowse, isNot(AppIcons.navBrowseActive));
    expect(AppIcons.navTraining, isNot(AppIcons.navTrainingActive));
    expect(AppIcons.navMe, isNot(AppIcons.navMeActive));
  });

  test('tile sizes share one radius rule and grow monotonically', () {
    var last = 0.0;
    for (final t in IconTile.values) {
      expect(t.box, greaterThan(last));
      expect(t.radius, closeTo(t.box * 0.3, 0.001));
      expect(t.glyph, lessThan(t.box));
      last = t.box;
    }
  });

  group('category icons', () {
    const cases = {
      'حكاية ميكسات': AppIcons.catMixes,
      'الإنترنت الأرضي (ADSL / VDSL / eHome DSL)': AppIcons.catDsl,
      'الإنترنت المنزلي اللاسلكي (Home 4G / eHome Wireless)':
          AppIcons.catHomeWireless,
      'الحالة 12: التجوال الدولي والمكالمات الدولية': AppIcons.catRoaming,
      'أرقام خدمة العملاء': AppIcons.catHotline,
      'أكواد USSD (*777#)': AppIcons.catWalletCodes,
      'سوبر كونكت (Super Connect)': AppIcons.catSuperConnect,
      'أنظمة الفاتورة': AppIcons.catPostpaid,
      'الجيل الخامس 5G': AppIcons.cat5g,
      'الشريحة المدمجة eSIM': AppIcons.catEsim,
      'جدول الرسوم': AppIcons.catFees,
      'الحدود (Limits)': AppIcons.catLimits,
      'بنود غير مؤكدة': AppIcons.catUnconfirmed,
      'الحالة 2: بدل فاقد، بدل تالف، تغيير لشريحة 4G، وeSIM':
          AppIcons.catReplaceSim,
      'الخدمات ذات القيمة المضافة (VAS)': AppIcons.catAddOns,
    };
    for (final e in cases.entries) {
      test(e.key, () => expect(CategoryIcons.match(e.key), e.value));
    }

    test('unknown category falls back to the section icon', () {
      expect(
        CategoryIcons.of(ContentSection.wallet, 'شيء غير معروف'),
        AppIcons.sectionWallet,
      );
      expect(
        CategoryIcons.of(ContentSection.internet, ''),
        AppIcons.sectionInternet,
      );
    });
  });

  testWidgets('chevron is drawn mirrored in Arabic', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: Icon(AppIcons.chevron)),
      ),
    );
    final t = tester.widget<Transform>(
      find.descendant(of: find.byType(Icon), matching: find.byType(Transform)),
    );
    expect(t.transform.getMaxScaleOnAxis(), 1);
    expect(t.transform.storage[0], -1, reason: 'x axis flipped');
  });

  test('theme tokens interpolate (smooth theme switch)', () {
    final mid = AppColors.light.lerp(AppColors.dark, 0.5);
    expect(mid.background, isNot(AppColors.light.background));
    expect(mid.background, isNot(AppColors.dark.background));
    expect(
      AppColors.light.lerp(AppColors.dark, 1).background,
      AppColors.dark.background,
    );
  });
}
