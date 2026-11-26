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
  String get navPackages => 'الباقات';

  @override
  String get navCodes => 'الأكواد والأرقام';

  @override
  String get navMore => 'المزيد';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get homeSearchHint => 'ابحث عن باقة، كود، رقم…';

  @override
  String get homeSectionsTitle => 'الأقسام';

  @override
  String get sectionPackages => 'الباقات';

  @override
  String get sectionNumbersCodes => 'الأكواد والأرقام';

  @override
  String get sectionWallet => 'المحفظة';

  @override
  String get sectionGlossary => 'المصطلحات';

  @override
  String get searchFieldHint => 'اكتب كلمة أو كودًا أو رقمًا';

  @override
  String get searchClear => 'مسح البحث';

  @override
  String get trainingTitle => 'التدريب';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesEmpty => 'اضغط القلب داخل أي بند ليظهر هنا.';

  @override
  String get showAll => 'عرض الكل';

  @override
  String showAllCount(int count) {
    return 'عرض الكل ($count)';
  }

  @override
  String get segmentMobile => 'موبايل';

  @override
  String get segmentMobileInternet => 'إنترنت موبايل';

  @override
  String get segmentHome => 'منزلي';

  @override
  String get sortTitle => 'الترتيب';

  @override
  String get sortPriceUp => 'الأرخص أولًا';

  @override
  String get sortPriceDown => 'الأغلى أولًا';

  @override
  String get sortQuota => 'الأكبر إنترنت';

  @override
  String get toolCompareShort => 'قارن';

  @override
  String get toolRecommendShort => 'رشّح';

  @override
  String get toolCalculatorShort => 'احسب';

  @override
  String get packagesInfoTitle => 'قواعد ومعلومات';

  @override
  String get hotlinesTitle => 'أرقام خدمة العملاء';

  @override
  String get codesNotesTitle => 'ملاحظات وخدمات';

  @override
  String get moreToolsTitle => 'أدواتي';

  @override
  String get moreNotes => 'ملاحظاتي';

  @override
  String get moreEditor => 'تعديل المحتوى';

  @override
  String get moreWhatsNew => 'الجديد في المحتوى';

  @override
  String get moreSettingsTitle => 'المظهر واللغة';

  @override
  String get editedByYou => 'معدّل منك';

  @override
  String editedByYouOn(String date) {
    return 'معدّل منك · $date';
  }

  @override
  String get statusPerGuide => 'حسب الدليل';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      few: '$count أيام',
      two: 'يومين',
      one: 'يوم',
    );
    return '$_temp0';
  }

  @override
  String quotaGb(String n) {
    return '$n جيجا';
  }

  @override
  String quotaMix(String n) {
    return '$n ميكس';
  }

  @override
  String quotaMinutes(String n) {
    return '$n دقيقة';
  }

  @override
  String get currencyShort => 'ج';

  @override
  String get packageNoPriceShort => 'بدون سعر';

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
  String copyValueSemantics(String value) {
    return 'نسخ $value';
  }

  @override
  String get copiedMessage => 'تم النسخ';

  @override
  String callValueSemantics(String value) {
    return 'اتصال بـ $value';
  }

  @override
  String get symbolStar => 'نجمة';

  @override
  String get symbolHash => 'مربع';

  @override
  String get symbolPlus => 'زائد';

  @override
  String get currencyEgp => 'ج.م';

  @override
  String get sectionInternet => 'الإنترنت';

  @override
  String get sectionProcedures => 'إجراءات الفرع';

  @override
  String get sectionCompany => 'عن الشركة';

  @override
  String get homeMustKnowTitle => 'الأكثر استخدامًا';

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
  String get statusConfirmedGuide => 'مؤكد حسب الدليل';

  @override
  String get statusConfirmedOfficial => 'مؤكد من الموقع الرسمي';

  @override
  String get statusUnconfirmedReview => 'غير مؤكد — راجع داخليًا';

  @override
  String get unconfirmedBannerBody =>
      'راجع النظام الداخلي أو مشرفك قبل إبلاغ العميل.';

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
  String get languageSystem => 'حسب لغة الجهاز';

  @override
  String get homeRecentTitle => 'آخر ما فتحته';

  @override
  String get searchRecentTitle => 'عمليات بحث سابقة';

  @override
  String get searchRecentClear => 'مسح السجل';

  @override
  String get packagePriceLabel => 'السعر';

  @override
  String get packageCodeTitle => 'كود الاشتراك';

  @override
  String get packageDetailsTitle => 'التفاصيل';

  @override
  String get packageNotesTitle => 'الشروط والملاحظات';

  @override
  String get packageNoPrice => 'السعر غير مذكور في الدليل';

  @override
  String get packageConflictPrice => 'السعر عليه تعارض — راجع القيمتين';

  @override
  String sectionJumpTo(String name) {
    return 'انتقل إلى $name';
  }

  @override
  String get detailOverviewTitle => 'الشرح';

  @override
  String get toolsNotStated => 'غير مذكور';

  @override
  String get toolsCancel => 'إلغاء';

  @override
  String get toolsSave => 'حفظ';

  @override
  String get toolsDelete => 'حذف';

  @override
  String get toolsUndo => 'تراجع';

  @override
  String get toolsPickPackage => 'اختر باقة';

  @override
  String get toolsSearchPackage => 'ابحث عن باقة';

  @override
  String get toolsNoMatches => 'لا توجد نتائج';

  @override
  String get toolsItemRemoved => 'هذا البند لم يعد في المحتوى';

  @override
  String toolsEditedOn(String date) {
    return 'معدّل منك – $date';
  }

  @override
  String get toolsInvalidNumber => 'اكتب رقمًا صحيحًا';

  @override
  String get toolsDial => 'اتصال';

  @override
  String get toolsDialFillTitle => 'اكتب البيانات قبل الاتصال';

  @override
  String get toolsDialFillHint =>
      'لا نحفظ ما تكتبه. سيُفتح الكود في تطبيق الاتصال، وتضغط أنت اتصال.';

  @override
  String get toolsDialOpen => 'افتح تطبيق الاتصال';

  @override
  String get toolsDialDigitsOnly => 'أرقام فقط';

  @override
  String get toolsDialChoose => 'اختر ما تريد طلبه';

  @override
  String toolsDialFailed(String value) {
    return 'تعذّر فتح تطبيق الاتصال، وتم نسخ $value';
  }

  @override
  String get toolsDialFailedTemplate =>
      'تعذّر فتح تطبيق الاتصال، وتم نسخ الكود بدون ما كتبته';

  @override
  String get toolsDialNothing => 'لا يوجد كود أو رقم للاتصال، وتم نسخ النص';

  @override
  String get toolsFavorite => 'المفضلة';

  @override
  String get toolsFavoriteAdd => 'أضف إلى المفضلة';

  @override
  String get toolsFavoriteRemove => 'أزل من المفضلة';

  @override
  String get toolsFavoritesTitle => 'المفضلة';

  @override
  String get toolsFavoritesEmpty => 'لا توجد مفضلة بعد';

  @override
  String get toolsFavoritesEmptyBody => 'اضغط القلب في أي بند ليظهر هنا.';

  @override
  String get toolsFavoritesHint => 'اسحب لتغيير الترتيب';

  @override
  String toolsReorder(String name) {
    return 'غيّر ترتيب $name';
  }

  @override
  String get toolsCompareAction => 'قارن';

  @override
  String get toolsNoteAction => 'ملاحظة';

  @override
  String toolsNoteCount(int count) {
    return 'ملاحظات ($count)';
  }

  @override
  String get toolsEditAction => 'عدّل';

  @override
  String get toolsCompareTitle => 'قارن الباقات';

  @override
  String get toolsCompareHint => 'اختر من باقتين إلى 4 باقات';

  @override
  String get toolsCompareAdd => 'أضف باقة';

  @override
  String toolsCompareRemove(String name) {
    return 'أزل $name';
  }

  @override
  String get toolsComparePeriods =>
      'المدد مختلفة أو غير مذكورة، لذلك لا نحدد الأقل سعرًا أو الأعلى حصة.';

  @override
  String get toolsRowPackage => 'الباقة';

  @override
  String get toolsRowPrice => 'السعر';

  @override
  String get toolsRowTotal => 'شامل الضريبة';

  @override
  String get toolsRowQuota => 'الحصة';

  @override
  String get toolsRowGb => 'الإنترنت (جيجا)';

  @override
  String get toolsRowMinutes => 'الدقائق';

  @override
  String get toolsRowMix => 'الميكسات';

  @override
  String get toolsRowValidity => 'الصلاحية';

  @override
  String get toolsRowCode => 'الكود';

  @override
  String get toolsRowAfter => 'بعد الباقة';

  @override
  String get toolsRowStatus => 'الحالة';

  @override
  String get toolsBestLowest => 'الأقل';

  @override
  String get toolsBestHighest => 'الأعلى';

  @override
  String get toolsBestLongest => 'الأطول';

  @override
  String get toolsStatusConfirmed => 'مؤكد';

  @override
  String get toolsStatusUnconfirmed => 'غير مؤكد';

  @override
  String get toolsStatusConflict => 'متعارض';

  @override
  String get toolsRecommendTitle => 'رشّح باقة';

  @override
  String get toolsRecommendSubtitle =>
      'اكتب ما يحتاجه العميل واترك الباقي فارغًا';

  @override
  String get toolsRecommendBudget => 'الميزانية (جنيه)';

  @override
  String get toolsRecommendGb => 'إنترنت (جيجا)';

  @override
  String get toolsRecommendMinutes => 'دقائق';

  @override
  String get toolsUseMobile => 'موبايل';

  @override
  String get toolsUseHome => 'منزلي';

  @override
  String get toolsRecommendStart => 'اكتب الميزانية أو الجيجا أو الدقائق';

  @override
  String get toolsRecommendFits => 'تغطي كل الطلبات';

  @override
  String get toolsRecommendNone =>
      'لا توجد باقة تغطي كل الطلبات بالأرقام المذكورة.';

  @override
  String get toolsRecommendMaybe => 'قد تناسب، وبها قيمة غير مذكورة';

  @override
  String get toolsRecommendClosest => 'أقرب الباقات (لا تغطي كل الطلبات)';

  @override
  String toolsBudgetMet(String value) {
    return 'التكلفة $value جنيه، في حدود الميزانية';
  }

  @override
  String toolsBudgetMissed(String value) {
    return 'السعر $value جنيه، أعلى من الميزانية';
  }

  @override
  String toolsBudgetUnknown(String value) {
    return 'السعر $value جنيه، والتكلفة شاملة الضريبة غير مذكورة';
  }

  @override
  String get toolsBudgetNotStated => 'السعر غير مذكور';

  @override
  String toolsGbMet(String value) {
    return '$value، تكفي';
  }

  @override
  String toolsGbMissed(String value) {
    return '$value، أقل من المطلوب';
  }

  @override
  String toolsGbMix(String value) {
    return 'الحصة $value ميكس، والجيجا غير مذكورة';
  }

  @override
  String get toolsGbNotStated => 'الجيجا غير مذكورة';

  @override
  String toolsMinutesMet(String value) {
    return '$value دقيقة، تكفي';
  }

  @override
  String toolsMinutesMissed(String value) {
    return '$value دقيقة، أقل من المطلوب';
  }

  @override
  String toolsMinutesMix(String value) {
    return 'الحصة $value ميكس، والدقائق غير مذكورة';
  }

  @override
  String get toolsMinutesNotStated => 'الدقائق غير مذكورة';

  @override
  String toolsMixNote(String text) {
    return 'طريقة الاستهلاك: $text';
  }

  @override
  String get toolsCalcTitle => 'حاسبة الشحن';

  @override
  String get toolsCalcModeCard => 'عندي كارت';

  @override
  String get toolsCalcModePrice => 'عندي سعر باقة';

  @override
  String get toolsCalcCardLabel => 'قيمة الكارت (جنيه)';

  @override
  String get toolsCalcPriceLabel => 'سعر الباقة قبل الضريبة (جنيه)';

  @override
  String get toolsCalcBalanceResult => 'الرصيد الذي سيصل';

  @override
  String get toolsCalcCardResult => 'الكارت المطلوب';

  @override
  String toolsCalcEgp(String value) {
    return '$value جنيه';
  }

  @override
  String toolsCalcTaxPart(String value) {
    return 'الفرق $value جنيه ضرائب ورسوم';
  }

  @override
  String toolsCalcStated(String value) {
    return 'المذكور في المحتوى شامل الضريبة: $value';
  }

  @override
  String get toolsCalcComputed =>
      'رقم محسوب من النسبة الموضحة، وليس سعرًا منشورًا.';

  @override
  String get toolsCalcSource => 'مصدر الحساب';

  @override
  String toolsCalcRatio(String card, String balance) {
    return 'كل $card جنيه كارت = $balance جنيه رصيد';
  }

  @override
  String get toolsCalcUnavailable => 'الحاسبة غير متاحة';

  @override
  String get toolsCalcUnavailableBody =>
      'بند نسبة الشحن غير موجود أو نسبته غير واضحة، ولا نحسب برقم من عندنا.';

  @override
  String get toolsWhatsNewTitle => 'الجديد في المحتوى';

  @override
  String get toolsWhatsNewEmpty => 'لا توجد تغييرات مسجلة';

  @override
  String get toolsWhatsNewEmptyBody =>
      'عند تحديث المحتوى تظهر هنا تغييرات الأسعار والأكواد.';

  @override
  String toolsWhatsNewOn(String date) {
    return 'تحديث $date';
  }

  @override
  String toolsWhatsNewRemoved(int count) {
    return 'حُذف $count بند';
  }

  @override
  String toolsWhatsNewAdded(int count) {
    return '$count بند جديد';
  }

  @override
  String toolsWhatsNewMore(int count) {
    return 'و$count أخرى';
  }

  @override
  String get toolsWhatsNewBanner => 'تم تحديث المحتوى. اعرف ما تغيّر';

  @override
  String get toolsWas => 'كان';

  @override
  String get toolsNow => 'الآن';

  @override
  String get editorMyEdits => 'تعديلاتي';

  @override
  String get editorLocalOnly =>
      'التعديلات محفوظة على هذا الموبايل فقط ولا يراها غيرك. حذف التطبيق يمسحها، فصدّر المهم منها.';

  @override
  String get editorEmpty => 'لا توجد تعديلات';

  @override
  String get editorEmptyBody => 'عدّل أي بند من صفحته، أو أضف بندًا جديدًا.';

  @override
  String get editorAdd => 'أضف بندًا';

  @override
  String get editorExport => 'تصدير';

  @override
  String get editorImport => 'استيراد';

  @override
  String get editorStateAdded => 'بند من إضافتك';

  @override
  String get editorStateHidden => 'مخفي';

  @override
  String get editorStateNewer => 'توجد نسخة أحدث من هذا البند في التطبيق';

  @override
  String get editorStateRemoved =>
      'البند الأصلي حُذف من المحتوى. تعديلك محفوظ لكنه غير ظاهر.';

  @override
  String get editorKeepMine => 'احتفظ بتعديلي';

  @override
  String get editorUseNew => 'استخدم الجديدة';

  @override
  String get editorRestore => 'استرجع الأصل';

  @override
  String get editorDeleteAdded => 'احذف البند';

  @override
  String editorRestoreAsk(String name) {
    return 'استرجاع «$name» إلى الأصل؟';
  }

  @override
  String editorDeleteAsk(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get editorRestoreBody => 'سيُحذف تعديلك من الموبايل.';

  @override
  String get editorEditTitle => 'تعديل بند';

  @override
  String get editorNewTitle => 'بند جديد';

  @override
  String get editorFieldTitle => 'العنوان';

  @override
  String get editorFieldSummary => 'الملخص';

  @override
  String get editorFieldCategory => 'المجموعة';

  @override
  String get editorFieldSection => 'القسم';

  @override
  String get editorFieldType => 'النوع';

  @override
  String get editorFieldFacts => 'البيانات';

  @override
  String get editorFactLabel => 'الاسم';

  @override
  String get editorFactValue => 'القيمة';

  @override
  String get editorFactUnit => 'الوحدة';

  @override
  String get editorFactKind => 'نوع القيمة';

  @override
  String get editorAddFact => 'أضف بيانًا';

  @override
  String editorRemoveFact(int n) {
    return 'أزل البيان رقم $n';
  }

  @override
  String get editorFieldCodes => 'الأكواد، كل كود في سطر';

  @override
  String get editorFieldPhones => 'الأرقام، كل رقم في سطر';

  @override
  String get editorFieldStatusNote => 'ملاحظة عن الحالة';

  @override
  String get editorHide => 'إخفاء البند';

  @override
  String get editorHideHint =>
      'لن يظهر في القوائم أو البحث حتى تسترجعه من تعديلاتي.';

  @override
  String get editorTitleRequired => 'اكتب العنوان';

  @override
  String get editorFactRequired => 'اكتب الاسم والقيمة، أو أزل البيان';

  @override
  String get editorNotConfirmed =>
      'بعد الحفظ يظهر عليه «معدّل منك» ولا يُكتب عليه مؤكد حتى تسترجع الأصل.';

  @override
  String get editorLeaveAsk => 'الخروج بدون حفظ؟';

  @override
  String get editorLeave => 'خروج';

  @override
  String get editorStay => 'أكمل التعديل';

  @override
  String get editorSaved => 'تم حفظ التعديل على الموبايل';

  @override
  String get editorNothingChanged => 'لم يتغير شيء';

  @override
  String get editorExportNoNotes => 'الملاحظات الخاصة لا تُصدَّر.';

  @override
  String get editorShare => 'مشاركة';

  @override
  String get editorCopy => 'نسخ النص';

  @override
  String get editorShareFailed => 'المشاركة غير متاحة، تم نسخ النص';

  @override
  String get editorCopied => 'تم نسخ النص';

  @override
  String get editorImportHint => 'الصق النص المصدَّر هنا';

  @override
  String get editorPaste => 'لصق';

  @override
  String get editorImportCheck => 'فحص';

  @override
  String get editorImportInvalid =>
      'هذا النص ليس تصديرًا صحيحًا من التطبيق، ولم يتغير شيء.';

  @override
  String editorImportDiff(int added, int replaced, int same) {
    return '$added جديد، $replaced سيُستبدل، $same بدون تغيير';
  }

  @override
  String get editorImportKeeps => 'باقي تعديلاتك تبقى كما هي.';

  @override
  String editorImportMissing(int count) {
    return '$count منها لبنود غير موجودة في المحتوى الحالي';
  }

  @override
  String get editorImportApply => 'تطبيق';

  @override
  String get editorImportDone => 'تم الاستيراد';

  @override
  String get editorImportNothing => 'لا فرق عمّا لديك';

  @override
  String get editorKindPrice => 'سعر';

  @override
  String get editorKindCode => 'كود';

  @override
  String get editorKindPhone => 'رقم';

  @override
  String get editorKindQuantity => 'كمية';

  @override
  String get editorKindDuration => 'مدة';

  @override
  String get editorKindPercent => 'نسبة';

  @override
  String get editorKindDate => 'تاريخ';

  @override
  String get editorKindText => 'نص';

  @override
  String get editorTypePackage => 'باقة';

  @override
  String get editorTypeCode => 'كود';

  @override
  String get editorTypeContact => 'رقم تواصل';

  @override
  String get editorTypeService => 'خدمة';

  @override
  String get editorTypeProcedure => 'إجراء';

  @override
  String get editorTypeFee => 'رسوم';

  @override
  String get editorTypeRule => 'قاعدة';

  @override
  String get editorTypeArticle => 'معلومة';

  @override
  String get editorTypeGlossary => 'مصطلح';

  @override
  String get editorTypeFaq => 'سؤال شائع';

  @override
  String get notesTitle => 'ملاحظاتي';

  @override
  String get notesWarning => 'لا تكتب أسماء العملاء أو أرقامهم أو بياناتهم.';

  @override
  String get notesLocal => 'على هذا الموبايل فقط، ولا تُصدَّر.';

  @override
  String get notesSearch => 'ابحث في ملاحظاتك';

  @override
  String get notesEmpty => 'لا توجد ملاحظات';

  @override
  String get notesEmptyBody => 'اكتب ما تريد تذكره، وحده أو على بند.';

  @override
  String get notesAdd => 'ملاحظة جديدة';

  @override
  String get notesEdit => 'تعديل الملاحظة';

  @override
  String get notesHint => 'اكتب الملاحظة';

  @override
  String get notesDeleted => 'تم حذف الملاحظة';

  @override
  String notesForItem(String name) {
    return 'على: $name';
  }

  @override
  String get notesDeleteOne => 'احذف الملاحظة';

  @override
  String get trainingIntro => 'الأسئلة من المحتوى المؤكد فقط';

  @override
  String get trainingDaily => 'سؤال اليوم';

  @override
  String get trainingDailyDone => 'أجبت عن سؤال اليوم';

  @override
  String get trainingCards => 'البطاقات';

  @override
  String trainingCardsDue(int due, int fresh) {
    return '$due للمراجعة اليوم، $fresh جديدة';
  }

  @override
  String get trainingQuiz => 'اختبار';

  @override
  String trainingQuizCount(int count) {
    return '$count أسئلة باختيارات';
  }

  @override
  String get trainingScenarios => 'حالات من الفرع';

  @override
  String trainingScenariosCount(int count) {
    return '$count حالة';
  }

  @override
  String get trainingLevel => 'مستواك';

  @override
  String get trainingMastered => 'متقنة';

  @override
  String get trainingLearning => 'قيد التعلم';

  @override
  String get trainingNew => 'جديدة';

  @override
  String get trainingWeakest => 'تحتاج مراجعة';

  @override
  String trainingWeakRow(int wrong, int seen) {
    return '$wrong خطأ من $seen';
  }

  @override
  String get trainingNothing => 'لا توجد أسئلة الآن';

  @override
  String get trainingNothingBody => 'نحتاج محتوى مؤكدًا كافيًا لإعداد الأسئلة.';

  @override
  String get trainingShowAnswer => 'اعرض الإجابة';

  @override
  String get trainingKnew => 'عرفتها';

  @override
  String get trainingDidNot => 'لم أعرفها';

  @override
  String get trainingNext => 'التالي';

  @override
  String get trainingFinish => 'إنهاء';

  @override
  String get trainingCorrect => 'صحيح';

  @override
  String get trainingWrong => 'خطأ';

  @override
  String get trainingOpenItem => 'افتح البند';

  @override
  String trainingQuizResult(int right, int total) {
    return '$right صحيحة من $total';
  }

  @override
  String get trainingReviewWrong => 'راجع هذه الأسئلة';

  @override
  String trainingStep(int index, int total) {
    return '$index من $total';
  }

  @override
  String get trainingDone => 'انتهت بطاقات اليوم';

  @override
  String get trainingDoneBody => 'البطاقات التي أجبت عنها تعود في موعدها.';

  @override
  String get trainingReset => 'ابدأ التدريب من جديد';

  @override
  String get trainingResetAsk => 'مسح تقدّمك في التدريب؟';

  @override
  String trainingAskFact(String title, String label) {
    return '«$title»: $label؟';
  }

  @override
  String trainingAskCode(String title) {
    return 'ما كود «$title»؟';
  }

  @override
  String trainingAskPhone(String title) {
    return 'ما رقم «$title»؟';
  }

  @override
  String trainingAskTerm(String title) {
    return 'ما معنى «$title»؟';
  }

  @override
  String trainingAskDocuments(String title) {
    return 'ما المستندات المطلوبة في «$title»؟';
  }

  @override
  String trainingAskFirstStep(String title) {
    return 'ما أول خطوة في «$title»؟';
  }

  @override
  String trainingAskScenario(String title) {
    return '$title. ماذا تفعل؟';
  }

  @override
  String get searchQuickTitle => 'بحث سريع';

  @override
  String get searchAllSections => 'ابحث في كل الأقسام';

  @override
  String get detailStepsReset => 'من البداية';

  @override
  String get toolsShareSummary => 'مشاركة';

  @override
  String get toolsSummaryCopied => 'المشاركة غير متاحة، تم نسخ الملخص';

  @override
  String get customerView => 'عرض للعميل';

  @override
  String get customerViewOff => 'إنهاء عرض العميل';

  @override
  String get moreContentTitle => 'قاعدة المعلومات';

  @override
  String get moreStatItems => 'كل البنود';

  @override
  String get moreStatOfficial => 'من الموقع الرسمي';

  @override
  String get moreClearHistory => 'مسح سجل البحث وآخر ما فتحته';

  @override
  String get moreHistoryCleared => 'تم مسح السجل';

  @override
  String get editorFieldBody => 'الشرح';

  @override
  String get editorFieldSteps => 'الخطوات، كل خطوة في سطر';

  @override
  String detailStepsProgress(int done, int total) {
    return '$done من $total';
  }
}
