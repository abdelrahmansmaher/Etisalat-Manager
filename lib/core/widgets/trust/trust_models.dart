import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/trust_colors.dart';

/// Verification status (doc 04 §3.3; "restricted" = owner-only private in
/// v0.2). Declared in display-priority order, highest first.
enum VerificationStatus {
  private,
  expired,
  conflict,
  needsReview,
  unverified,
  verified;

  /// Highest-priority status among [statuses] (doc 04 §3.3 priority rule).
  /// Empty input means nothing flagged → [verified].
  static VerificationStatus highest(Iterable<VerificationStatus> statuses) {
    var best = VerificationStatus.verified;
    for (final s in statuses) {
      if (s.index < best.index) best = s;
    }
    return best;
  }

  IconData get icon => switch (this) {
    verified => Icons.verified_outlined,
    needsReview => Icons.history,
    expired => Icons.event_busy,
    unverified => Icons.help_outline,
    conflict => Icons.report_outlined,
    private => Icons.lock_outline,
  };

  String label(AppLocalizations l10n) => switch (this) {
    verified => l10n.statusVerified,
    needsReview => l10n.statusNeedsReview,
    expired => l10n.statusExpired,
    unverified => l10n.statusUnverified,
    conflict => l10n.statusConflict,
    private => l10n.statusPrivate,
  };

  StatusColors colors(TrustColors t) => switch (this) {
    verified => t.verified,
    needsReview => t.needsReview,
    expired => t.expired,
    unverified => t.unverified,
    conflict => t.conflict,
    private => t.private,
  };
}

/// Source types in descending reliability (doc 04 §3.1), shown as text.
enum SourceType {
  officialInternal,
  officialPublic,
  training,
  supervisorConfirmed,
  external,
  ownerNote;

  IconData get icon => switch (this) {
    officialPublic => Icons.link,
    _ => Icons.description_outlined,
  };

  String label(AppLocalizations l10n) => switch (this) {
    officialInternal => l10n.sourceOfficialInternal,
    officialPublic => l10n.sourceOfficialPublic,
    training => l10n.sourceTraining,
    supervisorConfirmed => l10n.sourceSupervisor,
    external => l10n.sourceExternal,
    ownerNote => l10n.sourceOwnerNote,
  };
}

enum Freshness { fresh, aging, stale }

/// Content types with their freshness thresholds in days (doc 04 §3.2).
/// `agingAfter == null` means the type has no aging band.
enum TrustContentType {
  pricesOffers(freshMax: 14, agingMax: 30),
  contactNumbers(freshMax: 60, agingMax: 90),
  mobileServices(freshMax: 60, agingMax: 120),
  branchProcedures(freshMax: 90, agingMax: 180),
  siebelConcepts(freshMax: 365, agingMax: null);

  const TrustContentType({required this.freshMax, required this.agingMax});

  /// Last day (inclusive) that counts as fresh.
  final int freshMax;

  /// Last day (inclusive) that counts as aging; beyond → stale/needs review.
  final int? agingMax;

  Freshness freshnessForAge(int days) {
    if (days <= freshMax) return Freshness.fresh;
    final aging = agingMax;
    if (aging != null && days <= aging) return Freshness.aging;
    return Freshness.stale;
  }
}

/// Whole calendar days between two instants (date-only, never negative).
int daysBetween(DateTime from, DateTime to) {
  final a = DateUtils.dateOnly(from);
  final b = DateUtils.dateOnly(to);
  final d = b.difference(a).inHours / 24;
  return d.round() < 0 ? 0 : d.round();
}

/// Tax basis of a price (doc 00 §5: `price_tax_basis` is mandatory).
enum TaxBasis {
  inclusiveRechargeTax,
  exclusiveVat,
  unknown;

  String label(AppLocalizations l10n) => switch (this) {
    inclusiveRechargeTax => l10n.taxInclusiveRecharge,
    exclusiveVat => l10n.taxExclusiveVat,
    unknown => l10n.taxUnknown,
  };
}

/// Validity state of a price (doc 04 §3.6).
enum PriceValidity { active, endingSoon, expired, upcoming, noEndDate }

PriceValidity priceValidityFor({
  DateTime? validFrom,
  DateTime? validUntil,
  required DateTime now,
  int endingSoonDays = 3,
}) {
  final today = DateUtils.dateOnly(now);
  if (validFrom != null && DateUtils.dateOnly(validFrom).isAfter(today)) {
    return PriceValidity.upcoming;
  }
  if (validUntil == null) return PriceValidity.noEndDate;
  final until = DateUtils.dateOnly(validUntil);
  if (until.isBefore(today)) return PriceValidity.expired;
  if (daysBetween(today, until) <= endingSoonDays) {
    return PriceValidity.endingSoon;
  }
  return PriceValidity.active;
}
