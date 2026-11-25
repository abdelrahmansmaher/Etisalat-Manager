import 'package:flutter/material.dart';

import '../../core/content/content_models.dart';
import '../../core/theme/app_icons.dart';
import '../../l10n/app_localizations.dart';

/// Presentation metadata for each content section.
extension ContentSectionUi on ContentSection {
  IconData get icon => switch (this) {
    ContentSection.packages => AppIcons.sectionPackages,
    ContentSection.internet => AppIcons.sectionInternet,
    ContentSection.procedures => AppIcons.sectionProcedures,
    ContentSection.numbers => AppIcons.sectionNumbers,
    ContentSection.wallet => AppIcons.sectionWallet,
    ContentSection.glossary => AppIcons.sectionGlossary,
    ContentSection.company => AppIcons.sectionCompany,
  };

  String title(AppLocalizations l10n) => switch (this) {
    ContentSection.packages => l10n.sectionPackages,
    ContentSection.internet => l10n.sectionInternet,
    ContentSection.procedures => l10n.sectionProcedures,
    ContentSection.numbers => l10n.sectionNumbersCodes,
    ContentSection.wallet => l10n.sectionWallet,
    ContentSection.glossary => l10n.sectionGlossary,
    ContentSection.company => l10n.sectionCompany,
  };
}

/// Meaningful icon for a content sub-group (`category_ar`), by keyword.
///
/// Rules are ordered most-specific first; matching is on a lightly
/// normalised lower-case string (Arabic + the English names in brackets).
/// Unknown categories fall back to the section icon.
abstract final class CategoryIcons {
  static const List<(List<String>, IconData)> _rules = [
    (['غير مؤكد'], AppIcons.catUnconfirmed),
    (['المصادر'], AppIcons.catSources),
    (['اسئله شائعه', 'faq'], AppIcons.catFaq),
    (['ملخص'], AppIcons.catSummary),
    (
      ['تحريك الاسعار', 'زيادات الاسعار', 'خلفيه الاسعار'],
      AppIcons.catPriceHistory,
    ),
    (['تجوال', 'roaming', 'دوليه'], AppIcons.catRoaming),
    (['5g', 'الجيل الخامس'], AppIcons.cat5g),
    (['بدل فاقد', 'بدل تالف'], AppIcons.catReplaceSim),
    (['esim', 'الشريحه المدمجه'], AppIcons.catEsim),
    (['adsl', 'vdsl', 'dsl', 'الانترنت الارضي'], AppIcons.catDsl),
    (['wireless', 'home 4g', 'اللاسلكي'], AppIcons.catHomeWireless),
    (['data line', 'خطوط الداتا'], AppIcons.catDataLine),
    (['super connect', 'سوبر كونكت'], AppIcons.catSuperConnect),
    (['super hours', 'sa3at', 'ساعات'], AppIcons.catHours),
    (['super mega', 'سوبر ميجا', 'mbs', 'ميجابايتس'], AppIcons.catMegabytes),
    (['حكايه انترنت', 'حكايه الشهريه', 'hekaya'], AppIcons.catMegabytes),
    (['حكايه', 'ميكس'], AppIcons.catMixes),
    (['كارت اقوي', 'انظمه اليوم'], AppIcons.catDailyCard),
    (['التحويل بين الكارت', 'تغيير النظام'], AppIcons.catSystemChange),
    (['الفاتوره', 'رؤيه', 'emerald', 'ايميرالد'], AppIcons.catPostpaid),
    (['الخط الارضي'], AppIcons.catLandline),
    (['خدمه العملاء', 'الشكاوي وارقام'], AppIcons.catHotline),
    (['الشكاوي'], AppIcons.catComplaints),
    (['تنظيميه', 'تصعيد'], AppIcons.catRegulator),
    (['اكواد الرصيد', 'خدمات الرصيد'], AppIcons.catBalanceCodes),
    (['اكواد الانترنت', 'اداره انترنت'], AppIcons.catInternetCodes),
    (['القيمه المضافه'], AppIcons.catAddOns),
    (['الغاء الخدمات'], AppIcons.catCancelServices),
    (['خدمات المكالمات'], AppIcons.catCallServices),
    (['عروض', 'هدايا'], AppIcons.catOffers),
    (['من بره'], AppIcons.catImported),
    (['تطبيق'], AppIcons.catApp),
    (['معرفه الرقم', 'المسجله باسمك'], AppIcons.catIdentity),
    (['gsm', 'mmi'], AppIcons.catGsm),
    (['بادئات'], AppIcons.catPrefixes),
    (['ussd', '*777#'], AppIcons.catWalletCodes),
    (['فتح المحفظه', 'التسجيل'], AppIcons.catWalletOpen),
    (['الرسوم'], AppIcons.catFees),
    (['الحدود', 'limits'], AppIcons.catLimits),
    (['الرقم السري', 'pin'], AppIcons.catSecurity),
    (['فقدان'], AppIcons.catLost),
    (['اغلاق'], AppIcons.catClose),
    (['التحويل الخاطئ', 'استرداد'], AppIcons.catRefund),
    (['حالات شائعه', 'مواعيد الفروع'], AppIcons.catBranchCases),
    (['بيع خط'], AppIcons.catNewLine),
    (['نقل الملكيه', 'التنازل'], AppIcons.catOwnership),
    (['نقل الرقم', 'mnp', 'المنافسين'], AppIcons.catPortability),
    (['ايقاف الخط'], AppIcons.catSuspend),
    (['تحديث البيانات'], AppIcons.catUpdateData),
    (['الاجهزه'], AppIcons.catDevices),
    (['التعامل مع العملاء'], AppIcons.catCustomers),
    (['القواعد'], AppIcons.catRules),
    (['الشحن'], AppIcons.catRecharge),
    (['التعريفه'], AppIcons.catTariff),
    (['الاضافات'], AppIcons.catAddOns),
    (['الشبكه'], AppIcons.catNetwork),
    (['الولاء', 'النقاط'], AppIcons.catLoyalty),
    (['كول تون', 'caller tune'], AppIcons.catCallerTune),
    (['الترفيه', 'المحتوي'], AppIcons.catEntertainment),
    (['المميزه', 'ملكيه الرقم'], AppIcons.catSpecialNumbers),
    (['الشركات', 'business'], AppIcons.catBusiness),
    (['العلامه التجاريه', 'اسم الخدمه'], AppIcons.catBrand),
    (['مصطلحات', 'مسميات'], AppIcons.catTerms),
    (['الخدمات'], AppIcons.catWalletServices),
    (['بطاقه تعريف', 'مقدمه', 'عن '], AppIcons.catAbout),
    (['5 جنيه'], AppIcons.sectionPackages),
  ];

