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
}
