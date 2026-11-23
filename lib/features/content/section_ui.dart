import 'package:flutter/material.dart';

import '../../core/content/content_models.dart';
import '../../core/widgets/trust/trust_models.dart';
import '../../l10n/app_localizations.dart';

/// Presentation metadata for each content section.
extension ContentSectionUi on ContentSection {
  IconData get icon => switch (this) {
    ContentSection.packages => Icons.sell_rounded,
    ContentSection.internet => Icons.wifi_rounded,
    ContentSection.procedures => Icons.assignment_rounded,
    ContentSection.numbers => Icons.dialpad_rounded,
    ContentSection.wallet => Icons.account_balance_wallet_rounded,
    ContentSection.glossary => Icons.menu_book_rounded,
    ContentSection.company => Icons.apartment_rounded,
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

/// Per-section accent: icon colour (≥ 3:1 on [container]) and a soft
/// container tint. Emerald stays the brand; sections get calm sibling hues
/// so the grid reads at a glance (never red — red means conflict).
@immutable
class SectionTone {
  const SectionTone(this.foreground, this.container, this.glow);

  final Color foreground;
  final Color container;

  /// Second gradient stop for icon tiles / card washes.
  final Color glow;

  static SectionTone of(ContentSection s, Brightness b) {
    final dark = b == Brightness.dark;
    return switch (s) {
      ContentSection.packages =>
        dark
            ? const SectionTone(
                Color(0xFF5EE3B0),
                Color(0xFF0F3A2D),
                Color(0xFF14503D),
              )
            : const SectionTone(
                Color(0xFF047857),
                Color(0xFFDDF4EA),
                Color(0xFFC4EBD9),
              ),
      ContentSection.internet =>
        dark
            ? const SectionTone(
                Color(0xFF67D8F0),
                Color(0xFF0C3340),
                Color(0xFF114456),
              )
            : const SectionTone(
                Color(0xFF0E7490),
                Color(0xFFDDF3F8),
                Color(0xFFC3E8F1),
              ),
      ContentSection.procedures =>
        dark
            ? const SectionTone(
                Color(0xFFA9B6FC),
                Color(0xFF1E2550),
                Color(0xFF283166),
              )
            : const SectionTone(
                Color(0xFF4338CA),
                Color(0xFFE6E8FD),
                Color(0xFFD3D7FB),
              ),
      ContentSection.numbers =>
        dark
            ? const SectionTone(
                Color(0xFFF2C978),
                Color(0xFF2E2511),
                Color(0xFF3E3216),
              )
            : const SectionTone(
                Color(0xFF9A6200),
                Color(0xFFFBF1DC),
                Color(0xFFF6E3BA),
              ),
      ContentSection.wallet =>
        dark
            ? const SectionTone(
                Color(0xFF7CC4FB),
                Color(0xFF0D2C47),
                Color(0xFF133A5C),
              )
            : const SectionTone(
                Color(0xFF0369A1),
                Color(0xFFDDEFFB),
                Color(0xFFC5E3F7),
              ),
      ContentSection.glossary =>
        dark
            ? const SectionTone(
                Color(0xFFC9D3DF),
                Color(0xFF222B36),
                Color(0xFF2C3744),
              )
            : const SectionTone(
                Color(0xFF475569),
                Color(0xFFE9EDF2),
                Color(0xFFD9E0E8),
              ),
      ContentSection.company =>
        dark
            ? const SectionTone(
                Color(0xFF5FE0CF),
                Color(0xFF0D3531),
                Color(0xFF124843),
              )
            : const SectionTone(
                Color(0xFF0F766E),
                Color(0xFFDBF3F0),
                Color(0xFFC1EAE5),
              ),
    };
  }
}

extension ContentSectionTone on ContentSection {
  SectionTone tone(BuildContext context) =>
      SectionTone.of(this, Theme.of(context).brightness);
}

extension ContentSourceTypeUi on ContentSourceType {
  SourceType get trustType => switch (this) {
    ContentSourceType.officialSite ||
    ContentSourceType.regulator => SourceType.officialPublic,
    _ => SourceType.external,
  };
}
