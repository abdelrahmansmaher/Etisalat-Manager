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

  /// No description provided for @navBrowse.
  ///
  /// In ar, this message translates to:
  /// **'تصفح'**
  String get navBrowse;

  /// No description provided for @navSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get navSearch;

  /// No description provided for @navTraining.
  ///
  /// In ar, this message translates to:
  /// **'التدريب'**
  String get navTraining;

  /// No description provided for @navMe.
  ///
  /// In ar, this message translates to:
  /// **'أنا'**
  String get navMe;

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

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كل ما تحتاجه على الكاونتر في مكان واحد'**
  String get homeHeroSubtitle;

  /// No description provided for @homeSectionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر قسمًا للاستكشاف'**
  String get homeSectionsSubtitle;

  /// No description provided for @sectionPackagesDesc.
  ///
  /// In ar, this message translates to:
  /// **'العروض والأسعار وأكواد الاشتراك'**
  String get sectionPackagesDesc;

  /// No description provided for @sectionServicesDesc.
  ///
  /// In ar, this message translates to:
  /// **'خدمات الموبايل والإضافات'**
  String get sectionServicesDesc;

  /// No description provided for @sectionNumbersCodesDesc.
  ///
  /// In ar, this message translates to:
  /// **'أكواد USSD وأرقام الخدمة'**
  String get sectionNumbersCodesDesc;

  /// No description provided for @sectionWalletDesc.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة الإلكترونية والتحويلات'**
  String get sectionWalletDesc;

  /// No description provided for @sectionGlossaryDesc.
  ///
  /// In ar, this message translates to:
  /// **'مصطلحات الأنظمة والفرع'**
  String get sectionGlossaryDesc;

  /// No description provided for @browseSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كل الموسوعات في مكان واحد'**
  String get browseSubtitle;

  /// No description provided for @searchExampleTitle.
  ///
  /// In ar, this message translates to:
  /// **'مثال توضيحي — بيانات وهمية'**
  String get searchExampleTitle;

  /// No description provided for @searchExampleItem.
  ///
  /// In ar, this message translates to:
  /// **'باقة تجريبية'**
  String get searchExampleItem;

  /// No description provided for @searchExampleSource.
  ///
  /// In ar, this message translates to:
  /// **'الموقع العام (مثال)'**
  String get searchExampleSource;

  /// No description provided for @homeSectionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الموسوعات'**
  String get homeSectionsTitle;

  /// No description provided for @sectionPackages.
  ///
  /// In ar, this message translates to:
  /// **'الباقات'**
  String get sectionPackages;

  /// No description provided for @sectionServices.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get sectionServices;

  /// No description provided for @sectionNumbersCodes.
  ///
  /// In ar, this message translates to:
  /// **'الأرقام والأكواد'**
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

  /// No description provided for @browseTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصفح الموسوعات'**
  String get browseTitle;

  /// No description provided for @contentComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى قيد الإعداد'**
  String get contentComingSoon;

  /// No description provided for @searchTitle.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get searchTitle;

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

  /// No description provided for @searchPlaceholderBody.
  ///
  /// In ar, this message translates to:
  /// **'البحث قيد الإنشاء — سيعمل بدون إنترنت وبالعامية.'**
  String get searchPlaceholderBody;

  /// No description provided for @trainingTitle.
  ///
  /// In ar, this message translates to:
  /// **'التدريب'**
  String get trainingTitle;

  /// No description provided for @trainingPlaceholderBody.
  ///
  /// In ar, this message translates to:
  /// **'مسارات التعلم والمراجعة اليومية — قريبًا.'**
  String get trainingPlaceholderBody;

  /// No description provided for @meTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنا'**
  String get meTitle;

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

  /// No description provided for @aboutTitle.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutTitle;

  /// No description provided for @editorModeTitle.
  ///
  /// In ar, this message translates to:
  /// **'وضع المحرر (دخول المالك)'**
  String get editorModeTitle;

  /// No description provided for @editorModeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قريبًا'**
  String get editorModeSubtitle;

  /// No description provided for @disclaimerShort.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق مستقل وغير رسمي — تحقق دائمًا من المصادر الرسمية.'**
  String get disclaimerShort;

  /// No description provided for @disclaimerFull.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق مستقل وغير رسمي، غير تابع لأي شركة اتصالات ولا معتمد منها. المعلومات للاسترشاد ويجب الرجوع للمصادر الرسمية المعتمدة.'**
  String get disclaimerFull;

  /// No description provided for @copyAction.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copyAction;

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

  /// No description provided for @callAction.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get callAction;

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

  /// No description provided for @statusVerified.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق'**
  String get statusVerified;

  /// No description provided for @statusNeedsReview.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج مراجعة'**
  String get statusNeedsReview;

  /// No description provided for @statusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get statusExpired;

  /// No description provided for @statusUnverified.
  ///
  /// In ar, this message translates to:
  /// **'بدون مصدر معتمد'**
  String get statusUnverified;

  /// No description provided for @statusConflict.
  ///
  /// In ar, this message translates to:
  /// **'تعارض'**
  String get statusConflict;

  /// No description provided for @statusPrivate.
  ///
  /// In ar, this message translates to:
  /// **'خاص'**
  String get statusPrivate;

  /// No description provided for @lastVerified.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحقق: {relative}'**
  String lastVerified(String relative);

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{اليوم} =1{منذ يوم} =2{منذ يومين} few{منذ {count} أيام} many{منذ {count} يومًا} other{منذ {count} يوم}}'**
  String daysAgo(int count);

  /// No description provided for @verifiedOn.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق في {date}'**
  String verifiedOn(String date);

  /// No description provided for @sourceOfficialInternal.
  ///
  /// In ar, this message translates to:
  /// **'مستند رسمي داخلي'**
  String get sourceOfficialInternal;

  /// No description provided for @sourceOfficialPublic.
  ///
  /// In ar, this message translates to:
  /// **'مصدر رسمي علني'**
  String get sourceOfficialPublic;

  /// No description provided for @sourceTraining.
  ///
  /// In ar, this message translates to:
  /// **'مادة تدريبية معتمدة'**
  String get sourceTraining;

  /// No description provided for @sourceSupervisor.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد مشرف (موثّق)'**
  String get sourceSupervisor;

  /// No description provided for @sourceExternal.
  ///
  /// In ar, this message translates to:
  /// **'مرجع عام'**
  String get sourceExternal;

  /// No description provided for @sourceOwnerNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة المالك'**
  String get sourceOwnerNote;

  /// No description provided for @sourceSemantics.
  ///
  /// In ar, this message translates to:
  /// **'المصدر: {name}، {type}'**
  String sourceSemantics(String name, String type);

  /// No description provided for @conflictTitle.
  ///
  /// In ar, this message translates to:
  /// **'يوجد تعارض بين مصدرين حول هذه المعلومة'**
  String get conflictTitle;

  /// No description provided for @conflictGuidance.
  ///
  /// In ar, this message translates to:
  /// **'لا تُبلغ العميل بقيمة نهائية — راجع المصدر الرسمي أو المشرف.'**
  String get conflictGuidance;

  /// No description provided for @conflictAction.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة المصادر'**
  String get conflictAction;

  /// No description provided for @privateBadge.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة خاصة — للمالك فقط'**
  String get privateBadge;

  /// No description provided for @currencyEgp.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get currencyEgp;

  /// No description provided for @taxInclusiveRecharge.
  ///
  /// In ar, this message translates to:
  /// **'شامل ضريبة الشحن'**
  String get taxInclusiveRecharge;

  /// No description provided for @taxExclusiveVat.
  ///
  /// In ar, this message translates to:
  /// **'غير شامل ضريبة القيمة المضافة'**
  String get taxExclusiveVat;

  /// No description provided for @taxUnknown.
  ///
  /// In ar, this message translates to:
  /// **'أساس الضريبة غير محدد'**
  String get taxUnknown;

  /// No description provided for @priceValidRange.
  ///
  /// In ar, this message translates to:
  /// **'ساري من {from} حتى {until}'**
  String priceValidRange(String from, String until);

  /// No description provided for @priceValidFrom.
  ///
  /// In ar, this message translates to:
  /// **'ساري من {from}'**
  String priceValidFrom(String from);

  /// No description provided for @priceNoEndDate.
  ///
  /// In ar, this message translates to:
  /// **'بدون تاريخ انتهاء معلن'**
  String get priceNoEndDate;

  /// No description provided for @priceEndsIn.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{ينتهي اليوم} =1{ينتهي غدًا} =2{ينتهي خلال يومين} few{ينتهي خلال {count} أيام} many{ينتهي خلال {count} يومًا} other{ينتهي خلال {count} يوم}}'**
  String priceEndsIn(int count);

  /// No description provided for @priceStartsOn.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ في {date} — ليس السعر الحالي'**
  String priceStartsOn(String date);

  /// No description provided for @priceExpiredNote.
  ///
  /// In ar, this message translates to:
  /// **'انتهى في {date} — لا تستخدمه كسعر ساري'**
  String priceExpiredNote(String date);

  /// No description provided for @sectionInternet.
  ///
  /// In ar, this message translates to:
  /// **'الإنترنت'**
  String get sectionInternet;

  /// No description provided for @sectionInternetDesc.
  ///
  /// In ar, this message translates to:
  /// **'باقات الموبايل والإنترنت المنزلي و5G'**
  String get sectionInternetDesc;

  /// No description provided for @sectionProcedures.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات والإجراءات'**
  String get sectionProcedures;

  /// No description provided for @sectionProceduresDesc.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات الفرع والحالات والتجوال'**
  String get sectionProceduresDesc;

  /// No description provided for @sectionCompany.
  ///
  /// In ar, this message translates to:
  /// **'عن الشركة'**
  String get sectionCompany;

  /// No description provided for @sectionCompanyDesc.
  ///
  /// In ar, this message translates to:
  /// **'نبذة، الشبكة، التطبيق والمنافسون'**
  String get sectionCompanyDesc;

  /// No description provided for @sectionPackagesHomeDesc.
  ///
  /// In ar, this message translates to:
  /// **'أنظمة الكارت والفاتورة والإضافات'**
  String get sectionPackagesHomeDesc;

  /// No description provided for @sectionNumbersHomeDesc.
  ///
  /// In ar, this message translates to:
  /// **'أرقام خدمة العملاء وكل الأكواد'**
  String get sectionNumbersHomeDesc;

  /// No description provided for @sectionWalletHomeDesc.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل والأكواد والحدود والرسوم'**
  String get sectionWalletHomeDesc;

  /// No description provided for @sectionGlossaryHomeDesc.
  ///
  /// In ar, this message translates to:
  /// **'المصطلحات والاختصارات'**
  String get sectionGlossaryHomeDesc;

  /// No description provided for @itemCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد بنود} =1{بند واحد} =2{بندان} few{{count} بنود} many{{count} بندًا} other{{count} بند}}'**
  String itemCount(int count);

  /// No description provided for @homeMustKnowTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرقام لازم تكون حافظها'**
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

  /// No description provided for @filterConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get filterConfirmed;

  /// No description provided for @filterUnconfirmed.
  ///
  /// In ar, this message translates to:
  /// **'غير مؤكد'**
  String get filterUnconfirmed;

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

  /// No description provided for @unconfirmedBannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذه المعلومة غير مؤكدة'**
  String get unconfirmedBannerTitle;

  /// No description provided for @unconfirmedBannerBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع النظام الداخلي أو مشرفك قبل إبلاغ العميل.'**
  String get unconfirmedBannerBody;

  /// No description provided for @unconfirmedGroupTitle.
  ///
  /// In ar, this message translates to:
  /// **'بنود غير مؤكدة'**
  String get unconfirmedGroupTitle;

  /// No description provided for @answerCardTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة السريعة'**
  String get answerCardTitle;

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

  /// No description provided for @callPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'الاتصال المباشر غير متاح بعد — الرقم منسوخ؟ استخدم زر النسخ.'**
  String get callPlaceholder;

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

  /// No description provided for @trainingReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'راجع البنود غير المؤكدة'**
  String get trainingReviewTitle;

  /// No description provided for @trainingReviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد بنود تحتاج مراجعة} =1{بند واحد يحتاج مراجعة داخلية} =2{بندان يحتاجان مراجعة داخلية} few{{count} بنود تحتاج مراجعة داخلية} many{{count} بندًا يحتاج مراجعة داخلية} other{{count} بند يحتاج مراجعة داخلية}}'**
  String trainingReviewSubtitle(int count);

  /// No description provided for @reviewScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'البنود غير المؤكدة'**
  String get reviewScreenTitle;

  /// No description provided for @reviewScreenSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كل البنود غير المؤكدة أو المتعارضة من كل الأقسام.'**
  String get reviewScreenSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب لغة الجهاز'**
  String get languageSystem;

  /// No description provided for @homeQuickAccess.
  ///
  /// In ar, this message translates to:
  /// **'وصول سريع'**
  String get homeQuickAccess;

  /// No description provided for @homeRecentTitle.
  ///
  /// In ar, this message translates to:
  /// **'فتحتها مؤخرًا'**
  String get homeRecentTitle;

  /// No description provided for @homeGreetingNight.
  ///
  /// In ar, this message translates to:
  /// **'مساء النور'**
  String get homeGreetingNight;

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

  /// No description provided for @searchSuggestionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'جرّب البحث عن'**
  String get searchSuggestionsTitle;

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

  /// No description provided for @packageCurrencyNote.
  ///
  /// In ar, this message translates to:
  /// **'بالجنيه المصري'**
  String get packageCurrencyNote;

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

  /// No description provided for @detailStatusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة المعلومة'**
  String get detailStatusTitle;

  /// No description provided for @settingsAppearanceHint.
  ///
  /// In ar, this message translates to:
  /// **'يُحفظ اختيارك تلقائيًا'**
  String get settingsAppearanceHint;
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
