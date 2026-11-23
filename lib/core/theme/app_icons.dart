import 'package:flutter/material.dart';

/// The app's single icon vocabulary.
///
/// ## Rules
/// * **One family:** Material Icons **Rounded** (bundled with Flutter, no
///   extra package). Never the Sharp family, never mixed styles in one view.
/// * **Filled rounded is the default** for every glyph: tiles, chips, facts,
///   actions, status.
/// * **Outlined only for an inactive toggle** whose active state is the
///   filled glyph (navigation tabs). Selected = filled, unselected =
///   outlined, nothing else uses outlined.
/// * **Directional** glyphs ([back], [forward], [chevron], [arrowForward])
///   carry `matchTextDirection`, so they mirror automatically in Arabic.
///   Never pick left/right manually.
/// * **Sizes** come from [AppIconSize]; icons inside tiles from [IconTile].
///
/// Widgets never use `Icons.*` directly — add a semantic name here instead.
abstract final class AppIcons {
  // ---- Navigation tabs (outlined = inactive, filled = active) -------------
  static const IconData navHome = Icons.home_outlined;
  static const IconData navHomeActive = Icons.home_rounded;
  static const IconData navBrowse = Icons.grid_view_outlined;
  static const IconData navBrowseActive = Icons.grid_view_rounded;
  static const IconData navSearch = Icons.search_rounded;
  static const IconData navTraining = Icons.school_outlined;
  static const IconData navTrainingActive = Icons.school_rounded;
  static const IconData navMe = Icons.person_outline_rounded;
  static const IconData navMeActive = Icons.person_rounded;

  // ---- Directional (auto-mirrored in RTL) -------------------------------
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData arrowForward = Icons.arrow_forward_rounded;

  /// Trailing "opens" chevron of list rows / cards.
  static const IconData chevron = Icons.chevron_right_rounded;

  // ---- Actions ------------------------------------------------------------
  static const IconData search = Icons.search_rounded;
  static const IconData clear = Icons.cancel_rounded;
  static const IconData copy = Icons.content_copy_rounded;
  static const IconData call = Icons.call_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData history = Icons.history_rounded;
  static const IconData link = Icons.link_rounded;
  static const IconData pdf = Icons.picture_as_pdf_rounded;
  static const IconData document = Icons.description_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData lock = Icons.lock_rounded;
  static const IconData edit = Icons.edit_note_rounded;
  static const IconData quickAnswer = Icons.bolt_rounded;
  static const IconData offline = Icons.offline_bolt_rounded;
  static const IconData layers = Icons.layers_rounded;
  static const IconData brand = Icons.auto_stories_rounded;

  // ---- Settings -----------------------------------------------------------
  static const IconData appearance = Icons.palette_rounded;
  static const IconData themeSystem = Icons.brightness_auto_rounded;
  static const IconData themeLight = Icons.light_mode_rounded;
  static const IconData themeDark = Icons.dark_mode_rounded;
  static const IconData language = Icons.translate_rounded;

  // ---- Status / trust -----------------------------------------------------
  static const IconData confirmed = Icons.verified_rounded;
  static const IconData unconfirmed = Icons.help_rounded;
  static const IconData conflict = Icons.report_rounded;
  static const IconData needsReview = Icons.history_rounded;
  static const IconData expired = Icons.event_busy_rounded;
  static const IconData privateNote = Icons.lock_rounded;
  static const IconData lastVerified = Icons.schedule_rounded;
  static const IconData review = Icons.fact_check_rounded;

  // ---- Empty states (shown large in a tile) -------------------------------
  static const IconData emptySearch = Icons.search_off_rounded;
  static const IconData emptySection = Icons.inbox_rounded;
  static const IconData notFound = Icons.find_in_page_rounded;
  static const IconData comingSoon = Icons.school_rounded;
  static const IconData allReviewed = Icons.task_alt_rounded;

  // ---- Sections -----------------------------------------------------------
  static const IconData sectionPackages = Icons.sell_rounded;
  static const IconData sectionInternet = Icons.wifi_rounded;
  static const IconData sectionProcedures = Icons.assignment_rounded;
  static const IconData sectionNumbers = Icons.dialpad_rounded;
  static const IconData sectionWallet = Icons.account_balance_wallet_rounded;
  static const IconData sectionGlossary = Icons.menu_book_rounded;
  static const IconData sectionCompany = Icons.apartment_rounded;

  // ---- Facts (by meaning) -------------------------------------------------
  static const IconData price = Icons.sell_rounded;
  static const IconData recharge = Icons.receipt_long_rounded;
  static const IconData code = Icons.dialpad_rounded;
  static const IconData phone = Icons.call_rounded;
  static const IconData validity = Icons.event_available_rounded;
  static const IconData renewal = Icons.autorenew_rounded;
  static const IconData afterBundle = Icons.more_time_rounded;
  static const IconData quota = Icons.donut_large_rounded;
  static const IconData quotaData = Icons.data_usage_rounded;
  static const IconData quotaMinutes = Icons.call_rounded;
  static const IconData quotaSms = Icons.sms_rounded;
  static const IconData quotaMixes = Icons.all_inclusive_rounded;
  static const IconData quotaLines = Icons.group_rounded;
  static const IconData quotaApps = Icons.apps_rounded;
  static const IconData speed = Icons.speed_rounded;
  static const IconData roaming = Icons.public_rounded;
  static const IconData fee = Icons.request_quote_rounded;
  static const IconData limit = Icons.data_thresholding_rounded;
  static const IconData percent = Icons.percent_rounded;
  static const IconData date = Icons.calendar_month_rounded;
  static const IconData note = Icons.notes_rounded;

