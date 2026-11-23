// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navBrowse => 'تصفح';

  @override
  String get navSearch => 'بحث';

  @override
  String get navTraining => 'التدريب';

  @override
  String get navMe => 'أنا';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get homeSearchHint => 'ابحث عن باقة، كود، رقم…';

  @override
  String get homeHeroSubtitle => 'كل ما تحتاجه على الكاونتر في مكان واحد';

  @override
  String get homeSectionsSubtitle => 'اختر قسمًا للاستكشاف';

  @override
  String get sectionPackagesDesc => 'العروض والأسعار وأكواد الاشتراك';

  @override
  String get sectionServicesDesc => 'خدمات الموبايل والإضافات';

  @override
  String get sectionNumbersCodesDesc => 'أكواد USSD وأرقام الخدمة';

  @override
  String get sectionWalletDesc => 'المحفظة الإلكترونية والتحويلات';

  @override
  String get sectionGlossaryDesc => 'مصطلحات الأنظمة والفرع';

  @override
  String get browseSubtitle => 'كل الموسوعات في مكان واحد';

  @override
  String get searchExampleTitle => 'مثال توضيحي — بيانات وهمية';

  @override
  String get searchExampleItem => 'باقة تجريبية';

  @override
  String get searchExampleSource => 'الموقع العام (مثال)';

  @override
  String get homeSectionsTitle => 'الموسوعات';

  @override
  String get sectionPackages => 'الباقات';

  @override
  String get sectionServices => 'الخدمات';

  @override
  String get sectionNumbersCodes => 'الأرقام والأكواد';

  @override
  String get sectionWallet => 'المحفظة';

  @override
  String get sectionGlossary => 'المصطلحات';

  @override
  String get browseTitle => 'تصفح الموسوعات';

  @override
  String get contentComingSoon => 'المحتوى قيد الإعداد';

  @override
  String get searchTitle => 'بحث';

  @override
  String get searchFieldHint => 'اكتب كلمة أو كودًا أو رقمًا';

  @override
  String get searchClear => 'مسح البحث';

  @override
  String get searchPlaceholderBody =>
      'البحث قيد الإنشاء — سيعمل بدون إنترنت وبالعامية.';

  @override
  String get trainingTitle => 'التدريب';

  @override
  String get trainingPlaceholderBody =>
      'مسارات التعلم والمراجعة اليومية — قريبًا.';

  @override
  String get meTitle => 'أنا';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get aboutTitle => 'عن التطبيق';

  @override
  String get editorModeTitle => 'وضع المحرر (دخول المالك)';

  @override
  String get editorModeSubtitle => 'قريبًا';

  @override
  String get disclaimerShort =>
      'تطبيق مستقل وغير رسمي — تحقق دائمًا من المصادر الرسمية.';

  @override
  String get disclaimerFull =>
      'تطبيق مستقل وغير رسمي، غير تابع لأي شركة اتصالات ولا معتمد منها. المعلومات للاسترشاد ويجب الرجوع للمصادر الرسمية المعتمدة.';

  @override
  String get copyAction => 'نسخ';

  @override
  String copyValueSemantics(String value) {
    return 'نسخ $value';
  }

  @override
  String get copiedMessage => 'تم النسخ';

  @override
  String get callAction => 'اتصال';

  @override
  String get symbolStar => 'نجمة';

  @override
  String get symbolHash => 'مربع';

  @override
  String get symbolPlus => 'زائد';

  @override
  String get statusVerified => 'تم التحقق';

  @override
  String get statusNeedsReview => 'يحتاج مراجعة';

  @override
  String get statusExpired => 'منتهي';

  @override
  String get statusUnverified => 'بدون مصدر معتمد';

  @override
  String get statusConflict => 'تعارض';

  @override
  String get statusPrivate => 'خاص';

  @override
  String lastVerified(String relative) {
    return 'آخر تحقق: $relative';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      many: 'منذ $count يومًا',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'منذ يوم',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String verifiedOn(String date) {
    return 'تم التحقق في $date';
  }

  @override
  String get sourceOfficialInternal => 'مستند رسمي داخلي';

  @override
  String get sourceOfficialPublic => 'مصدر رسمي علني';

  @override
  String get sourceTraining => 'مادة تدريبية معتمدة';

  @override
  String get sourceSupervisor => 'تأكيد مشرف (موثّق)';

  @override
  String get sourceExternal => 'مرجع عام';

  @override
  String get sourceOwnerNote => 'ملاحظة المالك';

  @override
  String sourceSemantics(String name, String type) {
    return 'المصدر: $name، $type';
  }

  @override
  String get conflictTitle => 'يوجد تعارض بين مصدرين حول هذه المعلومة';

  @override
  String get conflictGuidance =>
      'لا تُبلغ العميل بقيمة نهائية — راجع المصدر الرسمي أو المشرف.';

  @override
  String get conflictAction => 'مراجعة المصادر';

  @override
  String get privateBadge => 'ملاحظة خاصة — للمالك فقط';

  @override
  String get currencyEgp => 'ج.م';

  @override
  String get taxInclusiveRecharge => 'شامل ضريبة الشحن';

  @override
  String get taxExclusiveVat => 'غير شامل ضريبة القيمة المضافة';

  @override
  String get taxUnknown => 'أساس الضريبة غير محدد';

  @override
  String priceValidRange(String from, String until) {
    return 'ساري من $from حتى $until';
  }

  @override
  String priceValidFrom(String from) {
    return 'ساري من $from';
  }

  @override
  String get priceNoEndDate => 'بدون تاريخ انتهاء معلن';

  @override
  String priceEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ينتهي خلال $count يوم',
      many: 'ينتهي خلال $count يومًا',
      few: 'ينتهي خلال $count أيام',
      two: 'ينتهي خلال يومين',
      one: 'ينتهي غدًا',
      zero: 'ينتهي اليوم',
    );
    return '$_temp0';
  }

  @override
  String priceStartsOn(String date) {
    return 'يبدأ في $date — ليس السعر الحالي';
  }

  @override
  String priceExpiredNote(String date) {
    return 'انتهى في $date — لا تستخدمه كسعر ساري';
  }

  @override
  String get sectionInternet => 'الإنترنت';

  @override
  String get sectionInternetDesc => 'باقات الموبايل والإنترنت المنزلي و5G';

  @override
  String get sectionProcedures => 'الخدمات والإجراءات';

  @override
  String get sectionProceduresDesc => 'إجراءات الفرع والحالات والتجوال';

  @override
  String get sectionCompany => 'عن الشركة';

  @override
  String get sectionCompanyDesc => 'نبذة، الشبكة، التطبيق والمنافسون';

  @override
  String get sectionPackagesHomeDesc => 'أنظمة الكارت والفاتورة والإضافات';

  @override
  String get sectionNumbersHomeDesc => 'أرقام خدمة العملاء وكل الأكواد';

  @override
  String get sectionWalletHomeDesc => 'التسجيل والأكواد والحدود والرسوم';

  @override
  String get sectionGlossaryHomeDesc => 'المصطلحات والاختصارات';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بند',
      many: '$count بندًا',
      few: '$count بنود',
      two: 'بندان',
      one: 'بند واحد',
      zero: 'لا توجد بنود',
    );
    return '$_temp0';
  }

  @override
  String get homeMustKnowTitle => 'أرقام لازم تكون حافظها';

  @override
  String contentAsOf(String date) {
    return 'آخر تحديث للمحتوى: $date';
  }

  @override
  String get contentEmptySection => 'لا يوجد محتوى في هذا القسم بعد';

  @override
  String get contentEmptySectionBody => 'سيظهر المحتوى هنا فور إضافته.';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterConfirmed => 'مؤكد';

  @override
  String get filterUnconfirmed => 'غير مؤكد';

  @override
  String get statusConfirmedGuide => 'مؤكد حسب الدليل';

  @override
  String get statusUnconfirmedReview => 'غير مؤكد — راجع داخليًا';

  @override
  String get unconfirmedBannerTitle => 'هذه المعلومة غير مؤكدة';

  @override
  String get unconfirmedBannerBody =>
      'راجع النظام الداخلي أو مشرفك قبل إبلاغ العميل.';

  @override
  String get unconfirmedGroupTitle => 'بنود غير مؤكدة';

  @override
  String get answerCardTitle => 'الإجابة السريعة';

  @override
  String get detailFactsTitle => 'كل التفاصيل';

  @override
  String get detailStepsTitle => 'الخطوات';

  @override
  String get detailSourcesTitle => 'المصادر';

  @override
  String get detailRelatedTitle => 'بنود ذات صلة';

  @override
  String detailPdfPages(String pages) {
    return 'من الدليل صفحة $pages';
  }

  @override
  String get detailNotFound => 'البند غير موجود';

  @override
  String get detailNotFoundBody => 'ربما تم حذفه أو تغيير معرّفه.';

  @override
  String get callPlaceholder =>
      'الاتصال المباشر غير متاح بعد — الرقم منسوخ؟ استخدم زر النسخ.';

  @override
  String get searchIdleBody =>
      'ابحث في كل المحتوى بالعامية أو بالكود أو بالرقم — بدون إنترنت.';

  @override
  String get searchEmptyTitle => 'لا توجد نتائج';

  @override
  String get searchEmptyBody =>
      'جرّب كلمة أخرى، أو اكتب الكود أو الرقم مباشرة.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get trainingReviewTitle => 'راجع البنود غير المؤكدة';

  @override
  String trainingReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بند يحتاج مراجعة داخلية',
      many: '$count بندًا يحتاج مراجعة داخلية',
      few: '$count بنود تحتاج مراجعة داخلية',
      two: 'بندان يحتاجان مراجعة داخلية',
      one: 'بند واحد يحتاج مراجعة داخلية',
      zero: 'لا توجد بنود تحتاج مراجعة',
    );
    return '$_temp0';
  }

  @override
  String get reviewScreenTitle => 'البنود غير المؤكدة';

  @override
  String get reviewScreenSubtitle =>
      'كل البنود غير المؤكدة أو المتعارضة من كل الأقسام.';
}
