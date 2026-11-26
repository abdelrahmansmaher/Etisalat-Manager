import 'package:flutter/widgets.dart';

import 'app_colors.dart';
import 'app_icons.dart';

/// The colours icons wear. Each meaning has its own hue, so an icon reads
/// at a glance before its label: data is blue, calls teal, messages
/// orange, dates indigo, money gold, people pink, warnings coral...
///
/// Every hue is deep enough for a white glyph on it (3:1 or more) in both
/// themes. Green stays reserved for "confirmed" and gold for money.
enum Hue {
  navy(Color(0xFF1F3A8A), Color(0xFF3B5BC4)),
  blue(Color(0xFF1D5FD6), Color(0xFF3B78E8)),
  azure(Color(0xFF0A72A8), Color(0xFF1C86BD)),
  teal(Color(0xFF0B7C74), Color(0xFF14917F)),
  indigo(Color(0xFF4338CA), Color(0xFF5B52DE)),
  violet(Color(0xFF7C3AED), Color(0xFF8B5CF6)),
  pink(Color(0xFFC0266D), Color(0xFFD63D84)),
  coral(Color(0xFFC93B3B), Color(0xFFDA5252)),
  orange(Color(0xFFC2560C), Color(0xFFD9691C)),
  gold(Color(0xFF9A6A00), Color(0xFFB07D0A)),
  slate(Color(0xFF475569), Color(0xFF5E6B80));

  const Hue(this.light, this.dark);

  final Color light;
  final Color dark;

  Color of(AppColors c) => c.isDark ? dark : light;
}

abstract final class IconHues {
  /// The hue an icon wears by meaning; navy when it has none of its own.
  static Hue of(IconData icon) => _map[icon] ?? Hue.navy;

  static final Map<IconData, Hue> _map = {
    // Data and network.
    for (final i in const [
      AppIcons.sectionInternet,
      AppIcons.quotaData,
      AppIcons.catMegabytes,
      AppIcons.catDsl,
      AppIcons.catHomeWireless,
      AppIcons.cat5g,
      AppIcons.catDataLine,
      AppIcons.catInternetCodes,
      AppIcons.catNetwork,
      AppIcons.speed,
      AppIcons.quotaApps,
      AppIcons.catSuperConnect,
    ])
      i: Hue.blue,
    // Calls and lines.
    for (final i in const [
      AppIcons.call,
      AppIcons.catLandline,
      AppIcons.catHotline,
      AppIcons.catCallServices,
      AppIcons.catLost,
      AppIcons.catNewLine,
    ])
      i: Hue.teal,
    // Messages and talk.
    for (final i in const [
      AppIcons.quotaSms,
      AppIcons.catComplaints,
      AppIcons.catFaq,
      AppIcons.trainQuiz,
    ])
      i: Hue.orange,
    // Money: prices, fees, recharge, balance.
    for (final i in const [
      AppIcons.price,
      AppIcons.recharge,
      AppIcons.catBalanceCodes,
      AppIcons.catRecharge,
      AppIcons.catTariff,
      AppIcons.percent,
      AppIcons.catPriceHistory,
    ])
      i: Hue.gold,
    // Wallet.
    for (final i in const [
      AppIcons.sectionWallet,
      AppIcons.catWalletOpen,
      AppIcons.catWalletServices,
      AppIcons.catDailyCard,
    ])
      i: Hue.violet,
    // Time and dates.
    for (final i in const [
      AppIcons.validity,
      AppIcons.renewal,
      AppIcons.afterBundle,
      AppIcons.date,
      AppIcons.catHours,
      AppIcons.trainDaily,
      AppIcons.lastVerified,
      AppIcons.history,
    ])
      i: Hue.indigo,
    // Travel.
    for (final i in const [AppIcons.roaming, AppIcons.catRoaming]) i: Hue.azure,
    // People and offers.
    for (final i in const [
      AppIcons.quotaLines,
      AppIcons.catCustomers,
      AppIcons.catOffers,
      AppIcons.catLoyalty,
      AppIcons.catSpecialNumbers,
      AppIcons.catEntertainment,
      AppIcons.catCallerTune,
      AppIcons.toolFavoriteOff,
      AppIcons.toolFavorite,
    ])
      i: Hue.pink,
    // Stops, warnings, closing.
    for (final i in const [
      AppIcons.catCancelServices,
      AppIcons.catClose,
      AppIcons.catSuspend,
      AppIcons.conflict,
      AppIcons.expired,
      AppIcons.catCompetitors,
    ])
      i: Hue.coral,
    // Procedures, rules, documents.
    for (final i in const [
      AppIcons.sectionProcedures,
      AppIcons.catRules,
      AppIcons.catTerms,
      AppIcons.catRegulator,
      AppIcons.catSummary,
      AppIcons.catSources,
      AppIcons.document,
      AppIcons.review,
      AppIcons.catUpdateData,
      AppIcons.catIdentity,
      AppIcons.catOwnership,
      AppIcons.catPortability,
      AppIcons.catReplaceSim,
      AppIcons.catSystemChange,
      AppIcons.catRefund,
    ])
      i: Hue.indigo,
    // Codes and numbers.
    for (final i in const [
      AppIcons.sectionNumbers,
      AppIcons.code,
      AppIcons.catPrefixes,
      AppIcons.catEsim,
    ])
      i: Hue.azure,
    // Company, brand, branch.
    for (final i in const [
      AppIcons.sectionCompany,
      AppIcons.catBrand,
      AppIcons.catBranchCases,
      AppIcons.catBusiness,
      AppIcons.catApp,
      AppIcons.catDevices,
      AppIcons.catImported,
    ])
      i: Hue.violet,
    // Packages and add-ons.
    for (final i in const [
      AppIcons.sectionPackages,
      AppIcons.catPostpaid,
      AppIcons.catAddOns,
      AppIcons.catMixes,
      AppIcons.navPackages,
      AppIcons.layers,
    ])
      i: Hue.blue,
    // Security.
    for (final i in const [
      AppIcons.lock,
      AppIcons.catSecurity,
      AppIcons.privateNote,
    ])
      i: Hue.slate,
    // Learning and info.
    for (final i in const [
      AppIcons.training,
      AppIcons.sectionGlossary,
      AppIcons.trainCards,
      AppIcons.info,
      AppIcons.catAbout,
    ])
      i: Hue.indigo,
    // Mixes (calls, messages and data in one balance).
    AppIcons.quotaMixes: Hue.violet,
    AppIcons.quota: Hue.violet,
    // Tools.
    AppIcons.toolCompare: Hue.azure,
    AppIcons.toolRecommend: Hue.violet,
    AppIcons.toolCalculator: Hue.orange,
    AppIcons.toolEdits: Hue.slate,
    AppIcons.toolNotes: Hue.teal,
    AppIcons.toolWhatsNew: Hue.blue,
    AppIcons.share: Hue.azure,
    AppIcons.copy: Hue.slate,
    AppIcons.quickAnswer: Hue.orange,
    AppIcons.trainScenario: Hue.teal,
  };
}