  // ---- Categories (content sub-groups) ------------------------------------
  static const IconData catMixes = Icons.all_inclusive_rounded;
  static const IconData catPostpaid = Icons.workspace_premium_rounded;
  static const IconData catSuperConnect = Icons.hub_rounded;
  static const IconData catMegabytes = Icons.data_usage_rounded;
  static const IconData catHours = Icons.timer_rounded;
  static const IconData catDailyCard = Icons.sim_card_rounded;
  static const IconData catDsl = Icons.router_rounded;
  static const IconData catHomeWireless = Icons.wifi_rounded;
  static const IconData cat5g = Icons.five_g_rounded;
  static const IconData catEsim = Icons.sim_card_download_rounded;
  static const IconData catDataLine = Icons.cell_tower_rounded;
  static const IconData catLandline = Icons.phone_in_talk_rounded;
  static const IconData catRoaming = Icons.flight_takeoff_rounded;
  static const IconData catHotline = Icons.support_agent_rounded;
  static const IconData catRegulator = Icons.gavel_rounded;
  static const IconData catBalanceCodes = Icons.payments_rounded;
  static const IconData catInternetCodes = Icons.signal_cellular_alt_rounded;
  static const IconData catCancelServices = Icons.block_rounded;
  static const IconData catCallServices = Icons.phone_forwarded_rounded;
  static const IconData catOffers = Icons.redeem_rounded;
  static const IconData catApp = Icons.smartphone_rounded;
  static const IconData catIdentity = Icons.badge_rounded;
  static const IconData catGsm = Icons.dialpad_rounded;
  static const IconData catPrefixes = Icons.tag_rounded;
  static const IconData catWalletCodes = Icons.account_balance_wallet_rounded;
  static const IconData catWalletOpen = Icons.person_add_rounded;
  static const IconData catWalletServices = Icons.apps_rounded;
  static const IconData catFees = Icons.request_quote_rounded;
  static const IconData catLimits = Icons.data_thresholding_rounded;
  static const IconData catSecurity = Icons.pin_rounded;
  static const IconData catLost = Icons.phonelink_erase_rounded;
  static const IconData catClose = Icons.no_accounts_rounded;
  static const IconData catRefund = Icons.currency_exchange_rounded;
  static const IconData catComplaints = Icons.forum_rounded;
  static const IconData catBranchCases = Icons.storefront_rounded;
  static const IconData catNewLine = Icons.add_card_rounded;
  static const IconData catReplaceSim = Icons.sim_card_alert_rounded;
  static const IconData catOwnership = Icons.swap_horiz_rounded;
  static const IconData catPortability = Icons.sync_alt_rounded;
  static const IconData catSuspend = Icons.phonelink_lock_rounded;
  static const IconData catUpdateData = Icons.manage_accounts_rounded;
  static const IconData catSystemChange = Icons.swap_vert_rounded;
  static const IconData catImported = Icons.luggage_rounded;
  static const IconData catDevices = Icons.devices_rounded;
  static const IconData catCustomers = Icons.sentiment_satisfied_rounded;
  static const IconData catRules = Icons.rule_rounded;
  static const IconData catRecharge = Icons.battery_charging_full_rounded;
  static const IconData catTariff = Icons.price_change_rounded;
  static const IconData catAddOns = Icons.extension_rounded;
  static const IconData catFaq = Icons.quiz_rounded;
  static const IconData catPriceHistory = Icons.trending_up_rounded;
  static const IconData catSummary = Icons.summarize_rounded;
  static const IconData catSources = Icons.source_rounded;
  static const IconData catUnconfirmed = Icons.help_rounded;
  static const IconData catAbout = Icons.info_rounded;
  static const IconData catBrand = Icons.storefront_rounded;
  static const IconData catNetwork = Icons.cell_tower_rounded;
  static const IconData catLoyalty = Icons.loyalty_rounded;
  static const IconData catCallerTune = Icons.music_note_rounded;
  static const IconData catEntertainment = Icons.movie_rounded;
  static const IconData catSpecialNumbers = Icons.stars_rounded;
  static const IconData catBusiness = Icons.business_center_rounded;
  static const IconData catCompetitors = Icons.compare_arrows_rounded;
  static const IconData catTerms = Icons.abc_rounded;
}

/// Icon sizes (logical px).
abstract final class AppIconSize {
  /// Inline with text, inside pills.
  static const double inline = 16;

  /// Capsules, segmented controls, overline labels, banner discs.
  static const double chip = 18;

  /// List rows, buttons, actions, trailing chevrons.
  static const double action = 20;

  /// Navigation bar / rail.
  static const double nav = 24;

  /// Inside metric / section tiles.
  static const double tile = 28;

  /// Empty-state illustration.
  static const double hero = 36;
}

/// Icon tile sizes: (container, glyph). One radius rule for all:
/// `container * 0.3`.
enum IconTile {
  /// Pills, compact headers.
  xs(28, 16),

  /// Dense rows (recent strip, capsule leading).
  sm(36, 20),

  /// List rows, code row, settings groups.
  md(44, 22),

  /// Section cards, metric tiles.
  lg(48, 26),

  /// Empty states.
  xl(72, 36);

  const IconTile(this.box, this.glyph);

  final double box;
  final double glyph;

  double get radius => box * 0.3;
}
