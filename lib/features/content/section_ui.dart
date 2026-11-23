import 'package:flutter/material.dart';

import '../../core/content/content_models.dart';
import '../../core/widgets/trust/trust_models.dart';
import '../../l10n/app_localizations.dart';

/// Presentation metadata for each content section.
extension ContentSectionUi on ContentSection {
  IconData get icon => switch (this) {
    ContentSection.packages => Icons.sell_outlined,
    ContentSection.internet => Icons.wifi_rounded,
    ContentSection.procedures => Icons.assignment_outlined,
    ContentSection.numbers => Icons.dialpad,
    ContentSection.wallet => Icons.account_balance_wallet_outlined,
    ContentSection.glossary => Icons.menu_book_outlined,
    ContentSection.company => Icons.apartment_outlined,
  };

  String title(AppLocalizations l10n) => switch (this) {
    ContentSection.packages => l10n.sectionPackages,
    ContentSection.internet => l10n.sectionInternet,
    ContentSection.procedures => l10n.sectionProcedures,
    ContentSection.numbers => l10n.sectionNumbersCodes,
    ContentSection.wallet => l10n.sectionWallet,
    ContentSection.glossary => l10n.sectionGlossary,
    ContentSection.company => l10n.sectionCompany,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    ContentSection.packages => l10n.sectionPackagesHomeDesc,
    ContentSection.internet => l10n.sectionInternetDesc,
    ContentSection.procedures => l10n.sectionProceduresDesc,
    ContentSection.numbers => l10n.sectionNumbersHomeDesc,
    ContentSection.wallet => l10n.sectionWalletHomeDesc,
    ContentSection.glossary => l10n.sectionGlossaryHomeDesc,
    ContentSection.company => l10n.sectionCompanyDesc,
  };
}

extension ContentSourceTypeUi on ContentSourceType {
  SourceType get trustType => switch (this) {
    ContentSourceType.officialSite ||
    ContentSourceType.regulator => SourceType.officialPublic,
    _ => SourceType.external,
  };
}
