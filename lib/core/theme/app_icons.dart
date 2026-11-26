import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

/// The app's single icon vocabulary.
///
/// ## Rules
/// * **One family:** Lucide: clean, even 2px strokes with round caps, the
///   same weight everywhere. The only exception is the filled heart of an
///   active favourite.
/// * **Navigation tabs:** the selected tab uses the heavier 2.5px stroke
///   (`LucideIcons500`); the others use the 2px stroke.
/// * **Directional** glyphs ([back], [arrowForward], [chevron]) use the
///   `Dir` variants, so they mirror automatically in Arabic. Never pick
///   left/right manually.
/// * **Sizes** come from [AppIconSize]; icons inside tiles from [IconTile].
///
/// Widgets never use `Icons.*` or `LucideIcons.*` directly: add a semantic
/// name here instead.
abstract final class AppIcons {
  // ---- Tools and training -------------------------------------------------
  static const IconData toolFavorite = Icons.favorite_rounded;
  static const IconData toolFavoriteOff = LucideIcons.heart;
  static const IconData toolCompare = LucideIcons.gitCompareArrows;
  static const IconData toolRecommend = LucideIcons.sparkles;
  static const IconData toolCalculator = LucideIcons.calculator;
  static const IconData toolEdits = LucideIcons.squarePen;
  static const IconData toolNotes = LucideIcons.stickyNote;
  static const IconData toolWhatsNew = LucideIcons.sparkle;
  static const IconData toolAdd = LucideIcons.plus;
  static const IconData toolRemove = LucideIcons.x;
  static const IconData toolDelete = LucideIcons.trash2;
  static const IconData toolRestore = LucideIcons.undo2;
  static const IconData toolImport = LucideIcons.clipboardPaste;
  static const IconData share = LucideIcons.share2;
  static const IconData customerView = LucideIcons.eye;
  static const IconData customerViewOff = LucideIcons.eyeOff;
  static const IconData toolExport = LucideIcons.share;
  static const IconData toolHide = LucideIcons.eyeOff;
  static const IconData toolBest = LucideIcons.circleArrowUp;
  static const IconData toolMeets = LucideIcons.circleCheck;
  static const IconData toolMisses = LucideIcons.circleMinus;
  static const IconData toolUnknown = LucideIcons.circleHelp;
  static const IconData toolDrag = LucideIcons.gripHorizontal;
  static const IconData toolSwap = LucideIcons.arrowUpDown;
  static const IconData trainCards = LucideIcons.layers;
  static const IconData trainDaily = LucideIcons.calendarDays;
  static const IconData trainQuiz = LucideIcons.messageCircleQuestion;
  static const IconData trainScenario = LucideIcons.store;

  // ---- Navigation tabs (outlined = inactive, filled = active) -------------
  static const IconData navHome = LucideIcons.house;
  static const IconData navHomeActive = LucideIcons500.house;
  static const IconData navPackages = LucideIcons.cardSim;
  static const IconData navPackagesActive = LucideIcons500.cardSim;
  static const IconData navCodes = LucideIcons.grip;
  static const IconData navCodesActive = LucideIcons500.grip;
  static const IconData navMore = LucideIcons.layoutGrid;
  static const IconData navMoreActive = LucideIcons500.layoutGrid;

  // ---- Directional (auto-mirrored in RTL) -------------------------------
  static const IconData back = LucideIcons.arrowLeftDir;
  static const IconData arrowForward = LucideIcons.arrowRightDir;

  /// Trailing "opens" chevron of list rows / cards.
  static const IconData chevron = LucideIcons.chevronRightDir;

