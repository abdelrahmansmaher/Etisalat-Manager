# AI Agent Handoff — Etisalat-Manager (`knowledge_hub`, "دليل الكاونتر")

> **Updated:** 2026-11-26 (after the v4 refactor started by Antigravity on 2026-11-25)
> **State:** `flutter analyze` clean, `flutter test` 623/623 green, `flutter build web --release` OK.
> Released as v0.4.0 (APK + web) on 2026-11-26.

## Owner's standing rules (do not break)
- Content ships **only if confirmed, current and useful at the counter**. Anything else goes to
  `docs/removed-content/<date>/<file>.json` with a `removed_reason`. Never invent a number, code or
  price; never raise a status to keep an item. A conflict inside the official site = remove the value.
- Packages are sorted **cheapest first**.
- Colours: navy = actions/selection, gold = prices only, green = confirmed only. Light and dark both
  polished; the chosen theme survives restarts.
- Never show an "unofficial app" line or any disclaimer.
- 4 tabs (الرئيسية، الباقات، الأكواد والأرقام، المزيد), search pill on every tab.
- Reply to the owner in Egyptian Arabic; show screenshots when done.

## Done on 2026-11-26
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
