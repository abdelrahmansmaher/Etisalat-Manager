import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The encyclopedia sections shown on Home and Browse (placeholder list —
/// the real taxonomy will come from the content layer).
enum EncyclopediaSection {
  packages(Icons.sell_outlined),
  services(Icons.sim_card_outlined),
  numbersCodes(Icons.dialpad),
  wallet(Icons.account_balance_wallet_outlined),
  glossary(Icons.menu_book_outlined);

  const EncyclopediaSection(this.icon);

  final IconData icon;

  String title(AppLocalizations l10n) => switch (this) {
    packages => l10n.sectionPackages,
    services => l10n.sectionServices,
    numbersCodes => l10n.sectionNumbersCodes,
    wallet => l10n.sectionWallet,
    glossary => l10n.sectionGlossary,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    packages => l10n.sectionPackagesDesc,
    services => l10n.sectionServicesDesc,
    numbersCodes => l10n.sectionNumbersCodesDesc,
    wallet => l10n.sectionWalletDesc,
    glossary => l10n.sectionGlossaryDesc,
  };
}