  // ---- Actions ------------------------------------------------------------
  static const IconData search = LucideIcons.search;
  static const IconData clear = LucideIcons.circleX;
  static const IconData copy = LucideIcons.copy;
  static const IconData call = LucideIcons.phone;
  static const IconData filter = LucideIcons.slidersHorizontal;
  static const IconData dropdown = LucideIcons.chevronDown;
  static const IconData jump = LucideIcons.listFilter;
  static const IconData history = LucideIcons.history;
  static const IconData link = LucideIcons.link;
  static const IconData pdf = LucideIcons.fileText;
  static const IconData document = LucideIcons.fileText;
  static const IconData info = LucideIcons.info;
  static const IconData lock = LucideIcons.lock;
  static const IconData edit = LucideIcons.squarePen;
  static const IconData quickAnswer = LucideIcons.zap;
  static const IconData offline = LucideIcons.cloudOff;
  static const IconData layers = LucideIcons.layers;
  static const IconData calculator = LucideIcons.calculator;
  static const IconData sort = LucideIcons.arrowUpDown;
  static const IconData sortPriceUp = LucideIcons.arrowUpNarrowWide;
  static const IconData sortPriceDown = LucideIcons.arrowDownWideNarrow;
  static const IconData sortQuota = LucideIcons.database;
  static const IconData exportPdf = LucideIcons.fileDown;
  static const IconData valueBest = LucideIcons.trophy;
  static const IconData exportText = LucideIcons.messageSquareText;
  static const IconData print = LucideIcons.printer;
  static const IconData selected = LucideIcons.check;
  static const IconData training = LucideIcons.graduationCap;
  static const IconData brand = LucideIcons.bookOpen;

  // ---- Settings -----------------------------------------------------------
  static const IconData appearance = LucideIcons.palette;
  static const IconData themeSystem = LucideIcons.sunMoon;
  static const IconData themeLight = LucideIcons.sun;
  static const IconData themeDark = LucideIcons.moon;
  static const IconData language = LucideIcons.languages;

  // ---- Status / trust -----------------------------------------------------
  static const IconData confirmed = LucideIcons.badgeCheck;
  static const IconData unconfirmed = LucideIcons.circleHelp;
  static const IconData conflict = LucideIcons.triangleAlert;
  static const IconData needsReview = LucideIcons.history;
  static const IconData expired = LucideIcons.calendarX;
  static const IconData privateNote = LucideIcons.lock;
  static const IconData lastVerified = LucideIcons.clock;
  static const IconData review = LucideIcons.listChecks;

  // ---- Empty states (shown large in a tile) -------------------------------
  static const IconData emptySearch = LucideIcons.searchX;
  static const IconData emptySection = LucideIcons.inbox;
  static const IconData notFound = LucideIcons.fileSearch;
  static const IconData comingSoon = LucideIcons.graduationCap;
  static const IconData allReviewed = LucideIcons.circleCheckBig;

  // ---- Sections -----------------------------------------------------------
  static const IconData sectionPackages = LucideIcons.tag;
  static const IconData sectionInternet = LucideIcons.wifi;
  static const IconData sectionProcedures = LucideIcons.clipboardList;
  static const IconData sectionNumbers = LucideIcons.hash;
  static const IconData sectionWallet = LucideIcons.wallet;
  static const IconData sectionGlossary = LucideIcons.bookOpen;
  static const IconData sectionCompany = LucideIcons.building2;

  // ---- Facts (by meaning) -------------------------------------------------
  static const IconData price = LucideIcons.tag;
  static const IconData recharge = LucideIcons.receipt;
  static const IconData code = LucideIcons.hash;
  static const IconData phone = LucideIcons.phone;
  static const IconData validity = LucideIcons.calendarCheck;
  static const IconData renewal = LucideIcons.refreshCw;
  static const IconData afterBundle = LucideIcons.hourglass;
  static const IconData quota = LucideIcons.chartPie;
  static const IconData quotaData = LucideIcons.arrowDownUp;
  static const IconData quotaMinutes = LucideIcons.phone;
  static const IconData quotaSms = LucideIcons.messageSquare;
  static const IconData quotaMixes = LucideIcons.infinity;
  static const IconData quotaLines = LucideIcons.users;
  static const IconData quotaApps = LucideIcons.layoutGrid;
  static const IconData speed = LucideIcons.gauge;
  static const IconData roaming = LucideIcons.globe;
  static const IconData fee = LucideIcons.receipt;
  static const IconData limit = LucideIcons.gauge;
  static const IconData percent = LucideIcons.percent;
  static const IconData date = LucideIcons.calendar;
  static const IconData note = LucideIcons.notebookText;

