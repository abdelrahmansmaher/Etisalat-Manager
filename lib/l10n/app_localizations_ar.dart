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
  String quotaMb(String n) {
    return '$n ميجا';
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
  String get toolsPickPackage => 'اختار باقة';

  @override
  String get toolsSearchPackage => 'ابحث عن باقة';

  @override
  String get toolsNoMatches => 'مفيش نتيجة';

  @override
  String get toolsItemRemoved => 'البند ده اتشال من المحتوى';

  @override
  String toolsEditedOn(String date) {
    return 'معدّل منك – $date';
  }

  @override
  String get toolsInvalidNumber => 'اكتب رقم صحيح';

  @override
  String get toolsDial => 'اتصال';

  @override
  String get toolsDialFillTitle => 'اكتب البيانات قبل الاتصال';

  @override
  String get toolsDialFillHint =>
      'مش بنحفظ اللي بتكتبه. الكود هيتفتح في برنامج الاتصال وإنت تضغط اتصال.';

  @override
  String get toolsDialOpen => 'افتح برنامج الاتصال';

  @override
  String get toolsDialDigitsOnly => 'أرقام بس';

  @override
  String get toolsDialChoose => 'اختار اللي هتطلبه';

  @override
  String toolsDialFailed(String value) {
    return 'برنامج الاتصال مفتحش، فنسخنا $value';
  }

  @override
  String get toolsDialFailedTemplate =>
      'برنامج الاتصال مفتحش، فنسخنا الكود من غير اللي كتبته';

  @override
  String get toolsDialNothing => 'مفيش كود أو رقم يتطلب، فنسخنا النص';

  @override
  String get toolsFavorite => 'المفضلة';

  @override
  String get toolsFavoriteAdd => 'ضيف للمفضلة';

  @override
  String get toolsFavoriteRemove => 'شيل من المفضلة';

  @override
  String get toolsFavoritesTitle => 'المفضلة';

  @override
  String get toolsFavoritesEmpty => 'مفيش مفضلة لسه';

  @override
  String get toolsFavoritesEmptyBody => 'دوس على القلب في أي بند وهتلاقيه هنا.';

  @override
  String get toolsFavoritesHint => 'اسحب عشان ترتّبها';

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
  String get toolsCompareTitle => 'قارن باقات';

  @override
  String get toolsCompareHint => 'اختار من 2 لـ 4 باقات';

  @override
  String get toolsCompareAdd => 'ضيف باقة';

  @override
  String toolsCompareRemove(String name) {
    return 'شيل $name';
  }

  @override
  String get toolsComparePeriods =>
      'المدد مختلفة أو مش مذكورة، فمش بنعلّم الأقل سعرًا ولا الأعلى حصة.';

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
      'اكتب اللي العميل محتاجه وسيب الباقي فاضي';

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
  String get toolsRecommendStart => 'اكتب ميزانية أو جيجا أو دقائق';

  @override
  String get toolsRecommendFits => 'تغطي كل الطلبات';

  @override
  String get toolsRecommendNone =>
      'مفيش باقة في المحتوى تغطي كل الطلبات بالأرقام المذكورة.';

  @override
  String get toolsRecommendMaybe => 'ممكن تناسب، وفيها حاجة مش مذكورة';

  @override
  String get toolsRecommendClosest => 'أقرب الباقات، بس مش كاملة';

  @override
  String toolsBudgetMet(String value) {
    return 'التكلفة $value جنيه، جوه الميزانية';
  }

  @override
  String toolsBudgetMissed(String value) {
    return 'السعر $value جنيه، أعلى من الميزانية';
  }

  @override
  String toolsBudgetUnknown(String value) {
    return 'السعر $value جنيه، والتكلفة شاملة الضريبة مش مذكورة';
  }

  @override
  String get toolsBudgetNotStated => 'السعر مش مذكور';

  @override
  String toolsGbMet(String value) {
    return '$value جيجا، تكفي';
  }

  @override
  String toolsGbMissed(String value) {
    return '$value جيجا، أقل من المطلوب';
  }

  @override
  String toolsGbMix(String value) {
    return 'الحصة $value ميكس، والجيجا مش مذكورة';
  }

  @override
  String get toolsGbNotStated => 'الجيجا مش مذكورة';

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
    return 'الحصة $value ميكس، والدقائق مش مذكورة';
  }

  @override
  String get toolsMinutesNotStated => 'الدقائق مش مذكورة';

  @override
  String toolsMixNote(String text) {
    return 'اللي مكتوب عن الاستهلاك: $text';
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
  String get toolsCalcBalanceResult => 'الرصيد اللي هيوصل';

  @override
  String get toolsCalcCardResult => 'الكارت المطلوب';

  @override
  String toolsCalcEgp(String value) {
    return '$value جنيه';
  }

  @override
  String toolsCalcTaxPart(String value) {
    return 'الفرق $value جنيه ضرايب ورسوم';
  }

  @override
  String toolsCalcStated(String value) {
    return 'المكتوب في المحتوى شامل الضريبة: $value';
  }

  @override
  String get toolsCalcComputed => 'رقم محسوب من النسبة اللي تحت، مش سعر منشور.';

  @override
  String get toolsCalcSource => 'مصدر الحساب';

  @override
  String toolsCalcRatio(String card, String balance) {
    return 'كل $card جنيه كارت = $balance جنيه رصيد';
  }

  @override
  String get toolsCalcUnavailable => 'الحاسبة مش متاحة';

  @override
  String get toolsCalcUnavailableBody =>
      'البند اللي فيه نسبة الشحن مش موجود أو نسبته مش واضحة، ومش بنحسب برقم من عندنا.';

  @override
  String get toolsWhatsNewTitle => 'إيه اللي اتغير';

  @override
  String get toolsWhatsNewEmpty => 'مفيش تغيير متسجل';

  @override
  String get toolsWhatsNewEmptyBody =>
      'لما المحتوى يتحدّث، التغيير في الأسعار والأكواد هيظهر هنا.';

  @override
  String toolsWhatsNewOn(String date) {
    return 'تحديث $date';
  }

  @override
  String toolsWhatsNewRemoved(int count) {
    return 'اتشال $count بند';
  }

  @override
  String toolsWhatsNewAdded(int count) {
    return '$count بند جديد';
  }

  @override
  String toolsWhatsNewMore(int count) {
    return 'و$count تاني';
  }

  @override
  String get toolsWhatsNewBanner => 'المحتوى اتحدّث. شوف إيه اللي اتغير';

  @override
  String get toolsWas => 'كان';

  @override
  String get toolsNow => 'بقى';

  @override
  String get editorMyEdits => 'تعديلاتي';

  @override
  String get editorLocalOnly =>
      'التعديلات على الموبايل ده بس، ومحدش غيرك بيشوفها. لو مسحت التطبيق هتروح، فصدّرها لو مهمة.';

  @override
  String get editorEmpty => 'مفيش تعديلات';

  @override
  String get editorEmptyBody => 'عدّل أي بند من صفحته، أو ضيف بند جديد.';

  @override
  String get editorAdd => 'ضيف بند';

  @override
  String get editorExport => 'تصدير';

  @override
  String get editorImport => 'استيراد';

  @override
  String get editorStateAdded => 'بند من إضافتك';

  @override
  String get editorStateHidden => 'مخفي';

  @override
  String get editorStateNewer => 'فيه نسخة أحدث من البند ده في التطبيق';

  @override
  String get editorStateRemoved =>
      'البند الأصلي اتشال من المحتوى. تعديلك محفوظ بس مش ظاهر.';

  @override
  String get editorKeepMine => 'سيب تعديلي';

  @override
  String get editorUseNew => 'خد الجديدة';

  @override
  String get editorRestore => 'رجّع الأصلي';

  @override
  String get editorDeleteAdded => 'امسح البند';

  @override
  String editorRestoreAsk(String name) {
    return 'نرجّع «$name» للأصل؟';
  }

  @override
  String editorDeleteAsk(String name) {
    return 'نمسح «$name»؟';
  }

  @override
  String get editorRestoreBody => 'تعديلك هيتمسح من الموبايل.';

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
  String get editorAddFact => 'ضيف بيان';

  @override
  String editorRemoveFact(int n) {
    return 'شيل البيان رقم $n';
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
      'مش هيظهر في القوائم ولا البحث لحد ما ترجّعه من تعديلاتي.';

  @override
  String get editorTitleRequired => 'اكتب العنوان';

  @override
  String get editorFactRequired => 'اكتب الاسم والقيمة، أو شيل البيان';

  @override
  String get editorNotConfirmed =>
      'بعد الحفظ هيظهر عليه «معدّل منك» ومش هيتكتب عليه مؤكد لحد ما ترجّع الأصلي.';

  @override
  String get editorLeaveAsk => 'تخرج من غير حفظ؟';

  @override
  String get editorLeave => 'اخرج';

  @override
  String get editorStay => 'كمّل تعديل';

  @override
  String get editorSaved => 'التعديل اتحفظ على الموبايل';

  @override
  String get editorNothingChanged => 'مفيش حاجة اتغيرت';

  @override
  String get editorExportNoNotes => 'الملاحظات الخاصة مش بتتصدّر.';

  @override
  String get editorShare => 'مشاركة';

  @override
  String get editorCopy => 'نسخ النص';

  @override
  String get editorShareFailed => 'المشاركة مش متاحة، فنسخنا النص';

  @override
  String get editorCopied => 'النص اتنسخ';

  @override
  String get editorImportHint => 'الصق النص المصدَّر هنا';

  @override
  String get editorPaste => 'لصق';

  @override
  String get editorImportCheck => 'افحص';

  @override
  String get editorImportInvalid =>
      'النص ده مش تصدير صحيح من التطبيق، ومفيش حاجة اتغيرت.';

  @override
  String editorImportDiff(int added, int replaced, int same) {
    return '$added جديد، $replaced هيتبدّل، $same زي ما هو';
  }

  @override
  String get editorImportKeeps => 'باقي تعديلاتك هتفضل زي ما هي.';

  @override
  String editorImportMissing(int count) {
    return '$count منهم لبنود مش موجودة في المحتوى الحالي';
  }

  @override
  String get editorImportApply => 'طبّق';

  @override
  String get editorImportDone => 'الاستيراد تم';

  @override
  String get editorImportNothing => 'مفيش فرق عن اللي عندك';

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
  String get notesWarning => 'متكتبش أسماء عملاء ولا أرقامهم ولا بياناتهم.';

  @override
  String get notesLocal => 'على الموبايل ده بس، ومش بتتصدّر.';

  @override
  String get notesSearch => 'ابحث في ملاحظاتك';

  @override
  String get notesEmpty => 'مفيش ملاحظات';

  @override
  String get notesEmptyBody => 'اكتب حاجة تفتكرها، لوحدها أو على بند.';

  @override
  String get notesAdd => 'ملاحظة جديدة';

  @override
  String get notesEdit => 'تعديل الملاحظة';

  @override
  String get notesHint => 'اكتب الملاحظة';

  @override
  String get notesDeleted => 'الملاحظة اتمسحت';

  @override
  String notesForItem(String name) {
    return 'على: $name';
  }

  @override
  String get notesDeleteOne => 'احذف الملاحظة';

  @override
  String get trainingIntro => 'الأسئلة من المحتوى المؤكد بس';

  @override
  String get trainingDaily => 'سؤال النهارده';

  @override
  String get trainingDailyDone => 'جاوبت سؤال النهارده';

  @override
  String get trainingCards => 'البطاقات';

  @override
  String trainingCardsDue(int due, int fresh) {
    return '$due للمراجعة النهارده، $fresh جديدة';
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
  String get trainingLearning => 'بتتعلمها';

  @override
  String get trainingNew => 'جديدة';

  @override
  String get trainingWeakest => 'محتاجة مراجعة';

  @override
  String trainingWeakRow(int wrong, int seen) {
    return '$wrong غلط من $seen';
  }

  @override
  String get trainingNothing => 'مفيش أسئلة دلوقتي';

  @override
  String get trainingNothingBody => 'محتاجين محتوى مؤكد كفاية عشان نعمل أسئلة.';

  @override
  String get trainingShowAnswer => 'اعرض الإجابة';

  @override
  String get trainingKnew => 'عرفتها';

  @override
  String get trainingDidNot => 'معرفتهاش';

  @override
  String get trainingNext => 'التالي';

  @override
  String get trainingFinish => 'خلاص';

  @override
  String get trainingCorrect => 'صح';

  @override
  String get trainingWrong => 'غلط';

  @override
  String get trainingOpenItem => 'افتح البند';

  @override
  String trainingQuizResult(int right, int total) {
    return '$right صح من $total';
  }

  @override
  String get trainingReviewWrong => 'راجع دول';

  @override
  String trainingStep(int index, int total) {
    return '$index من $total';
  }

  @override
  String get trainingDone => 'خلصت بطاقات النهارده';

  @override
  String get trainingDoneBody => 'البطاقات اللي جاوبتها هترجع في ميعادها.';

  @override
  String get trainingReset => 'ابدأ التدريب من الأول';

  @override
  String get trainingResetAsk => 'نمسح تقدّمك في التدريب؟';

  @override
  String trainingAskFact(String title, String label) {
    return '«$title»: $label؟';
  }

  @override
  String trainingAskCode(String title) {
    return 'إيه كود «$title»؟';
  }

  @override
  String trainingAskPhone(String title) {
    return 'إيه رقم «$title»؟';
  }

  @override
  String trainingAskTerm(String title) {
    return 'يعني إيه «$title»؟';
  }

  @override
  String trainingAskDocuments(String title) {
    return 'إيه المستندات المطلوبة في «$title»؟';
  }

  @override
  String trainingAskFirstStep(String title) {
    return 'إيه أول خطوة في «$title»؟';
  }

  @override
  String trainingAskScenario(String title) {
    return '$title. تعمل إيه؟';
  }
}
