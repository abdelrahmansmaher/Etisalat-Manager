# AI Agent Handoff — Etisalat-Manager (`knowledge_hub`, "دليل الكاونتر")

> **Updated:** 2026-11-26 (v5: liquid glass, strict prices, direct call, postpaid taxes)
> **State:** `flutter analyze` clean, `flutter test` 781/781 green, `flutter build web --release` OK.
> Release v0.5.0 (2026-11-26) is the first one signed with the release key (secrets
> `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`).
> Earlier APKs were debug-signed, so phones must uninstall them once before installing v0.5.0.

## Owner's standing rules (do not break)
- Content ships **only if confirmed, current and useful at the counter**. Anything else goes to
  `docs/removed-content/<date>/<file>.json` with a `removed_reason`. Never invent a number, code or
  price; never raise a status to keep an item. A conflict inside the official site = remove the value.
- Packages are sorted **cheapest first**.
- **Every price shown must come from an item checked on the official site** (`checked_at`); old
  prices and price-increase history are removed. A test enforces it.
- Colours: navy = actions/selection, gold = prices only, green = confirmed only. Light and dark both
  polished; the chosen theme survives restarts. Design is liquid glass (see below).
- Postpaid packages show the total: fee x 1.08 (table tax) x 1.14 (VAT) + 10 (state development
  fee) + 1.34 (stamp duty, from the owner). `PostpaidTax` in `lib/features/tools/postpaid_tax.dart`.
- Never show an "unofficial app" line or any disclaimer.
- 4 tabs (الرئيسية، الباقات، الأكواد والأرقام، المزيد), search pill on every tab.
- Reply to the owner in Egyptian Arabic; show screenshots when done.

## Design system v5 (liquid glass)
- `AppBackdrop` (lib/core/widgets/liquid_glass.dart): static ambient lights behind every screen.
- `GlassDecoration` / `LiquidGlass`: translucent fill, sheen, bright rim; `blur: true` only on chrome
  (tab header, page bar, nav bar, sheets, popups). Cards and rows never blur (the backdrop is static).
- Tabs: the header is a pinned sliver; content scrolls under it. Packages filters live in the header.
- Motion (`AppMotion`, `lib/core/widgets/motion.dart`): springs, `Entrance` rows rise once per page,
  `SpringPop` on selected nav icons and badges. Nothing loops (tests use pumpAndSettle).
- Popups (`glass_popups.dart`): glass toast, glass sheet, centred popup with blurred page; long-press
  on any row opens `ItemPeek` (price, codes with call/copy, open, favourite).
- Badges (`badges.dart`): official seal, "جديد" for items the latest update added, counts, nav dot.
- Icons: Lucide (`lucide_icons_flutter`), mapped in `AppIcons` only.
- Motion is iOS-style: `AppMotion.smooth/snappy/bouncy` spring curves, `springOf()` physical
  springs, `CupertinoPageTransition` for push/pop (500ms), spring sheets and popups, press = quick
  dip + bouncy release.
- Dock: glass capsule + round search orb; the selected tab has a clear "lens" moved by two springs
  (leading edge faster = liquid stretch); it follows the finger while swiping (`TabPagerScope.swiping`).
- `CapsuleRow(selected:)` paints the pills itself and glides one navy indicator between choices.
- Contrast tests composite glass over every point of the backdrop.

## Done on 2026-11-26 (v5)
- Unconfirmed / old prices removed (wallet limits, InstaPay fees, small cards, old DSL plan, price
  increase answers, imported-phone fee percentages...). Originals in docs/removed-content/2026-11-26.
- Hekaya, Mini, Extra and Super Connect prices re-checked on the official site (2026-11-26).
- Call button places the call / runs the USSD code directly on Android (CALL_PHONE, asked once;
  dialer fallback). MainActivity method channel `counter_guide/call`.
- Emerald totals with taxes and fees, 800 hotline on Emerald pages, postpaid mode in the calculator.
- Recommender rebuilt: budget = what the customer pays (stated total, or the card computed from a
  price deducted from balance), budget-only = most it buys, needs = cheapest that covers them,
  mixes count as minutes only by the stated rates (e& 1 / other 5), duration filter, top pick card.

## Done earlier on 2026-11-26 (v4)
- **Wrong numbers fixed:** package rows, compare and recommend showed the internet quota converted
  with 1024 (e.g. "240 ميجا" for an official 250 MB). They now show the stated value; `quota_gb`
  is only used for sorting and comparing. A real-content test guards it.
- **Family names:** data slugs (`hekaya-mixat`, monograms "O"/"A") replaced by Arabic names.
- **Editor bugs:** a hidden item reopened as a blank form (saving wiped it); a title-only edit dropped
  the structured price; the bundled "confirmed" note leaked into edited items; sheet controllers
  were disposed during the closing animation. Body and steps are now editable.
- **UI:** one-tap copy of the subscription code in package rows, favourite mark, code-row icons
  (hotline / network / wallet), pinned segment + family capsules, icon-only tools on narrow screens,
  steps progress kept per item with reset, "share summary", "customer view" on package pages,
  details table without repeats, quick searches and no dead-end empty search, knowledge-base stats
  and history clearing in المزيد, centred 840dp column + rail on wide screens, Ctrl+K for search,
  48dp minimum for every tab, prices scale instead of overflowing, one professional Arabic tone.
- **Content:** official findings of 2026-11-25 merged (333 flat rate, 778 / +201111234778, 800,
  Super Salefny fees, balance-transfer rules, *80#, Call Keeper, Call Filter, Voice Mail, WiFi
  Calling, Khattein, international call prices, lines per ID, DSL activation times, MNP, wallet
  codes 5 and 15, wallet fees and limits). eSIM swap price and the "+201111234333" abroad number
  removed (contradicted by the official site). Section groups keep the file order.
- **Tests:** old v3 tests rewritten for v4; new tests for compare, recommend, calculator, favorites,
  notes, editor, import, training, what's new, More stats, and real-content rules.

## Open
- Merge `claude/graffiti-app-0cb29c` into `main` (v0.4.0 was tagged on the branch).
- Pages not read yet: gated-community, pensions, International_Money_Remittance,
  multi-media-SMS, video-call. Blocked (HTTP 500): parental-control-service, activation-steps,
  configuration-steps.
- Topics with nothing confirmed (owner to find out at the branch): SIM replacement fee, new-line
  price, ownership-transfer documents, balance-inquiry code, scratch-card recharge code.
