import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navPackages.
  ///
  /// In ar, this message translates to:
  /// **'الباقات'**
  String get navPackages;

  /// No description provided for @navCodes.
  ///
  /// In ar, this message translates to:
  /// **'الأكواد والأرقام'**
  String get navCodes;

  /// No description provided for @navMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @greetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get greetingMorning;

  /// No description provided for @greetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get greetingEvening;

  /// No description provided for @homeSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن باقة، كود، رقم…'**
  String get homeSearchHint;

  /// No description provided for @homeSectionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get homeSectionsTitle;

  /// No description provided for @sectionPackages.
  ///
  /// In ar, this message translates to:
  /// **'الباقات'**
  String get sectionPackages;

  /// No description provided for @sectionNumbersCodes.
  ///
  /// In ar, this message translates to:
  /// **'الأكواد والأرقام'**
  String get sectionNumbersCodes;

  /// No description provided for @sectionWallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get sectionWallet;

  /// No description provided for @sectionGlossary.
  ///
  /// In ar, this message translates to:
  /// **'المصطلحات'**
  String get sectionGlossary;

  /// No description provided for @searchFieldHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب كلمة أو كودًا أو رقمًا'**
  String get searchFieldHint;

  /// No description provided for @searchClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get searchClear;

  /// No description provided for @trainingTitle.
  ///
  /// In ar, this message translates to:
  /// **'التدريب'**
  String get trainingTitle;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'اضغط القلب داخل أي بند ليظهر هنا.'**
  String get favoritesEmpty;

  /// No description provided for @showAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get showAll;

  /// No description provided for @showAllCount.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل ({count})'**
  String showAllCount(int count);

  /// No description provided for @segmentMobile.
  ///
  /// In ar, this message translates to:
  /// **'موبايل'**
  String get segmentMobile;

  /// No description provided for @segmentMobileInternet.
  ///
  /// In ar, this message translates to:
  /// **'إنترنت موبايل'**
  String get segmentMobileInternet;

  /// No description provided for @segmentHome.
  ///
  /// In ar, this message translates to:
  /// **'منزلي'**
  String get segmentHome;

  /// No description provided for @sortTitle.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب'**
  String get sortTitle;

  /// No description provided for @sortPriceUp.
  ///
  /// In ar, this message translates to:
  /// **'الأرخص أولًا'**
  String get sortPriceUp;

  /// No description provided for @sortPriceDown.
  ///
  /// In ar, this message translates to:
  /// **'الأغلى أولًا'**
  String get sortPriceDown;

  /// No description provided for @sortQuota.
  ///
  /// In ar, this message translates to:
  /// **'الأكبر إنترنت'**
  String get sortQuota;

  /// No description provided for @toolCompareShort.
  ///
  /// In ar, this message translates to:
  /// **'قارن'**
  String get toolCompareShort;

  /// No description provided for @toolRecommendShort.
  ///
  /// In ar, this message translates to:
  /// **'رشّح'**
  String get toolRecommendShort;

  /// No description provided for @toolCalculatorShort.
  ///
  /// In ar, this message translates to:
  /// **'احسب'**
  String get toolCalculatorShort;

  /// No description provided for @packagesInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'قواعد ومعلومات'**
  String get packagesInfoTitle;

  /// No description provided for @hotlinesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرقام خدمة العملاء'**
  String get hotlinesTitle;

  /// No description provided for @codesNotesTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات وخدمات'**
  String get codesNotesTitle;

  /// No description provided for @moreToolsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدواتي'**
  String get moreToolsTitle;

  /// No description provided for @moreNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظاتي'**
  String get moreNotes;

  /// No description provided for @moreEditor.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المحتوى'**
  String get moreEditor;

  /// No description provided for @moreWhatsNew.
  ///
  /// In ar, this message translates to:
  /// **'الجديد في المحتوى'**
  String get moreWhatsNew;

  /// No description provided for @moreSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المظهر واللغة'**
  String get moreSettingsTitle;

  /// No description provided for @editedByYou.
  ///
  /// In ar, this message translates to:
  /// **'معدّل منك'**
  String get editedByYou;

  /// No description provided for @editedByYouOn.
  ///
  /// In ar, this message translates to:
  /// **'معدّل منك · {date}'**
  String editedByYouOn(String date);

  /// No description provided for @statusPerGuide.
  ///
  /// In ar, this message translates to:
  /// **'حسب الدليل'**
  String get statusPerGuide;

  /// No description provided for @daysCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{يوم} =2{يومين} few{{count} أيام} other{{count} يوم}}'**
  String daysCount(int count);

  /// No description provided for @quotaGb.
  ///
  /// In ar, this message translates to:
  /// **'{n} جيجا'**
  String quotaGb(String n);

  /// No description provided for @quotaMb.
  ///
  /// In ar, this message translates to:
  /// **'{n} ميجا'**
  String quotaMb(String n);

  /// No description provided for @quotaMix.
  ///
  /// In ar, this message translates to:
  /// **'{n} ميكس'**
  String quotaMix(String n);

  /// No description provided for @quotaMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{n} دقيقة'**
  String quotaMinutes(String n);

  /// No description provided for @currencyShort.
  ///
  /// In ar, this message translates to:
  /// **'ج'**
  String get currencyShort;

  /// No description provided for @packageNoPriceShort.
  ///
  /// In ar, this message translates to:
  /// **'بدون سعر'**
  String get packageNoPriceShort;

  /// No description provided for @settingsAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @copyValueSemantics.
  ///
  /// In ar, this message translates to:
  /// **'نسخ {value}'**
  String copyValueSemantics(String value);

  /// No description provided for @copiedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copiedMessage;

  /// No description provided for @callValueSemantics.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بـ {value}'**
  String callValueSemantics(String value);

  /// No description provided for @symbolStar.
  ///
  /// In ar, this message translates to:
  /// **'نجمة'**
  String get symbolStar;

  /// No description provided for @symbolHash.
  ///
  /// In ar, this message translates to:
  /// **'مربع'**
  String get symbolHash;

  /// No description provided for @symbolPlus.
  ///
  /// In ar, this message translates to:
  /// **'زائد'**
  String get symbolPlus;

  /// No description provided for @currencyEgp.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get currencyEgp;

  /// No description provided for @sectionInternet.
  ///
  /// In ar, this message translates to:
  /// **'الإنترنت'**
  String get sectionInternet;

  /// No description provided for @sectionProcedures.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات الفرع'**
  String get sectionProcedures;

  /// No description provided for @sectionCompany.
  ///
  /// In ar, this message translates to:
  /// **'عن الشركة'**
  String get sectionCompany;

  /// No description provided for @homeMustKnowTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر استخدامًا'**
  String get homeMustKnowTitle;

  /// No description provided for @contentAsOf.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث للمحتوى: {date}'**
  String contentAsOf(String date);

  /// No description provided for @contentEmptySection.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محتوى في هذا القسم بعد'**
  String get contentEmptySection;

  /// No description provided for @contentEmptySectionBody.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر المحتوى هنا فور إضافته.'**
  String get contentEmptySectionBody;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @statusConfirmedGuide.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد حسب الدليل'**
  String get statusConfirmedGuide;

  /// No description provided for @statusConfirmedOfficial.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد من الموقع الرسمي'**
  String get statusConfirmedOfficial;

  /// No description provided for @statusUnconfirmedReview.
  ///
  /// In ar, this message translates to:
  /// **'غير مؤكد — راجع داخليًا'**
  String get statusUnconfirmedReview;

  /// No description provided for @unconfirmedBannerBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع النظام الداخلي أو مشرفك قبل إبلاغ العميل.'**
  String get unconfirmedBannerBody;

  /// No description provided for @detailFactsTitle.
  ///
  /// In ar, this message translates to:
  /// **'كل التفاصيل'**
  String get detailFactsTitle;

  /// No description provided for @detailStepsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخطوات'**
  String get detailStepsTitle;

  /// No description provided for @detailSourcesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المصادر'**
  String get detailSourcesTitle;

  /// No description provided for @detailRelatedTitle.
  ///
  /// In ar, this message translates to:
  /// **'بنود ذات صلة'**
  String get detailRelatedTitle;

  /// No description provided for @detailPdfPages.
  ///
  /// In ar, this message translates to:
  /// **'من الدليل صفحة {pages}'**
  String detailPdfPages(String pages);

  /// No description provided for @detailNotFound.
  ///
  /// In ar, this message translates to:
  /// **'البند غير موجود'**
  String get detailNotFound;

  /// No description provided for @detailNotFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'ربما تم حذفه أو تغيير معرّفه.'**
  String get detailNotFoundBody;

  /// No description provided for @searchIdleBody.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في كل المحتوى بالعامية أو بالكود أو بالرقم — بدون إنترنت.'**
  String get searchIdleBody;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة أخرى، أو اكتب الكود أو الرقم مباشرة.'**
  String get searchEmptyBody;

  /// No description provided for @searchResultsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{نتيجة واحدة} =2{نتيجتان} few{{count} نتائج} many{{count} نتيجة} other{{count} نتيجة}}'**
  String searchResultsCount(int count);

  /// No description provided for @languageSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب لغة الجهاز'**
  String get languageSystem;

  /// No description provided for @homeRecentTitle.
  ///
  /// In ar, this message translates to:
  /// **'آخر ما فتحته'**
  String get homeRecentTitle;

  /// No description provided for @searchRecentTitle.
  ///
  /// In ar, this message translates to:
  /// **'عمليات بحث سابقة'**
  String get searchRecentTitle;

  /// No description provided for @searchRecentClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح السجل'**
  String get searchRecentClear;

  /// No description provided for @packagePriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get packagePriceLabel;

  /// No description provided for @packageCodeTitle.
  ///
  /// In ar, this message translates to:
  /// **'كود الاشتراك'**
  String get packageCodeTitle;

  /// No description provided for @packageDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get packageDetailsTitle;

  /// No description provided for @packageNotesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والملاحظات'**
  String get packageNotesTitle;

  /// No description provided for @packageNoPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر غير مذكور في الدليل'**
  String get packageNoPrice;

  /// No description provided for @packageConflictPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر عليه تعارض — راجع القيمتين'**
  String get packageConflictPrice;

  /// No description provided for @sectionJumpTo.
  ///
  /// In ar, this message translates to:
  /// **'انتقل إلى {name}'**
  String sectionJumpTo(String name);

  /// No description provided for @detailOverviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'الشرح'**
  String get detailOverviewTitle;

  /// No description provided for @toolsNotStated.
  ///
  /// In ar, this message translates to:
  /// **'غير مذكور'**
  String get toolsNotStated;

  /// No description provided for @toolsCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get toolsCancel;

  /// No description provided for @toolsSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get toolsSave;

  /// No description provided for @toolsDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get toolsDelete;

  /// No description provided for @toolsUndo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get toolsUndo;

  /// No description provided for @toolsPickPackage.
  ///
  /// In ar, this message translates to:
  /// **'اختار باقة'**
  String get toolsPickPackage;

  /// No description provided for @toolsSearchPackage.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن باقة'**
  String get toolsSearchPackage;

  /// No description provided for @toolsNoMatches.
  ///
  /// In ar, this message translates to:
  /// **'مفيش نتيجة'**
  String get toolsNoMatches;

  /// No description provided for @toolsItemRemoved.
  ///
  /// In ar, this message translates to:
  /// **'البند ده اتشال من المحتوى'**
  String get toolsItemRemoved;

  /// No description provided for @toolsEditedOn.
  ///
  /// In ar, this message translates to:
  /// **'معدّل منك – {date}'**
  String toolsEditedOn(String date);

  /// No description provided for @toolsInvalidNumber.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رقم صحيح'**
  String get toolsInvalidNumber;

  /// No description provided for @toolsDial.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get toolsDial;

  /// No description provided for @toolsDialFillTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب البيانات قبل الاتصال'**
  String get toolsDialFillTitle;

  /// No description provided for @toolsDialFillHint.
  ///
  /// In ar, this message translates to:
  /// **'مش بنحفظ اللي بتكتبه. الكود هيتفتح في برنامج الاتصال وإنت تضغط اتصال.'**
  String get toolsDialFillHint;

  /// No description provided for @toolsDialOpen.
  ///
  /// In ar, this message translates to:
  /// **'افتح برنامج الاتصال'**
  String get toolsDialOpen;

  /// No description provided for @toolsDialDigitsOnly.
  ///
  /// In ar, this message translates to:
  /// **'أرقام بس'**
  String get toolsDialDigitsOnly;

  /// No description provided for @toolsDialChoose.
  ///
  /// In ar, this message translates to:
  /// **'اختار اللي هتطلبه'**
  String get toolsDialChoose;

  /// No description provided for @toolsDialFailed.
  ///
  /// In ar, this message translates to:
  /// **'برنامج الاتصال مفتحش، فنسخنا {value}'**
  String toolsDialFailed(String value);

  /// No description provided for @toolsDialFailedTemplate.
  ///
  /// In ar, this message translates to:
  /// **'برنامج الاتصال مفتحش، فنسخنا الكود من غير اللي كتبته'**
  String get toolsDialFailedTemplate;

  /// No description provided for @toolsDialNothing.
  ///
  /// In ar, this message translates to:
  /// **'مفيش كود أو رقم يتطلب، فنسخنا النص'**
  String get toolsDialNothing;

  /// No description provided for @toolsFavorite.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get toolsFavorite;

  /// No description provided for @toolsFavoriteAdd.
  ///
  /// In ar, this message translates to:
  /// **'ضيف للمفضلة'**
  String get toolsFavoriteAdd;

  /// No description provided for @toolsFavoriteRemove.
  ///
  /// In ar, this message translates to:
  /// **'شيل من المفضلة'**
  String get toolsFavoriteRemove;

  /// No description provided for @toolsFavoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get toolsFavoritesTitle;

  /// No description provided for @toolsFavoritesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مفضلة لسه'**
  String get toolsFavoritesEmpty;

  /// No description provided for @toolsFavoritesEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'دوس على القلب في أي بند وهتلاقيه هنا.'**
  String get toolsFavoritesEmptyBody;

  /// No description provided for @toolsFavoritesHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب عشان ترتّبها'**
  String get toolsFavoritesHint;

  /// No description provided for @toolsReorder.
  ///
  /// In ar, this message translates to:
  /// **'غيّر ترتيب {name}'**
  String toolsReorder(String name);

  /// No description provided for @toolsCompareAction.
  ///
  /// In ar, this message translates to:
  /// **'قارن'**
  String get toolsCompareAction;

  /// No description provided for @toolsNoteAction.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get toolsNoteAction;

  /// No description provided for @toolsNoteCount.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات ({count})'**
  String toolsNoteCount(int count);

  /// No description provided for @toolsEditAction.
  ///
  /// In ar, this message translates to:
  /// **'عدّل'**
  String get toolsEditAction;

  /// No description provided for @toolsCompareTitle.
  ///
  /// In ar, this message translates to:
  /// **'قارن باقات'**
  String get toolsCompareTitle;

  /// No description provided for @toolsCompareHint.
  ///
  /// In ar, this message translates to:
  /// **'اختار من 2 لـ 4 باقات'**
  String get toolsCompareHint;

  /// No description provided for @toolsCompareAdd.
  ///
  /// In ar, this message translates to:
  /// **'ضيف باقة'**
  String get toolsCompareAdd;

  /// No description provided for @toolsCompareRemove.
  ///
  /// In ar, this message translates to:
  /// **'شيل {name}'**
  String toolsCompareRemove(String name);

  /// No description provided for @toolsComparePeriods.
  ///
  /// In ar, this message translates to:
  /// **'المدد مختلفة أو مش مذكورة، فمش بنعلّم الأقل سعرًا ولا الأعلى حصة.'**
  String get toolsComparePeriods;

  /// No description provided for @toolsRowPackage.
  ///
  /// In ar, this message translates to:
  /// **'الباقة'**
  String get toolsRowPackage;

  /// No description provided for @toolsRowPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get toolsRowPrice;

  /// No description provided for @toolsRowTotal.
  ///
  /// In ar, this message translates to:
  /// **'شامل الضريبة'**
  String get toolsRowTotal;

  /// No description provided for @toolsRowQuota.
  ///
  /// In ar, this message translates to:
  /// **'الحصة'**
  String get toolsRowQuota;

  /// No description provided for @toolsRowGb.
  ///
  /// In ar, this message translates to:
  /// **'الإنترنت (جيجا)'**
  String get toolsRowGb;

  /// No description provided for @toolsRowMinutes.
  ///
  /// In ar, this message translates to:
  /// **'الدقائق'**
  String get toolsRowMinutes;

  /// No description provided for @toolsRowMix.
  ///
  /// In ar, this message translates to:
  /// **'الميكسات'**
  String get toolsRowMix;

  /// No description provided for @toolsRowValidity.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحية'**
  String get toolsRowValidity;

  /// No description provided for @toolsRowCode.
  ///
  /// In ar, this message translates to:
  /// **'الكود'**
  String get toolsRowCode;

  /// No description provided for @toolsRowAfter.
  ///
  /// In ar, this message translates to:
  /// **'بعد الباقة'**
  String get toolsRowAfter;

  /// No description provided for @toolsRowStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get toolsRowStatus;

  /// No description provided for @toolsBestLowest.
  ///
  /// In ar, this message translates to:
  /// **'الأقل'**
  String get toolsBestLowest;

  /// No description provided for @toolsBestHighest.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى'**
  String get toolsBestHighest;

  /// No description provided for @toolsBestLongest.
  ///
  /// In ar, this message translates to:
  /// **'الأطول'**
  String get toolsBestLongest;

  /// No description provided for @toolsStatusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get toolsStatusConfirmed;

  /// No description provided for @toolsStatusUnconfirmed.
  ///
  /// In ar, this message translates to:
  /// **'غير مؤكد'**
  String get toolsStatusUnconfirmed;

  /// No description provided for @toolsStatusConflict.
  ///
  /// In ar, this message translates to:
  /// **'متعارض'**
  String get toolsStatusConflict;

  /// No description provided for @toolsRecommendTitle.
  ///
  /// In ar, this message translates to:
  /// **'رشّح باقة'**
  String get toolsRecommendTitle;

  /// No description provided for @toolsRecommendSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اللي العميل محتاجه وسيب الباقي فاضي'**
  String get toolsRecommendSubtitle;

  /// No description provided for @toolsRecommendBudget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية (جنيه)'**
  String get toolsRecommendBudget;

  /// No description provided for @toolsRecommendGb.
  ///
  /// In ar, this message translates to:
  /// **'إنترنت (جيجا)'**
  String get toolsRecommendGb;

  /// No description provided for @toolsRecommendMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق'**
  String get toolsRecommendMinutes;

  /// No description provided for @toolsUseMobile.
  ///
  /// In ar, this message translates to:
  /// **'موبايل'**
  String get toolsUseMobile;

  /// No description provided for @toolsUseHome.
  ///
  /// In ar, this message translates to:
  /// **'منزلي'**
  String get toolsUseHome;

  /// No description provided for @toolsRecommendStart.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ميزانية أو جيجا أو دقائق'**
  String get toolsRecommendStart;

  /// No description provided for @toolsRecommendFits.
  ///
  /// In ar, this message translates to:
  /// **'تغطي كل الطلبات'**
  String get toolsRecommendFits;

  /// No description provided for @toolsRecommendNone.
  ///
  /// In ar, this message translates to:
  /// **'مفيش باقة في المحتوى تغطي كل الطلبات بالأرقام المذكورة.'**
  String get toolsRecommendNone;

  /// No description provided for @toolsRecommendMaybe.
  ///
  /// In ar, this message translates to:
  /// **'ممكن تناسب، وفيها حاجة مش مذكورة'**
  String get toolsRecommendMaybe;

  /// No description provided for @toolsRecommendClosest.
  ///
  /// In ar, this message translates to:
  /// **'أقرب الباقات، بس مش كاملة'**
  String get toolsRecommendClosest;

  /// No description provided for @toolsBudgetMet.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة {value} جنيه، جوه الميزانية'**
  String toolsBudgetMet(String value);

  /// No description provided for @toolsBudgetMissed.
  ///
  /// In ar, this message translates to:
  /// **'السعر {value} جنيه، أعلى من الميزانية'**
  String toolsBudgetMissed(String value);

  /// No description provided for @toolsBudgetUnknown.
  ///
  /// In ar, this message translates to:
  /// **'السعر {value} جنيه، والتكلفة شاملة الضريبة مش مذكورة'**
  String toolsBudgetUnknown(String value);

  /// No description provided for @toolsBudgetNotStated.
  ///
  /// In ar, this message translates to:
  /// **'السعر مش مذكور'**
  String get toolsBudgetNotStated;

  /// No description provided for @toolsGbMet.
  ///
  /// In ar, this message translates to:
  /// **'{value} جيجا، تكفي'**
  String toolsGbMet(String value);

  /// No description provided for @toolsGbMissed.
  ///
  /// In ar, this message translates to:
  /// **'{value} جيجا، أقل من المطلوب'**
  String toolsGbMissed(String value);

  /// No description provided for @toolsGbMix.
  ///
  /// In ar, this message translates to:
  /// **'الحصة {value} ميكس، والجيجا مش مذكورة'**
  String toolsGbMix(String value);

  /// No description provided for @toolsGbNotStated.
  ///
  /// In ar, this message translates to:
  /// **'الجيجا مش مذكورة'**
  String get toolsGbNotStated;

  /// No description provided for @toolsMinutesMet.
  ///
  /// In ar, this message translates to:
  /// **'{value} دقيقة، تكفي'**
  String toolsMinutesMet(String value);

  /// No description provided for @toolsMinutesMissed.
  ///
  /// In ar, this message translates to:
  /// **'{value} دقيقة، أقل من المطلوب'**
  String toolsMinutesMissed(String value);

  /// No description provided for @toolsMinutesMix.
  ///
  /// In ar, this message translates to:
  /// **'الحصة {value} ميكس، والدقائق مش مذكورة'**
  String toolsMinutesMix(String value);

  /// No description provided for @toolsMinutesNotStated.
  ///
  /// In ar, this message translates to:
  /// **'الدقائق مش مذكورة'**
  String get toolsMinutesNotStated;

  /// No description provided for @toolsMixNote.
  ///
  /// In ar, this message translates to:
  /// **'اللي مكتوب عن الاستهلاك: {text}'**
  String toolsMixNote(String text);

  /// No description provided for @toolsCalcTitle.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة الشحن'**
  String get toolsCalcTitle;

  /// No description provided for @toolsCalcModeCard.
  ///
  /// In ar, this message translates to:
  /// **'عندي كارت'**
  String get toolsCalcModeCard;

  /// No description provided for @toolsCalcModePrice.
  ///
  /// In ar, this message translates to:
  /// **'عندي سعر باقة'**
  String get toolsCalcModePrice;

  /// No description provided for @toolsCalcCardLabel.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الكارت (جنيه)'**
  String get toolsCalcCardLabel;

  /// No description provided for @toolsCalcPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الباقة قبل الضريبة (جنيه)'**
  String get toolsCalcPriceLabel;

  /// No description provided for @toolsCalcBalanceResult.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد اللي هيوصل'**
  String get toolsCalcBalanceResult;

  /// No description provided for @toolsCalcCardResult.
  ///
  /// In ar, this message translates to:
  /// **'الكارت المطلوب'**
  String get toolsCalcCardResult;

  /// No description provided for @toolsCalcEgp.
  ///
  /// In ar, this message translates to:
  /// **'{value} جنيه'**
  String toolsCalcEgp(String value);

  /// No description provided for @toolsCalcTaxPart.
  ///
  /// In ar, this message translates to:
  /// **'الفرق {value} جنيه ضرايب ورسوم'**
  String toolsCalcTaxPart(String value);

  /// No description provided for @toolsCalcStated.
  ///
  /// In ar, this message translates to:
  /// **'المكتوب في المحتوى شامل الضريبة: {value}'**
  String toolsCalcStated(String value);

  /// No description provided for @toolsCalcComputed.
  ///
  /// In ar, this message translates to:
  /// **'رقم محسوب من النسبة اللي تحت، مش سعر منشور.'**
  String get toolsCalcComputed;

  /// No description provided for @toolsCalcSource.
  ///
  /// In ar, this message translates to:
  /// **'مصدر الحساب'**
  String get toolsCalcSource;

  /// No description provided for @toolsCalcRatio.
  ///
  /// In ar, this message translates to:
  /// **'كل {card} جنيه كارت = {balance} جنيه رصيد'**
  String toolsCalcRatio(String card, String balance);

  /// No description provided for @toolsCalcUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الحاسبة مش متاحة'**
  String get toolsCalcUnavailable;

  /// No description provided for @toolsCalcUnavailableBody.
  ///
  /// In ar, this message translates to:
  /// **'البند اللي فيه نسبة الشحن مش موجود أو نسبته مش واضحة، ومش بنحسب برقم من عندنا.'**
  String get toolsCalcUnavailableBody;

  /// No description provided for @toolsWhatsNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'إيه اللي اتغير'**
  String get toolsWhatsNewTitle;

  /// No description provided for @toolsWhatsNewEmpty.
  ///
  /// In ar, this message translates to:
  /// **'مفيش تغيير متسجل'**
  String get toolsWhatsNewEmpty;

  /// No description provided for @toolsWhatsNewEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'لما المحتوى يتحدّث، التغيير في الأسعار والأكواد هيظهر هنا.'**
  String get toolsWhatsNewEmptyBody;

  /// No description provided for @toolsWhatsNewOn.
  ///
  /// In ar, this message translates to:
  /// **'تحديث {date}'**
  String toolsWhatsNewOn(String date);

  /// No description provided for @toolsWhatsNewRemoved.
  ///
  /// In ar, this message translates to:
  /// **'اتشال {count} بند'**
  String toolsWhatsNewRemoved(int count);

  /// No description provided for @toolsWhatsNewAdded.
  ///
  /// In ar, this message translates to:
  /// **'{count} بند جديد'**
  String toolsWhatsNewAdded(int count);

  /// No description provided for @toolsWhatsNewMore.
  ///
  /// In ar, this message translates to:
  /// **'و{count} تاني'**
  String toolsWhatsNewMore(int count);

  /// No description provided for @toolsWhatsNewBanner.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى اتحدّث. شوف إيه اللي اتغير'**
  String get toolsWhatsNewBanner;

  /// No description provided for @toolsWas.
  ///
  /// In ar, this message translates to:
  /// **'كان'**
  String get toolsWas;

  /// No description provided for @toolsNow.
  ///
  /// In ar, this message translates to:
  /// **'بقى'**
  String get toolsNow;

  /// No description provided for @editorMyEdits.
  ///
  /// In ar, this message translates to:
  /// **'تعديلاتي'**
  String get editorMyEdits;

  /// No description provided for @editorLocalOnly.
  ///
  /// In ar, this message translates to:
  /// **'التعديلات على الموبايل ده بس، ومحدش غيرك بيشوفها. لو مسحت التطبيق هتروح، فصدّرها لو مهمة.'**
  String get editorLocalOnly;

  /// No description provided for @editorEmpty.
  ///
  /// In ar, this message translates to:
  /// **'مفيش تعديلات'**
  String get editorEmpty;

  /// No description provided for @editorEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'عدّل أي بند من صفحته، أو ضيف بند جديد.'**
  String get editorEmptyBody;

  /// No description provided for @editorAdd.
  ///
  /// In ar, this message translates to:
  /// **'ضيف بند'**
  String get editorAdd;

  /// No description provided for @editorExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get editorExport;

  /// No description provided for @editorImport.
  ///
  /// In ar, this message translates to:
  /// **'استيراد'**
  String get editorImport;

  /// No description provided for @editorStateAdded.
  ///
  /// In ar, this message translates to:
  /// **'بند من إضافتك'**
  String get editorStateAdded;

  /// No description provided for @editorStateHidden.
  ///
  /// In ar, this message translates to:
  /// **'مخفي'**
  String get editorStateHidden;

  /// No description provided for @editorStateNewer.
  ///
  /// In ar, this message translates to:
  /// **'فيه نسخة أحدث من البند ده في التطبيق'**
  String get editorStateNewer;

  /// No description provided for @editorStateRemoved.
  ///
  /// In ar, this message translates to:
  /// **'البند الأصلي اتشال من المحتوى. تعديلك محفوظ بس مش ظاهر.'**
  String get editorStateRemoved;

  /// No description provided for @editorKeepMine.
  ///
  /// In ar, this message translates to:
  /// **'سيب تعديلي'**
  String get editorKeepMine;

  /// No description provided for @editorUseNew.
  ///
  /// In ar, this message translates to:
  /// **'خد الجديدة'**
  String get editorUseNew;

  /// No description provided for @editorRestore.
  ///
  /// In ar, this message translates to:
  /// **'رجّع الأصلي'**
  String get editorRestore;

  /// No description provided for @editorDeleteAdded.
  ///
  /// In ar, this message translates to:
  /// **'امسح البند'**
  String get editorDeleteAdded;

  /// No description provided for @editorRestoreAsk.
  ///
  /// In ar, this message translates to:
  /// **'نرجّع «{name}» للأصل؟'**
  String editorRestoreAsk(String name);

  /// No description provided for @editorDeleteAsk.
  ///
  /// In ar, this message translates to:
  /// **'نمسح «{name}»؟'**
  String editorDeleteAsk(String name);

  /// No description provided for @editorRestoreBody.
  ///
  /// In ar, this message translates to:
  /// **'تعديلك هيتمسح من الموبايل.'**
  String get editorRestoreBody;

  /// No description provided for @editorEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بند'**
  String get editorEditTitle;

  /// No description provided for @editorNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'بند جديد'**
  String get editorNewTitle;

  /// No description provided for @editorFieldTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get editorFieldTitle;

  /// No description provided for @editorFieldSummary.
  ///
  /// In ar, this message translates to:
  /// **'الملخص'**
  String get editorFieldSummary;

  /// No description provided for @editorFieldCategory.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get editorFieldCategory;

  /// No description provided for @editorFieldSection.
  ///
  /// In ar, this message translates to:
  /// **'القسم'**
  String get editorFieldSection;

  /// No description provided for @editorFieldType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get editorFieldType;

  /// No description provided for @editorFieldFacts.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get editorFieldFacts;

  /// No description provided for @editorFactLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get editorFactLabel;

  /// No description provided for @editorFactValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get editorFactValue;

  /// No description provided for @editorFactUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get editorFactUnit;

  /// No description provided for @editorFactKind.
  ///
  /// In ar, this message translates to:
  /// **'نوع القيمة'**
  String get editorFactKind;

  /// No description provided for @editorAddFact.
  ///
  /// In ar, this message translates to:
  /// **'ضيف بيان'**
  String get editorAddFact;

  /// No description provided for @editorRemoveFact.
  ///
  /// In ar, this message translates to:
  /// **'شيل البيان رقم {n}'**
  String editorRemoveFact(int n);

  /// No description provided for @editorFieldCodes.
  ///
  /// In ar, this message translates to:
  /// **'الأكواد، كل كود في سطر'**
  String get editorFieldCodes;

  /// No description provided for @editorFieldPhones.
  ///
  /// In ar, this message translates to:
  /// **'الأرقام، كل رقم في سطر'**
  String get editorFieldPhones;

  /// No description provided for @editorFieldStatusNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة عن الحالة'**
  String get editorFieldStatusNote;

  /// No description provided for @editorHide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء البند'**
  String get editorHide;

  /// No description provided for @editorHideHint.
  ///
  /// In ar, this message translates to:
  /// **'مش هيظهر في القوائم ولا البحث لحد ما ترجّعه من تعديلاتي.'**
  String get editorHideHint;

  /// No description provided for @editorTitleRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب العنوان'**
  String get editorTitleRequired;

  /// No description provided for @editorFactRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الاسم والقيمة، أو شيل البيان'**
  String get editorFactRequired;

  /// No description provided for @editorNotConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'بعد الحفظ هيظهر عليه «معدّل منك» ومش هيتكتب عليه مؤكد لحد ما ترجّع الأصلي.'**
  String get editorNotConfirmed;

  /// No description provided for @editorLeaveAsk.
  ///
  /// In ar, this message translates to:
  /// **'تخرج من غير حفظ؟'**
  String get editorLeaveAsk;

  /// No description provided for @editorLeave.
  ///
  /// In ar, this message translates to:
  /// **'اخرج'**
  String get editorLeave;

  /// No description provided for @editorStay.
  ///
  /// In ar, this message translates to:
  /// **'كمّل تعديل'**
  String get editorStay;

  /// No description provided for @editorSaved.
  ///
  /// In ar, this message translates to:
  /// **'التعديل اتحفظ على الموبايل'**
  String get editorSaved;

  /// No description provided for @editorNothingChanged.
  ///
  /// In ar, this message translates to:
  /// **'مفيش حاجة اتغيرت'**
  String get editorNothingChanged;

  /// No description provided for @editorExportNoNotes.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات الخاصة مش بتتصدّر.'**
  String get editorExportNoNotes;

  /// No description provided for @editorShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get editorShare;

  /// No description provided for @editorCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ النص'**
  String get editorCopy;

  /// No description provided for @editorShareFailed.
  ///
  /// In ar, this message translates to:
  /// **'المشاركة مش متاحة، فنسخنا النص'**
  String get editorShareFailed;

  /// No description provided for @editorCopied.
  ///
  /// In ar, this message translates to:
  /// **'النص اتنسخ'**
  String get editorCopied;

  /// No description provided for @editorImportHint.
  ///
  /// In ar, this message translates to:
  /// **'الصق النص المصدَّر هنا'**
  String get editorImportHint;

  /// No description provided for @editorPaste.
  ///
  /// In ar, this message translates to:
  /// **'لصق'**
  String get editorPaste;

  /// No description provided for @editorImportCheck.
  ///
  /// In ar, this message translates to:
  /// **'افحص'**
  String get editorImportCheck;

  /// No description provided for @editorImportInvalid.
  ///
  /// In ar, this message translates to:
  /// **'النص ده مش تصدير صحيح من التطبيق، ومفيش حاجة اتغيرت.'**
  String get editorImportInvalid;

  /// No description provided for @editorImportDiff.
  ///
  /// In ar, this message translates to:
  /// **'{added} جديد، {replaced} هيتبدّل، {same} زي ما هو'**
  String editorImportDiff(int added, int replaced, int same);

  /// No description provided for @editorImportKeeps.
  ///
  /// In ar, this message translates to:
  /// **'باقي تعديلاتك هتفضل زي ما هي.'**
  String get editorImportKeeps;

  /// No description provided for @editorImportMissing.
  ///
  /// In ar, this message translates to:
  /// **'{count} منهم لبنود مش موجودة في المحتوى الحالي'**
  String editorImportMissing(int count);

  /// No description provided for @editorImportApply.
  ///
  /// In ar, this message translates to:
  /// **'طبّق'**
  String get editorImportApply;

  /// No description provided for @editorImportDone.
  ///
  /// In ar, this message translates to:
  /// **'الاستيراد تم'**
  String get editorImportDone;

  /// No description provided for @editorImportNothing.
  ///
  /// In ar, this message translates to:
  /// **'مفيش فرق عن اللي عندك'**
  String get editorImportNothing;

  /// No description provided for @editorKindPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر'**
  String get editorKindPrice;

  /// No description provided for @editorKindCode.
  ///
  /// In ar, this message translates to:
  /// **'كود'**
  String get editorKindCode;

  /// No description provided for @editorKindPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم'**
  String get editorKindPhone;

  /// No description provided for @editorKindQuantity.
  ///
  /// In ar, this message translates to:
  /// **'كمية'**
  String get editorKindQuantity;

  /// No description provided for @editorKindDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة'**
  String get editorKindDuration;

  /// No description provided for @editorKindPercent.
  ///
  /// In ar, this message translates to:
  /// **'نسبة'**
  String get editorKindPercent;

  /// No description provided for @editorKindDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ'**
  String get editorKindDate;

  /// No description provided for @editorKindText.
  ///
  /// In ar, this message translates to:
  /// **'نص'**
  String get editorKindText;

  /// No description provided for @editorTypePackage.
  ///
  /// In ar, this message translates to:
  /// **'باقة'**
  String get editorTypePackage;

  /// No description provided for @editorTypeCode.
  ///
  /// In ar, this message translates to:
  /// **'كود'**
  String get editorTypeCode;

  /// No description provided for @editorTypeContact.
  ///
  /// In ar, this message translates to:
  /// **'رقم تواصل'**
  String get editorTypeContact;

  /// No description provided for @editorTypeService.
  ///
  /// In ar, this message translates to:
  /// **'خدمة'**
  String get editorTypeService;

  /// No description provided for @editorTypeProcedure.
  ///
  /// In ar, this message translates to:
  /// **'إجراء'**
  String get editorTypeProcedure;

  /// No description provided for @editorTypeFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم'**
  String get editorTypeFee;

  /// No description provided for @editorTypeRule.
  ///
  /// In ar, this message translates to:
  /// **'قاعدة'**
  String get editorTypeRule;

  /// No description provided for @editorTypeArticle.
  ///
  /// In ar, this message translates to:
  /// **'معلومة'**
  String get editorTypeArticle;

  /// No description provided for @editorTypeGlossary.
  ///
  /// In ar, this message translates to:
  /// **'مصطلح'**
  String get editorTypeGlossary;

  /// No description provided for @editorTypeFaq.
  ///
  /// In ar, this message translates to:
  /// **'سؤال شائع'**
  String get editorTypeFaq;

  /// No description provided for @notesTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظاتي'**
  String get notesTitle;

  /// No description provided for @notesWarning.
  ///
  /// In ar, this message translates to:
  /// **'متكتبش أسماء عملاء ولا أرقامهم ولا بياناتهم.'**
  String get notesWarning;

  /// No description provided for @notesLocal.
  ///
  /// In ar, this message translates to:
  /// **'على الموبايل ده بس، ومش بتتصدّر.'**
  String get notesLocal;

  /// No description provided for @notesSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في ملاحظاتك'**
  String get notesSearch;

  /// No description provided for @notesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'مفيش ملاحظات'**
  String get notesEmpty;

  /// No description provided for @notesEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'اكتب حاجة تفتكرها، لوحدها أو على بند.'**
  String get notesEmptyBody;

  /// No description provided for @notesAdd.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة جديدة'**
  String get notesAdd;

  /// No description provided for @notesEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملاحظة'**
  String get notesEdit;

  /// No description provided for @notesHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الملاحظة'**
  String get notesHint;

  /// No description provided for @notesDeleted.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظة اتمسحت'**
  String get notesDeleted;

  /// No description provided for @notesForItem.
  ///
  /// In ar, this message translates to:
  /// **'على: {name}'**
  String notesForItem(String name);

  /// No description provided for @notesDeleteOne.
  ///
  /// In ar, this message translates to:
  /// **'احذف الملاحظة'**
  String get notesDeleteOne;

  /// No description provided for @trainingIntro.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة من المحتوى المؤكد بس'**
  String get trainingIntro;

  /// No description provided for @trainingDaily.
  ///
  /// In ar, this message translates to:
  /// **'سؤال النهارده'**
  String get trainingDaily;

  /// No description provided for @trainingDailyDone.
  ///
  /// In ar, this message translates to:
  /// **'جاوبت سؤال النهارده'**
  String get trainingDailyDone;

  /// No description provided for @trainingCards.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات'**
  String get trainingCards;

  /// No description provided for @trainingCardsDue.
  ///
  /// In ar, this message translates to:
  /// **'{due} للمراجعة النهارده، {fresh} جديدة'**
  String trainingCardsDue(int due, int fresh);

  /// No description provided for @trainingQuiz.
  ///
  /// In ar, this message translates to:
  /// **'اختبار'**
  String get trainingQuiz;

  /// No description provided for @trainingQuizCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} أسئلة باختيارات'**
  String trainingQuizCount(int count);

  /// No description provided for @trainingScenarios.
  ///
  /// In ar, this message translates to:
  /// **'حالات من الفرع'**
  String get trainingScenarios;

  /// No description provided for @trainingScenariosCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} حالة'**
  String trainingScenariosCount(int count);

  /// No description provided for @trainingLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستواك'**
  String get trainingLevel;

  /// No description provided for @trainingMastered.
  ///
  /// In ar, this message translates to:
  /// **'متقنة'**
  String get trainingMastered;

  /// No description provided for @trainingLearning.
  ///
  /// In ar, this message translates to:
  /// **'بتتعلمها'**
  String get trainingLearning;

  /// No description provided for @trainingNew.
  ///
  /// In ar, this message translates to:
  /// **'جديدة'**
  String get trainingNew;

  /// No description provided for @trainingWeakest.
  ///
  /// In ar, this message translates to:
  /// **'محتاجة مراجعة'**
  String get trainingWeakest;

  /// No description provided for @trainingWeakRow.
  ///
  /// In ar, this message translates to:
  /// **'{wrong} غلط من {seen}'**
  String trainingWeakRow(int wrong, int seen);

  /// No description provided for @trainingNothing.
  ///
  /// In ar, this message translates to:
  /// **'مفيش أسئلة دلوقتي'**
  String get trainingNothing;

  /// No description provided for @trainingNothingBody.
  ///
  /// In ar, this message translates to:
  /// **'محتاجين محتوى مؤكد كفاية عشان نعمل أسئلة.'**
  String get trainingNothingBody;

  /// No description provided for @trainingShowAnswer.
  ///
  /// In ar, this message translates to:
  /// **'اعرض الإجابة'**
  String get trainingShowAnswer;

  /// No description provided for @trainingKnew.
  ///
  /// In ar, this message translates to:
  /// **'عرفتها'**
  String get trainingKnew;

  /// No description provided for @trainingDidNot.
  ///
  /// In ar, this message translates to:
  /// **'معرفتهاش'**
  String get trainingDidNot;

  /// No description provided for @trainingNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get trainingNext;

  /// No description provided for @trainingFinish.
  ///
  /// In ar, this message translates to:
  /// **'خلاص'**
  String get trainingFinish;

  /// No description provided for @trainingCorrect.
  ///
  /// In ar, this message translates to:
  /// **'صح'**
  String get trainingCorrect;

  /// No description provided for @trainingWrong.
  ///
  /// In ar, this message translates to:
  /// **'غلط'**
  String get trainingWrong;

  /// No description provided for @trainingOpenItem.
  ///
  /// In ar, this message translates to:
  /// **'افتح البند'**
  String get trainingOpenItem;

  /// No description provided for @trainingQuizResult.
  ///
  /// In ar, this message translates to:
  /// **'{right} صح من {total}'**
  String trainingQuizResult(int right, int total);

  /// No description provided for @trainingReviewWrong.
  ///
  /// In ar, this message translates to:
  /// **'راجع دول'**
  String get trainingReviewWrong;

  /// No description provided for @trainingStep.
  ///
  /// In ar, this message translates to:
  /// **'{index} من {total}'**
  String trainingStep(int index, int total);

  /// No description provided for @trainingDone.
  ///
  /// In ar, this message translates to:
  /// **'خلصت بطاقات النهارده'**
  String get trainingDone;

  /// No description provided for @trainingDoneBody.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات اللي جاوبتها هترجع في ميعادها.'**
  String get trainingDoneBody;

  /// No description provided for @trainingReset.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التدريب من الأول'**
  String get trainingReset;

  /// No description provided for @trainingResetAsk.
  ///
  /// In ar, this message translates to:
  /// **'نمسح تقدّمك في التدريب؟'**
  String get trainingResetAsk;

  /// No description provided for @trainingAskFact.
  ///
  /// In ar, this message translates to:
  /// **'«{title}»: {label}؟'**
  String trainingAskFact(String title, String label);

  /// No description provided for @trainingAskCode.
  ///
  /// In ar, this message translates to:
  /// **'إيه كود «{title}»؟'**
  String trainingAskCode(String title);

  /// No description provided for @trainingAskPhone.
  ///
  /// In ar, this message translates to:
  /// **'إيه رقم «{title}»؟'**
  String trainingAskPhone(String title);

  /// No description provided for @trainingAskTerm.
  ///
  /// In ar, this message translates to:
  /// **'يعني إيه «{title}»؟'**
  String trainingAskTerm(String title);

  /// No description provided for @trainingAskDocuments.
  ///
  /// In ar, this message translates to:
  /// **'إيه المستندات المطلوبة في «{title}»؟'**
  String trainingAskDocuments(String title);

  /// No description provided for @trainingAskFirstStep.
  ///
  /// In ar, this message translates to:
  /// **'إيه أول خطوة في «{title}»؟'**
  String trainingAskFirstStep(String title);

  /// No description provided for @trainingAskScenario.
  ///
  /// In ar, this message translates to:
  /// **'{title}. تعمل إيه؟'**
  String trainingAskScenario(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