  // ---- Categories (content sub-groups) ------------------------------------
  static const IconData catMixes = LucideIcons.infinity;
  static const IconData catPostpaid = LucideIcons.crown;
  static const IconData catSuperConnect = LucideIcons.zap;
  static const IconData catMegabytes = LucideIcons.arrowDownUp;
  static const IconData catHours = LucideIcons.timer;
  static const IconData catDailyCard = LucideIcons.creditCard;
  static const IconData catDsl = LucideIcons.router;
  static const IconData catHomeWireless = LucideIcons.wifi;
  static const IconData cat5g = LucideIcons.radioTower;
  static const IconData catEsim = LucideIcons.scanLine;
  static const IconData catDataLine = LucideIcons.signal;
  static const IconData catLandline = LucideIcons.phoneCall;
  static const IconData catRoaming = LucideIcons.plane;
  static const IconData catHotline = LucideIcons.headset;
  static const IconData catRegulator = LucideIcons.gavel;
  static const IconData catBalanceCodes = LucideIcons.coins;
  static const IconData catInternetCodes = LucideIcons.signal;
  static const IconData catCancelServices = LucideIcons.ban;
  static const IconData catCallServices = LucideIcons.phoneForwarded;
  static const IconData catOffers = LucideIcons.gift;
  static const IconData catApp = LucideIcons.smartphone;
  static const IconData catIdentity = LucideIcons.idCard;
  static const IconData catGsm = LucideIcons.hash;
  static const IconData catPrefixes = LucideIcons.listOrdered;
  static const IconData catWalletCodes = LucideIcons.wallet;
  static const IconData catWalletOpen = LucideIcons.userPlus;
  static const IconData catWalletServices = LucideIcons.layoutGrid;
  static const IconData catFees = LucideIcons.receipt;
  static const IconData catLimits = LucideIcons.gauge;
  static const IconData catSecurity = LucideIcons.keyRound;
  static const IconData catLost = LucideIcons.phoneOff;
  static const IconData catClose = LucideIcons.userX;
  static const IconData catRefund = LucideIcons.refreshCcw;
  static const IconData catComplaints = LucideIcons.messagesSquare;
  static const IconData catBranchCases = LucideIcons.store;
  static const IconData catNewLine = LucideIcons.circlePlus;
  static const IconData catReplaceSim = LucideIcons.repeat;
  static const IconData catOwnership = LucideIcons.arrowLeftRight;
  static const IconData catPortability = LucideIcons.arrowRightLeft;
  static const IconData catSuspend = LucideIcons.lockKeyhole;
  static const IconData catUpdateData = LucideIcons.userCog;
  static const IconData catSystemChange = LucideIcons.arrowUpDown;
  static const IconData catImported = LucideIcons.luggage;
  static const IconData catDevices = LucideIcons.monitorSmartphone;
  static const IconData catCustomers = LucideIcons.smile;
  static const IconData catRules = LucideIcons.listChecks;
  static const IconData catRecharge = LucideIcons.batteryCharging;
  static const IconData catTariff = LucideIcons.badgePercent;
  static const IconData catAddOns = LucideIcons.puzzle;
  static const IconData catFaq = LucideIcons.messageCircleQuestion;
  static const IconData catPriceHistory = LucideIcons.trendingUp;
  static const IconData catSummary = LucideIcons.fileText;
  static const IconData catSources = LucideIcons.libraryBig;
  static const IconData catUnconfirmed = LucideIcons.circleHelp;
  static const IconData catAbout = LucideIcons.info;
  static const IconData catBrand = LucideIcons.store;
  static const IconData catNetwork = LucideIcons.radioTower;
  static const IconData catLoyalty = LucideIcons.star;
  static const IconData catCallerTune = LucideIcons.music;
  static const IconData catEntertainment = LucideIcons.clapperboard;
  static const IconData catSpecialNumbers = LucideIcons.sparkles;
  static const IconData catBusiness = LucideIcons.briefcase;
  static const IconData catCompetitors = LucideIcons.swords;
  static const IconData catTerms = LucideIcons.type;
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
