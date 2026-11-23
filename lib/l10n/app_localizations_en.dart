// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navBrowse => 'Browse';

  @override
  String get navSearch => 'Search';

  @override
  String get navTraining => 'Training';

  @override
  String get navMe => 'Me';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get homeSearchHint => 'Search packages, codes, numbers…';

  @override
  String get homeHeroSubtitle =>
      'Everything you need at the counter, in one place';

  @override
  String get homeSectionsSubtitle => 'Pick a section to explore';

  @override
  String get sectionPackagesDesc => 'Offers, prices and subscription codes';

  @override
  String get sectionServicesDesc => 'Mobile services and add-ons';

  @override
  String get sectionNumbersCodesDesc => 'USSD codes and service numbers';

  @override
  String get sectionWalletDesc => 'Mobile wallet and transfers';

  @override
  String get sectionGlossaryDesc => 'System and branch terminology';

  @override
  String get browseSubtitle => 'All encyclopedias in one place';

  @override
  String get searchExampleTitle => 'Illustrative example — fake data';

  @override
  String get searchExampleItem => 'Sample package';

  @override
  String get searchExampleSource => 'Public website (sample)';

  @override
  String get homeSectionsTitle => 'Encyclopedias';

  @override
  String get sectionPackages => 'Packages';

  @override
  String get sectionServices => 'Services';

  @override
  String get sectionNumbersCodes => 'Numbers & Codes';

  @override
  String get sectionWallet => 'Wallet';

  @override
  String get sectionGlossary => 'Glossary';

  @override
  String get browseTitle => 'Browse encyclopedias';

  @override
  String get contentComingSoon => 'Content coming soon';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchFieldHint => 'Type a word, code or number';

  @override
  String get searchClear => 'Clear search';

  @override
  String get searchPlaceholderBody =>
      'Search is being built — it will work offline and understand colloquial Arabic.';

  @override
  String get trainingTitle => 'Training';

  @override
  String get trainingPlaceholderBody =>
      'Learning paths and daily review — coming soon.';

  @override
  String get meTitle => 'Me';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get aboutTitle => 'About';

  @override
  String get editorModeTitle => 'Editor mode (owner sign-in)';

  @override
  String get editorModeSubtitle => 'Coming soon';

  @override
  String get disclaimerShort =>
      'Independent, unofficial app — always check official sources.';

  @override
  String get disclaimerFull =>
      'An independent, unofficial app. Not affiliated with or endorsed by any telecom operator. Information is for guidance only; always refer to the approved official sources.';

  @override
  String get copyAction => 'Copy';

  @override
  String copyValueSemantics(String value) {
    return 'Copy $value';
  }

  @override
  String get copiedMessage => 'Copied';

  @override
  String get callAction => 'Call';

  @override
  String get symbolStar => 'star';

  @override
  String get symbolHash => 'hash';

  @override
  String get symbolPlus => 'plus';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusNeedsReview => 'Needs review';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusUnverified => 'No approved source';

  @override
  String get statusConflict => 'Conflict';

  @override
  String get statusPrivate => 'Private';

  @override
  String lastVerified(String relative) {
    return 'Last verified: $relative';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String verifiedOn(String date) {
    return 'Verified on $date';
  }

  @override
  String get sourceOfficialInternal => 'Official internal document';

  @override
  String get sourceOfficialPublic => 'Official public source';

  @override
  String get sourceTraining => 'Approved training material';

  @override
  String get sourceSupervisor => 'Supervisor-confirmed (documented)';

  @override
  String get sourceExternal => 'General reference';

  @override
  String get sourceOwnerNote => 'Owner\'s note';

  @override
  String sourceSemantics(String name, String type) {
    return 'Source: $name, $type';
  }

  @override
  String get conflictTitle => 'Two sources disagree about this information';

  @override
  String get conflictGuidance =>
      'Don\'t give the customer a final value — check the official source or a supervisor.';

  @override
  String get conflictAction => 'Review sources';

  @override
  String get privateBadge => 'Private note — owner only';

  @override
  String get currencyEgp => 'EGP';

  @override
  String get taxInclusiveRecharge => 'Incl. recharge tax';

  @override
  String get taxExclusiveVat => 'Excl. VAT';

  @override
  String get taxUnknown => 'Tax basis not stated';

  @override
  String priceValidRange(String from, String until) {
    return 'Valid from $from to $until';
  }

  @override
  String priceValidFrom(String from) {
    return 'Valid from $from';
  }

  @override
  String get priceNoEndDate => 'No announced end date';

  @override
  String priceEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ends in $count days',
      one: 'Ends tomorrow',
      zero: 'Ends today',
    );
    return '$_temp0';
  }

  @override
  String priceStartsOn(String date) {
    return 'Starts on $date — not the current price';
  }

  @override
  String priceExpiredNote(String date) {
    return 'Ended on $date — do not quote as current';
  }

  @override
  String get sectionInternet => 'Internet';

  @override
  String get sectionInternetDesc => 'Mobile data, home internet and 5G';

  @override
  String get sectionProcedures => 'Services & procedures';

  @override
  String get sectionProceduresDesc => 'Branch procedures, cases and roaming';

  @override
  String get sectionCompany => 'About the company';

  @override
  String get sectionCompanyDesc => 'Profile, network, app and competitors';

  @override
  String get sectionPackagesHomeDesc => 'Prepaid, postpaid and add-ons';

  @override
  String get sectionNumbersHomeDesc => 'Hotlines and every USSD code';

  @override
  String get sectionWalletHomeDesc => 'Registration, codes, limits and fees';

  @override
  String get sectionGlossaryHomeDesc => 'Terms and abbreviations';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get homeMustKnowTitle => 'Numbers to know by heart';

  @override
  String contentAsOf(String date) {
    return 'Content last updated: $date';
  }

  @override
  String get contentEmptySection => 'No content in this section yet';

  @override
  String get contentEmptySectionBody =>
      'Content will appear here once it is added.';

  @override
  String get filterAll => 'All';

  @override
  String get filterConfirmed => 'Confirmed';

  @override
  String get filterUnconfirmed => 'Unconfirmed';

  @override
  String get statusConfirmedGuide => 'Confirmed per guide';

  @override
  String get statusUnconfirmedReview => 'Unconfirmed — check internally';

  @override
  String get unconfirmedBannerTitle => 'This information is unconfirmed';

  @override
  String get unconfirmedBannerBody =>
      'Check the internal system or your supervisor before telling the customer.';

  @override
  String get unconfirmedGroupTitle => 'Unconfirmed items';

  @override
  String get answerCardTitle => 'Quick answer';

  @override
  String get detailFactsTitle => 'All details';

  @override
  String get detailStepsTitle => 'Steps';

  @override
  String get detailSourcesTitle => 'Sources';

  @override
  String get detailRelatedTitle => 'Related items';

  @override
  String detailPdfPages(String pages) {
    return 'Guide page $pages';
  }

  @override
  String get detailNotFound => 'Item not found';

  @override
  String get detailNotFoundBody => 'It may have been removed or renamed.';

  @override
  String get callPlaceholder =>
      'Direct calling isn\'t available yet — use the copy button.';

  @override
  String get searchIdleBody =>
      'Search all content in colloquial Arabic, by code or by number — offline.';

  @override
  String get searchEmptyTitle => 'No results';

  @override
  String get searchEmptyBody =>
      'Try another word, or type the code or number directly.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get trainingReviewTitle => 'Review unconfirmed items';

  @override
  String trainingReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items need internal review',
      one: '1 item needs internal review',
      zero: 'Nothing to review',
    );
    return '$_temp0';
  }

  @override
  String get reviewScreenTitle => 'Unconfirmed items';

  @override
  String get reviewScreenSubtitle =>
      'Every unconfirmed or conflicting item across sections.';
}
