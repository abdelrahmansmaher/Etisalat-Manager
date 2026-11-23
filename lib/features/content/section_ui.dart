import 'package:flutter/material.dart';

import '../../core/content/content_models.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/trust/trust_models.dart';
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

  String subtitle(AppLocalizations l10n) => switch (this) {
    ContentSection.packages => l10n.sectionPackagesHomeDesc,
    ContentSection.internet => l10n.sectionInternetDesc,
    ContentSection.procedures => l10n.sectionProceduresDesc,
    ContentSection.numbers => l10n.sectionNumbersHomeDesc,
    ContentSection.wallet => l10n.sectionWalletHomeDesc,
    ContentSection.glossary => l10n.sectionGlossaryHomeDesc,
    ContentSection.company => l10n.sectionCompanyDesc,
  };
}

/// Per-section accent: icon colour (≥ 3:1 on [container]) and a soft
/// container tint. Emerald stays the brand; sections get calm sibling hues
/// so the grid reads at a glance (never red — red means conflict).
@immutable
class SectionTone {
  const SectionTone(this.foreground, this.container, this.glow);

  final Color foreground;
  final Color container;

  /// Second gradient stop for icon tiles / card washes.
  final Color glow;

  static SectionTone of(ContentSection s, Brightness b) {
    final dark = b == Brightness.dark;
    return switch (s) {
      ContentSection.packages =>
        dark
            ? const SectionTone(
                Color(0xFF5EE3B0),
                Color(0xFF0F3A2D),
                Color(0xFF14503D),
              )
            : const SectionTone(
                Color(0xFF047857),
                Color(0xFFDDF4EA),
                Color(0xFFC4EBD9),
              ),
      ContentSection.internet =>
        dark
            ? const SectionTone(
                Color(0xFF67D8F0),
                Color(0xFF0C3340),
                Color(0xFF114456),
              )
            : const SectionTone(
                Color(0xFF0E7490),
                Color(0xFFDDF3F8),
                Color(0xFFC3E8F1),
              ),
      ContentSection.procedures =>
        dark
            ? const SectionTone(
                Color(0xFFA9B6FC),
                Color(0xFF1E2550),
                Color(0xFF283166),
              )
            : const SectionTone(
                Color(0xFF4338CA),
                Color(0xFFE6E8FD),
                Color(0xFFD3D7FB),
              ),
      ContentSection.numbers =>
        dark
            ? const SectionTone(
                Color(0xFFF2C978),
                Color(0xFF2E2511),
                Color(0xFF3E3216),
              )
            : const SectionTone(
                Color(0xFF9A6200),
                Color(0xFFFBF1DC),
                Color(0xFFF6E3BA),
              ),
      ContentSection.wallet =>
        dark
            ? const SectionTone(
                Color(0xFF7CC4FB),
                Color(0xFF0D2C47),
                Color(0xFF133A5C),
              )
            : const SectionTone(
                Color(0xFF0369A1),
                Color(0xFFDDEFFB),
                Color(0xFFC5E3F7),
              ),
      ContentSection.glossary =>
        dark
            ? const SectionTone(
                Color(0xFFC9D3DF),
                Color(0xFF222B36),
                Color(0xFF2C3744),
              )
            : const SectionTone(
                Color(0xFF475569),
                Color(0xFFE9EDF2),
                Color(0xFFD9E0E8),
              ),
      ContentSection.company =>
        dark
            ? const SectionTone(
                Color(0xFF5FE0CF),
                Color(0xFF0D3531),
                Color(0xFF124843),
              )
            : const SectionTone(
                Color(0xFF0F766E),
                Color(0xFFDBF3F0),
                Color(0xFFC1EAE5),
              ),
    };
  }
}

extension ContentSectionTone on ContentSection {
  SectionTone tone(BuildContext context) =>
      SectionTone.of(this, Theme.of(context).brightness);
}

extension ContentSourceTypeUi on ContentSourceType {
  SourceType get trustType => switch (this) {
    ContentSourceType.officialSite ||
    ContentSourceType.regulator => SourceType.officialPublic,
    _ => SourceType.external,
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
