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
  String get navPackages => 'Packages';

  @override
  String get navCodes => 'Codes & numbers';

  @override
  String get navMore => 'More';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get homeSearchHint => 'Search packages, codes, numbers…';

  @override
  String get homeSectionsTitle => 'Sections';

  @override
  String get sectionPackages => 'Packages';

  @override
  String get sectionNumbersCodes => 'Codes & numbers';

  @override
  String get sectionWallet => 'Wallet';

  @override
  String get sectionGlossary => 'Glossary';

  @override
  String get searchFieldHint => 'Type a word, code or number';

  @override
  String get searchClear => 'Clear search';

  @override
  String get trainingTitle => 'Training';

  @override
  String get favoritesTitle => 'Favourites';

  @override
  String get favoritesEmpty => 'Tap the heart on any item to keep it here.';

  @override
  String get showAll => 'Show all';

  @override
  String showAllCount(int count) {
    return 'Show all ($count)';
  }

  @override
  String get segmentMobile => 'Mobile';

  @override
  String get segmentMobileInternet => 'Mobile data';

  @override
  String get segmentHome => 'Home';

  @override
  String get sortTitle => 'Order';

  @override
  String get sortPriceUp => 'Cheapest first';

  @override
  String get sortPriceDown => 'Priciest first';

  @override
  String get sortQuota => 'Most data';

  @override
  String get toolCompareShort => 'Compare';

  @override
  String get toolRecommendShort => 'Suggest';

  @override
  String get toolCalculatorShort => 'Calculate';

  @override
  String get packagesInfoTitle => 'Rules and information';

  @override
  String get hotlinesTitle => 'Customer service';

  @override
  String get codesNotesTitle => 'Notes and services';

  @override
  String get moreToolsTitle => 'My tools';

  @override
  String get moreNotes => 'My notes';

  @override
  String get moreEditor => 'Edit content';

  @override
  String get moreWhatsNew => 'What changed';

  @override
  String get moreSettingsTitle => 'Appearance and language';

  @override
  String get editedByYou => 'Edited by you';

  @override
  String editedByYouOn(String date) {
    return 'Edited by you · $date';
  }

  @override
  String get statusPerGuide => 'From the guide';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String quotaGb(String n) {
    return '$n GB';
  }

  @override
  String quotaMix(String n) {
    return '$n mix';
  }

  @override
  String quotaMinutes(String n) {
    return '$n min';
  }

  @override
  String get currencyShort => 'EGP';

  @override
  String get packageNoPriceShort => 'No price';

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
  String copyValueSemantics(String value) {
    return 'Copy $value';
  }

  @override
  String get copiedMessage => 'Copied';

  @override
  String callValueSemantics(String value) {
    return 'Call $value';
  }

  @override
  String get symbolStar => 'star';

  @override
  String get symbolHash => 'hash';

  @override
  String get symbolPlus => 'plus';

  @override
  String get currencyEgp => 'EGP';

  @override
  String get sectionInternet => 'Internet';

  @override
  String get sectionProcedures => 'Branch procedures';

  @override
  String get sectionCompany => 'About the company';

  @override
  String get homeMustKnowTitle => 'Most used';

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
  String get statusConfirmedGuide => 'Confirmed per guide';

  @override
  String get statusConfirmedOfficial => 'Confirmed on official site';

  @override
  String get statusUnconfirmedReview => 'Unconfirmed — check internally';

  @override
  String get unconfirmedBannerBody =>
      'Check the internal system or your supervisor before telling the customer.';

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
  String get languageSystem => 'Device language';

  @override
  String get homeRecentTitle => 'Last opened';

  @override
  String get searchRecentTitle => 'Recent searches';

  @override
  String get searchRecentClear => 'Clear history';

  @override
  String get packagePriceLabel => 'Price';

  @override
  String get packageCodeTitle => 'Subscription code';

  @override
  String get packageDetailsTitle => 'Details';

  @override
  String get packageNotesTitle => 'Conditions & notes';

  @override
  String get packageNoPrice => 'Price not stated in the guide';

  @override
  String get packageConflictPrice => 'Conflicting price — check both values';

  @override
  String sectionJumpTo(String name) {
    return 'Jump to $name';
  }

  @override
  String get detailOverviewTitle => 'Overview';

  @override
  String get toolsNotStated => 'Not stated';

  @override
  String get toolsCancel => 'Cancel';

  @override
  String get toolsSave => 'Save';

  @override
  String get toolsDelete => 'Delete';

  @override
  String get toolsUndo => 'Undo';

  @override
  String get toolsPickPackage => 'Choose a package';

  @override
  String get toolsSearchPackage => 'Search packages';

  @override
  String get toolsNoMatches => 'No matches';

  @override
  String get toolsItemRemoved => 'This item was removed from the content';

  @override
  String toolsEditedOn(String date) {
    return 'Edited by you – $date';
  }

  @override
  String get toolsInvalidNumber => 'Enter a valid number';

  @override
  String get toolsDial => 'Dial';

  @override
  String get toolsDialFillTitle => 'Fill in before dialing';

  @override
  String get toolsDialFillHint =>
      'Nothing you type is kept. The code opens in the dialer and you press call.';

  @override
  String get toolsDialOpen => 'Open the dialer';

  @override
  String get toolsDialDigitsOnly => 'Digits only';

  @override
  String get toolsDialChoose => 'Choose what to dial';

  @override
  String toolsDialFailed(String value) {
    return 'The dialer did not open, so we copied $value';
  }

  @override
  String get toolsDialFailedTemplate =>
      'The dialer did not open, so we copied the code without what you typed';

  @override
  String get toolsDialNothing =>
      'There is nothing to dial, so we copied the text';

  @override
  String get toolsFavorite => 'Favorite';

  @override
  String get toolsFavoriteAdd => 'Add to favorites';

  @override
  String get toolsFavoriteRemove => 'Remove from favorites';

  @override
  String get toolsFavoritesTitle => 'Favorites';

  @override
  String get toolsFavoritesEmpty => 'No favorites yet';

  @override
  String get toolsFavoritesEmptyBody =>
      'Tap the heart on any item to keep it here.';

  @override
  String get toolsFavoritesHint => 'Drag to reorder';

  @override
  String toolsReorder(String name) {
    return 'Reorder $name';
  }

  @override
  String get toolsCompareAction => 'Compare';

  @override
  String get toolsNoteAction => 'Note';

  @override
  String toolsNoteCount(int count) {
    return 'Notes ($count)';
  }

  @override
  String get toolsEditAction => 'Edit';

  @override
  String get toolsCompareTitle => 'Compare packages';

  @override
  String get toolsCompareHint => 'Choose 2 to 4 packages';

  @override
  String get toolsCompareAdd => 'Add a package';

  @override
  String toolsCompareRemove(String name) {
    return 'Remove $name';
  }

  @override
  String get toolsComparePeriods =>
      'Validity differs or is not stated, so the lowest price and largest quota are not marked.';

  @override
  String get toolsRowPackage => 'Package';

  @override
  String get toolsRowPrice => 'Price';

  @override
  String get toolsRowTotal => 'Including tax';

  @override
  String get toolsRowQuota => 'Quota';

  @override
  String get toolsRowGb => 'Internet (GB)';

  @override
  String get toolsRowMinutes => 'Minutes';

  @override
  String get toolsRowMix => 'Mixes';

  @override
  String get toolsRowValidity => 'Validity';

  @override
  String get toolsRowCode => 'Code';

  @override
  String get toolsRowAfter => 'After the bundle';

  @override
  String get toolsRowStatus => 'Status';

  @override
  String get toolsBestLowest => 'Lowest';

  @override
  String get toolsBestHighest => 'Highest';

  @override
  String get toolsBestLongest => 'Longest';

  @override
  String get toolsStatusConfirmed => 'Confirmed';

  @override
  String get toolsStatusUnconfirmed => 'Not confirmed';

  @override
  String get toolsStatusConflict => 'Conflicting';

  @override
  String get toolsRecommendTitle => 'Recommend a package';

  @override
  String get toolsRecommendSubtitle =>
      'Pick what the customer needs and leave the rest empty';

  @override
  String get toolsRecommendBudget =>
      'What will the customer pay? (EGP incl. tax)';

  @override
  String get toolsRecommendGb => 'Internet (GB)';

  @override
  String get toolsRecommendMinutes => 'Minutes';

  @override
  String get toolsUseMobile => 'Mobile';

  @override
  String get toolsUseHome => 'Home';

  @override
  String get toolsRecommendStart =>
      'Pick a budget, GB, minutes or a duration; results show at once';

  @override
  String get toolsRecommendFits => 'Covers every need';

  @override
  String get toolsRecommendNone =>
      'No package in the content covers everything with stated numbers.';

  @override
  String get toolsRecommendMaybe => 'May fit, something is not stated';

  @override
  String get toolsRecommendClosest => 'Closest, but not complete';

  @override
  String toolsBudgetMet(String value) {
    return 'Costs $value EGP, within budget';
  }

  @override
  String toolsBudgetMissed(String value) {
    return 'Costs $value EGP, over budget';
  }

  @override
  String toolsBudgetUnknown(String value) {
    return '$value EGP; the cost including tax is not stated';
  }

  @override
  String get toolsBudgetNotStated => 'Price not stated';

  @override
  String toolsGbMet(String value) {
    return '$value, enough';
  }

  @override
  String toolsGbMissed(String value) {
    return '$value, less than needed';
  }

  @override
  String toolsGbMix(String value) {
    return '$value mixes; GB not stated';
  }

  @override
  String get toolsGbNotStated => 'GB not stated';

  @override
  String toolsMinutesMet(String value) {
    return '$value minutes, enough';
  }

  @override
  String toolsMinutesMissed(String value) {
    return '$value minutes, less than needed';
  }

  @override
  String toolsMinutesMix(String value) {
    return '$value mixes; minutes not stated';
  }

  @override
  String get toolsMinutesNotStated => 'Minutes not stated';

  @override
  String toolsMixNote(String text) {
    return 'What the content says about usage: $text';
  }

  @override
  String get toolsCalcTitle => 'Recharge calculator';

  @override
  String get toolsCalcModeCard => 'I have a card';

  @override
  String get toolsCalcModePrice => 'I have a price';

  @override
  String get toolsCalcCardLabel => 'Card value (EGP)';

  @override
  String get toolsCalcPriceLabel => 'Package price before tax (EGP)';

  @override
  String get toolsCalcBalanceResult => 'Balance received';

  @override
  String get toolsCalcCardResult => 'Card needed';

  @override
  String toolsCalcEgp(String value) {
    return '$value EGP';
  }

  @override
  String toolsCalcTaxPart(String value) {
    return '$value EGP goes to tax and fees';
  }

  @override
  String toolsCalcStated(String value) {
    return 'Stated in the content including tax: $value';
  }

  @override
  String get toolsCalcComputed =>
      'Computed from the ratio below, not a published price.';

  @override
  String get toolsCalcSource => 'Where the ratio comes from';

  @override
  String toolsCalcRatio(String card, String balance) {
    return 'Every $card EGP card = $balance EGP balance';
  }

  @override
  String get toolsCalcUnavailable => 'Calculator not available';

  @override
  String get toolsCalcUnavailableBody =>
      'The item with the recharge ratio is missing or unclear, and no number is assumed instead.';

  @override
  String get toolsWhatsNewTitle => 'What changed';

  @override
  String get toolsWhatsNewEmpty => 'No recorded changes';

  @override
  String get toolsWhatsNewEmptyBody =>
      'When the content is updated, price and code changes appear here.';

  @override
  String toolsWhatsNewOn(String date) {
    return 'Update $date';
  }

  @override
  String toolsWhatsNewRemoved(int count) {
    return '$count items removed';
  }

  @override
  String toolsWhatsNewAdded(int count) {
    return '$count new items';
  }

  @override
  String toolsWhatsNewMore(int count) {
    return 'and $count more';
  }

  @override
  String get toolsWhatsNewBanner => 'Content updated. See what changed';

  @override
  String get toolsWas => 'Was';

  @override
  String get toolsNow => 'Now';

  @override
  String get editorMyEdits => 'My edits';

  @override
  String get editorLocalOnly =>
      'Edits live only on this phone and nobody else sees them. Uninstalling removes them, so export what matters.';

  @override
  String get editorEmpty => 'No edits';

  @override
  String get editorEmptyBody =>
      'Edit any item from its page, or add a new one.';

  @override
  String get editorAdd => 'Add item';

  @override
  String get editorExport => 'Export';

  @override
  String get editorImport => 'Import';

  @override
  String get editorStateAdded => 'Added by you';

  @override
  String get editorStateHidden => 'Hidden';

  @override
  String get editorStateNewer => 'The app has a newer version of this item';

  @override
  String get editorStateRemoved =>
      'The original was removed from the content. Your edit is kept but not shown.';

  @override
  String get editorKeepMine => 'Keep mine';

  @override
  String get editorUseNew => 'Use the new one';

  @override
  String get editorRestore => 'Restore original';

  @override
  String get editorDeleteAdded => 'Delete item';

  @override
  String editorRestoreAsk(String name) {
    return 'Restore “$name” to the original?';
  }

  @override
  String editorDeleteAsk(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get editorRestoreBody => 'Your edit will be removed from this phone.';

  @override
  String get editorEditTitle => 'Edit item';

  @override
  String get editorNewTitle => 'New item';

  @override
  String get editorFieldTitle => 'Title';

  @override
  String get editorFieldSummary => 'Summary';

  @override
  String get editorFieldCategory => 'Group';

  @override
  String get editorFieldSection => 'Section';

  @override
  String get editorFieldType => 'Type';

  @override
  String get editorFieldFacts => 'Facts';

  @override
  String get editorFactLabel => 'Label';

  @override
  String get editorFactValue => 'Value';

  @override
  String get editorFactUnit => 'Unit';

  @override
  String get editorFactKind => 'Kind';

  @override
  String get editorAddFact => 'Add fact';

  @override
  String editorRemoveFact(int n) {
    return 'Remove fact $n';
  }

  @override
  String get editorFieldCodes => 'Codes, one per line';

  @override
  String get editorFieldPhones => 'Phones, one per line';

  @override
  String get editorFieldStatusNote => 'Status note';

  @override
  String get editorHide => 'Hide item';

  @override
  String get editorHideHint =>
      'It disappears from lists and search until you restore it from My edits.';

  @override
  String get editorTitleRequired => 'Enter a title';

  @override
  String get editorFactRequired => 'Enter label and value, or remove the fact';

  @override
  String get editorNotConfirmed =>
      'After saving it shows “Edited by you” and is not labelled confirmed until you restore the original.';

  @override
  String get editorLeaveAsk => 'Leave without saving?';

  @override
  String get editorLeave => 'Leave';

  @override
  String get editorStay => 'Keep editing';

  @override
  String get editorSaved => 'Edit saved on this phone';

  @override
  String get editorNothingChanged => 'Nothing changed';

  @override
  String get editorExportNoNotes => 'Private notes are not exported.';

  @override
  String get editorShare => 'Share';

  @override
  String get editorCopy => 'Copy text';

  @override
  String get editorShareFailed =>
      'Sharing is not available, so we copied the text';

  @override
  String get editorCopied => 'Text copied';

  @override
  String get editorImportHint => 'Paste the exported text here';

  @override
  String get editorPaste => 'Paste';

  @override
  String get editorImportCheck => 'Check';

  @override
  String get editorImportInvalid =>
      'This is not a valid export of the app. Nothing was changed.';

  @override
  String editorImportDiff(int added, int replaced, int same) {
    return '$added new, $replaced replaced, $same unchanged';
  }

  @override
  String get editorImportKeeps => 'Your other edits stay as they are.';

  @override
  String editorImportMissing(int count) {
    return '$count are for items not in the current content';
  }

  @override
  String get editorImportApply => 'Apply';

  @override
  String get editorImportDone => 'Import done';

  @override
  String get editorImportNothing => 'Nothing differs from what you have';

  @override
  String get editorKindPrice => 'Price';

  @override
  String get editorKindCode => 'Code';

  @override
  String get editorKindPhone => 'Phone';

  @override
  String get editorKindQuantity => 'Quantity';

  @override
  String get editorKindDuration => 'Duration';

  @override
  String get editorKindPercent => 'Percent';

  @override
  String get editorKindDate => 'Date';

  @override
  String get editorKindText => 'Text';

  @override
  String get editorTypePackage => 'Package';

  @override
  String get editorTypeCode => 'Code';

  @override
  String get editorTypeContact => 'Contact';

  @override
  String get editorTypeService => 'Service';

  @override
  String get editorTypeProcedure => 'Procedure';

  @override
  String get editorTypeFee => 'Fee';

  @override
  String get editorTypeRule => 'Rule';

  @override
  String get editorTypeArticle => 'Article';

  @override
  String get editorTypeGlossary => 'Term';

  @override
  String get editorTypeFaq => 'FAQ';

  @override
  String get notesTitle => 'My notes';

  @override
  String get notesWarning => 'Do not write customer names, numbers or data.';

  @override
  String get notesLocal => 'Only on this phone, never exported.';

  @override
  String get notesSearch => 'Search your notes';

  @override
  String get notesEmpty => 'No notes';

  @override
  String get notesEmptyBody =>
      'Write something to remember, on its own or on an item.';

  @override
  String get notesAdd => 'New note';

  @override
  String get notesEdit => 'Edit note';

  @override
  String get notesHint => 'Write the note';

  @override
  String get notesDeleted => 'Note deleted';

  @override
  String notesForItem(String name) {
    return 'On: $name';
  }

  @override
  String get notesDeleteOne => 'Delete note';

  @override
  String get trainingIntro => 'Questions come only from confirmed content';

  @override
  String get trainingDaily => 'Question of the day';

  @override
  String get trainingDailyDone => 'Answered today';

  @override
  String get trainingCards => 'Cards';

  @override
  String trainingCardsDue(int due, int fresh) {
    return '$due due today, $fresh new';
  }

  @override
  String get trainingQuiz => 'Quiz';

  @override
  String trainingQuizCount(int count) {
    return '$count questions with choices';
  }

  @override
  String get trainingScenarios => 'Branch cases';

  @override
  String trainingScenariosCount(int count) {
    return '$count cases';
  }

  @override
  String get trainingLevel => 'Your progress';

  @override
  String get trainingMastered => 'Mastered';

  @override
  String get trainingLearning => 'Learning';

  @override
  String get trainingNew => 'New';

  @override
  String get trainingWeakest => 'Needs review';

  @override
  String trainingWeakRow(int wrong, int seen) {
    return '$wrong wrong of $seen';
  }

  @override
  String get trainingNothing => 'No questions now';

  @override
  String get trainingNothingBody =>
      'Not enough confirmed content to make questions.';

  @override
  String get trainingShowAnswer => 'Show answer';

  @override
  String get trainingKnew => 'I knew it';

  @override
  String get trainingDidNot => 'I did not';

  @override
  String get trainingNext => 'Next';

  @override
  String get trainingFinish => 'Finish';

  @override
  String get trainingCorrect => 'Correct';

  @override
  String get trainingWrong => 'Wrong';

  @override
  String get trainingOpenItem => 'Open item';

  @override
  String trainingQuizResult(int right, int total) {
    return '$right correct of $total';
  }

  @override
  String get trainingReviewWrong => 'Review these';

  @override
  String trainingStep(int index, int total) {
    return '$index of $total';
  }

  @override
  String get trainingDone => 'Done for today';

  @override
  String get trainingDoneBody => 'Answered cards come back when due.';

  @override
  String get trainingReset => 'Reset training';

  @override
  String get trainingResetAsk => 'Erase your training progress?';

  @override
  String trainingAskFact(String title, String label) {
    return '“$title”: $label?';
  }

  @override
  String trainingAskCode(String title) {
    return 'What is the code for “$title”?';
  }

  @override
  String trainingAskPhone(String title) {
    return 'What is the number of “$title”?';
  }

  @override
  String trainingAskTerm(String title) {
    return 'What does “$title” mean?';
  }

  @override
  String trainingAskDocuments(String title) {
    return 'Which documents does “$title” need?';
  }

  @override
  String trainingAskFirstStep(String title) {
    return 'What is the first step in “$title”?';
  }

  @override
  String trainingAskScenario(String title) {
    return '$title. What do you do?';
  }

  @override
  String get searchQuickTitle => 'Quick search';

  @override
  String get searchAllSections => 'Search all sections';

  @override
  String get detailStepsReset => 'Start over';

  @override
  String get toolsShareSummary => 'Share';

  @override
  String get toolsSummaryCopied =>
      'Sharing is not available; the summary was copied';

  @override
  String get customerView => 'Show to customer';

  @override
  String get customerViewOff => 'Leave customer view';

  @override
  String get moreContentTitle => 'Knowledge base';

  @override
  String get moreStatItems => 'All items';

  @override
  String get moreStatOfficial => 'Official site';

  @override
  String get moreClearHistory => 'Clear search and reading history';

  @override
  String get moreHistoryCleared => 'History cleared';

  @override
  String get editorFieldBody => 'Explanation';

  @override
  String get editorFieldSteps => 'Steps, one per line';

  @override
  String detailStepsProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get badgeNew => 'New';

  @override
  String get peekOpen => 'Open details';

  @override
  String get peekHint => 'Long-press any item for a quick look';

  @override
  String get navNewContent => 'New update';

  @override
  String get toolsCalcModePostpaid => 'Postpaid';

  @override
  String get toolsCalcPostpaidLabel => 'Monthly fee before tax (EGP)';

  @override
  String get toolsCalcPostpaidResult => 'Monthly total incl. taxes and fees';

  @override
  String toolsCalcPostpaidParts(String table, String vat, String fees) {
    return 'Table tax 8%: $table · VAT 14%: $vat · Fees: $fees';
  }

  @override
  String get toolsCalcPostpaidRule =>
      'Fee × 1.08 × 1.14 + 10 development + 1.34 stamp';

  @override
  String get toolsRecommendValidity => 'Duration';

  @override
  String get toolsValidityAny => 'Any';

  @override
  String get toolsValidityMonthly => 'Monthly';

  @override
  String get toolsValidityShort => 'Under a month';

  @override
  String get toolsRecommendBest => 'Top pick';

  @override
  String get toolsRecommendBestBudget => 'The most this budget buys';

  @override
  String get toolsRecommendBestCheapest => 'Cheapest that covers it';

  @override
  String get toolsRecommendReset => 'Clear';

  @override
  String get toolsRecommendOpen => 'Open package';

  @override
  String get toolsRecommendComputed => 'computed';

  @override
  String get toolsRecommendPays => 'Customer pays';

  @override
  String toolsRecommendDeducted(String value) {
    return '$value EGP taken from balance';
  }

  @override
  String toolsBudgetComputed(String value) {
    return 'Recharge $value EGP (computed from the deducted price), within budget';
  }

  @override
  String toolsMinutesEandOnly(String value) {
    return '$value units: enough if calls are to e&';
  }

  @override
  String toolsMinutesAnyNetwork(String value) {
    return '$value units: enough even to other networks';
  }

  @override
  String toolsMinutesUnitsShort(String value) {
    return '$value units: less than needed';
  }

  @override
  String toolsValidityMet(String value) {
    return '$value days, suits';
  }

  @override
  String toolsValidityMissed(String value) {
    return '$value days, does not suit';
  }

  @override
  String get toolsValidityNotStated => 'Duration not stated';

  @override
  String get toolsRecommendPrice => 'Stated price';

  @override
  String get toolsRecommendBeforeTax => 'before tax';

  @override
  String get packageIncludesTitle => 'What\'s included';

  @override
  String get badgeOfficial => 'Official';

  @override
  String get filterFamiliesAll => 'All kinds';

  @override
  String get filterFamilyTitle => 'Choose a kind of package';

  @override
  String get jumpTitle => 'Go to a group';

  @override
  String get jumpPill => 'Groups';

  @override
  String get searchScopeTitle => 'Search in';

  @override
  String get moreTrainingSub => 'Test yourself daily';

  @override
  String get moreRecommendSub => 'The right package';

  @override
  String get moreCompareSub => 'Two packages side by side';

  @override
  String get moreCalculatorSub => 'Card, balance and bill';

  @override
  String get moreFavoritesSub => 'What you saved';

  @override
  String get moreNotesSub => 'Your private notes';

  @override
  String get moreEditorSub => 'Edit and add items';

  @override
  String get moreWhatsNewSub => 'Latest content updates';

  @override
  String moreItemsCount(int count) {
    return '$count items';
  }

  @override
  String get toolsCalcIntro =>
      'Work out the card for a package, the balance a card gives, or a monthly bill with taxes and fees.';

  @override
  String get toolsFavoritesIntro =>
      'Items you come back to, in your order. Drag the handle to reorder.';

  @override
  String get toolsWhatsNewIntro =>
      'Every content update on this phone: what is new, changed prices, and what was removed.';

  @override
  String get toolsRecommendIntro =>
      'Enter the customer\'s needs: what they pay, how much internet and minutes, and for how long. Only confirmed prices are used.';

  @override
  String get heroSelected => 'chosen of 4';

  @override
  String get heroInFavorites => 'favourites';

  @override
  String get heroNotes => 'notes';

  @override
  String get heroEdits => 'edits';

  @override
  String get heroUpdates => 'updates';

  @override
  String get heroAdded => 'new items';

  @override
  String get heroPackages => 'packages';

  @override
  String get exportTitle => 'Share and export';

  @override
  String get exportPdf => 'Formatted PDF';

  @override
  String get exportPdfHint =>
      'A tidy page with the N-Core header, ready to send';

  @override
  String get exportText => 'Text message';

  @override
  String get exportTextHint => 'A customer summary for WhatsApp or SMS';

  @override
  String get exportCopy => 'Copy';

  @override
  String get exportCopyHint => 'Copy the summary and paste it anywhere';

  @override
  String get exportPreparing => 'Preparing the file…';

  @override
  String get exportFailed => 'Could not prepare the file, try again';

  @override
  String get exportCopied => 'Copied';

  @override
  String get exportUnavailable => 'Sharing is not available here';

  @override
  String get exportComparePdf => 'Export comparison as PDF';

  @override
  String get exportListPdf => 'Export the list as PDF';

  @override
  String get exportDetails => 'Details';

  @override
  String get exportSteps => 'Steps';

  @override
  String get exportCodes => 'Codes and numbers';

  @override
  String get exportBestMark => 'A shaded cell is the best in its row';

  @override
  String get exportTagline => 'Counter guide · e& Egypt';

  @override
  String get exportConfirmed => 'Confirmed';

  @override
  String get exportSource => 'Source';

  @override
  String get exportVerified => 'Last checked';

  @override
  String exportFooter(String name) {
    return 'Issued by $name · prices as last officially checked';
  }

  @override
  String exportPage(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String exportItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get valueTitle => 'Best value for money';

  @override
  String get valueForBudget => 'Best value for your money';

  @override
  String get valueForCalls => 'For calls';

  @override
  String get valueForInternet => 'For internet';

  @override
  String valuePerGb(String cost) {
    return '$cost per GB';
  }

  @override
  String valuePerMinute(String cost) {
    return '$cost per minute to any network';
  }

  @override
  String valuePerMix(String cost) {
    return '$cost per 100 mixes';
  }

  @override
  String valueLead(String percent) {
    return '$percent% cheaper per unit than the next';
  }

  @override
  String valueLeadLast(String percent) {
    return 'and $percent% cheaper than the dearest';
  }

  @override
  String get valueTie => 'They all cost the same per unit; choose by use';

  @override
  String get valueNotComparable =>
      'These packages share no single unit (GB or any-network minutes) to weigh them honestly';

  @override
  String get valueBasisGb => 'Weighed by the price of a GB';

  @override
  String get valueBasisMinute =>
      'Weighed by the price of a minute to any network';

  @override
  String get valueBasisMix => 'Weighed by the price of a mix (same plan)';

  @override
  String get valuePriceTotal => 'At what the customer pays, tax included';

  @override
  String get valuePriceBefore => 'At every package\'s price before tax';

  @override
  String get valueBadge => 'Best value';

  @override
  String get valueOpen => 'Open the package';

  @override
  String get contentUpdated => 'Prices updated from the official site';

  @override
  String toolsBudgetPostpaid(String value) {
    return 'Bill $value EGP with taxes and fees, within budget';
  }
}