  /// Light normalisation: lower case, alef/ta-marbuta/ya variants, no
  /// diacritics.
  static String _norm(String s) {
    final b = StringBuffer();
    for (final r in s.toLowerCase().runes) {
      if ((r >= 0x064B && r <= 0x065F) || r == 0x0670 || r == 0x0640) {
        continue;
      }
      b.writeCharCode(switch (r) {
        0x0623 || 0x0625 || 0x0622 || 0x0671 => 0x0627,
        0x0629 => 0x0647,
        0x0649 => 0x064A,
        _ => r,
      });
    }
    return b.toString();
  }

  static final Map<String, IconData?> _cache = {};

  /// Icon for [category], or null when nothing matches.
  static IconData? match(String category) {
    if (category.isEmpty) return null;
    return _cache.putIfAbsent(category, () {
      final n = _norm(category);
      for (final (words, icon) in _rules) {
        if (words.any((w) => n.contains(_norm(w)))) return icon;
      }
      return null;
    });
  }

  /// Icon for a category inside [section] (falls back to the section icon).
  static IconData of(ContentSection section, String category) =>
      match(category) ?? section.icon;
}

extension ContentItemIcon on ContentItem {
  /// Leading icon of this item: its category's, else the section's.
  IconData get icon => CategoryIcons.of(section, category);
}
