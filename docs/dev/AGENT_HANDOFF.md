# AI Agent Handoff — Etisalat-Manager (`knowledge_hub`)

> **Date:** 2026-11-25
> **Current State:** Mid-refactor v3 → v4 (SIM Card navy + gold design system, 4-tab shell). Core tool screens and `toolRoutes` were just implemented and wired.
> **Important Verification Note:** `flutter analyze`, `dart analyze`, and `flutter test` timed out/hung inside the restricted Windows sandbox during the previous session. **Run `flutter analyze` and `flutter test` first** in an environment where Flutter CLI runs cleanly (or outside sandbox if needed) before doing further work.

---

## 1. What Was Just Completed

### Bug & Data Fixes
- **`lib/features/tools/item_actions.dart`**: Fixed compile-time type mismatch `l10n.toolsNoteCount('$notes')` → `l10n.toolsNoteCount(notes)` (the ARB signature in `lib/l10n/app_localizations.dart` expects `int`).
- **`assets/content/numbers.json`**: Fixed broken `related` reference on `num-recharge-hakamini` (`"pkg-hekaya-mini"` did not exist) → replaced with `"pkg-hekaya-mini-19"`, `"pkg-hekaya-mini-22-5"`, `"pkg-hekaya-mini-30"`.
- **`web/manifest.json`**: Updated `background_color` and `theme_color` from `#1E2A78` (v3) to `#142258` (`AppColors.light.masthead`).
- **`lib/features/more/more_screen.dart` & `lib/features/packages/packages_screen.dart`**: Aligned tool icons to `AppIcons.toolNotes`, `AppIcons.toolEdits`, `AppIcons.toolWhatsNew`, `AppIcons.toolCompare`, `AppIcons.toolRecommend`, `AppIcons.toolCalculator`.

### Implemented & Wired Screens
All routes in `lib/features/tools/tool_routes.dart` (`toolRoutes`) were previously `[]` and are now wired with `AppPage`:
- **`lib/features/tools/compare_screen.dart`** (`CompareScreen`): Pick 2–4 packages via `showPackagePicker`, table via `compareRows(...)`, period-difference notice (`periodsDiffer`), best-value highlights, clickable package headers.
- **`lib/features/tools/recommend_screen.dart`** (`RecommendScreen`): Mobile/Home toggle, budget/GB/minutes inputs via `NumberField`, live results via `recommend(...)` grouped into `fits`, `maybe`, `closest`.
- **`lib/features/tools/calculator_screen.dart`** (`CalculatorScreen`): Card-to-balance & price-to-card modes via `rechargeRuleProvider`, quick preset chips (`10..200`), `SimShape` hero card, clickable source item.
- **`lib/features/tools/favorites_screen.dart`** (`FavoritesScreen`): Reorderable list using `favoritesProvider.notifier.reorder(...)` and quick remove toggle.
- **`lib/features/tools/notes_screen.dart`** (`NotesScreen`): Local private notes with privacy banner, search via `searchNotes(...)`, add/edit bottom sheet, delete with Undo (`putBack`).
- **`lib/features/tools/whats_new_screen.dart`** (`WhatsNewScreen`): Diff changelog using `whatsNewProvider`, marks seen on open (`markSeen()`), links to changed items.
- **`lib/features/tools/editor_screen.dart`** (`EditorScreen`, `ItemEditorScreen`): Local override management (`overridesProvider`), JSON export (`SharePlus.instance.share` + clipboard fallback), validated import preview (`OverridesTransfer.parse` / `diff`), create/edit form with dynamic facts, codes, phones, hide toggle, and dirty-exit `PopScope`.
- **`lib/features/training/training_screen.dart`** (`TrainingScreen`): Replaced placeholder with full hub using `trainingDeckProvider` and `trainingProgressProvider` (Daily Question, Leitner Flashcards session, 10-question Quiz + wrong-answer review, Branch Scenarios, level stats, weakest topics, reset confirmation).

### Home & Detail Improvements
- **`lib/features/home/home_screen.dart`**:
  - Added `_WhatsNewBanner` watching `whatsNewUnseenProvider`.
  - Added `_QuickToolsStrip` (Recommend, Compare, Calculator when available, Training).
  - Wrapped empty favorites state in `AppCard(role: CardRole.flat)`.
  - Upgraded `_SectionTile` to use `TintedIcon(icon, tile: IconTile.sm)` and display section item counts.
- **`lib/features/content/item_detail_screen.dart`**:
  - Made source URLs (`s.url`) clickable using `url_launcher` (`LaunchMode.externalApplication`).

---

## 2. Remaining Tasks for the Next Agent (Ordered by Priority)

### Priority 1: Compile Check & Test Suite Recovery
1. **Run `flutter analyze`**: Fix any warnings/lints in the newly added screens (`compare_screen.dart`, `recommend_screen.dart`, `calculator_screen.dart`, `favorites_screen.dart`, `notes_screen.dart`, `whats_new_screen.dart`, `editor_screen.dart`, `training_screen.dart`).
2. **Fix broken v3 tests in `test/`**:
   These test files still reference deleted v3 files (`browse_screen.dart`, `me_screen.dart`, `review_screen.dart`), deleted widgets (`SourceBadge`, `ConflictBanner`, `SectionTone`), or 5 nav tabs (`nav-4`):
   - `test/app_shell_test.dart` → update for 4 tabs (`HomeScreen`, `PackagesScreen`, `CodesScreen`, `MoreScreen`), `nav-0`..`nav-3`, `search-pill`.
   - `test/capsules_test.dart` → update `nav-4` → `nav-3`, `MeScreen` → `MoreScreen`.
   - `test/overflow_test.dart` → update `MeScreen` → `MoreScreen`, `nav-4` → `nav-3`.
   - `test/navigation_motion_test.dart` → update `nav-4` → `nav-3`.
   - `test/features/content_screens_test.dart` → remove `review_screen.dart`, `SourceBadge`, `ConflictBanner` assertions; update for v4 `SectionScreen`, `ItemDetailScreen`, `MoreScreen`.
   - `test/features/package_detail_test.dart` → update `ConflictBanner` assertion to match `ItemDetailScreen`'s v4 conflict UI.
   - `test/core/theme/contrast_test.dart` → remove deleted v3 tokens (`heroGradientStart`, `heroGradientMid`, `cardTop`, `SectionTone`, `trust.expired`, `trust.unverified`, `trust.private`) and add WCAG contrast assertions for v4 tokens (`masthead`, `onMasthead`, `onMastheadMuted`, `mastheadField`, `mastheadPrice`, `surfaceElevated`).
3. **Add widget tests** for the new tool screens (`CompareScreen`, `RecommendScreen`, `CalculatorScreen`, `TrainingScreen`, `NotesScreen`, `EditorScreen`, `FavoritesScreen`, `WhatsNewScreen`).

### Priority 2: UI/UX Polish & Organization (Phase 2)
1. **`lib/features/packages/packages_screen.dart`**:
   - `_PackagesTop` squeezes 3 `_ToolButton` pills next to `MastheadTitle` inside `minHeight: 36`, causing horizontal clipping/scrolling on 360dp screens or larger text scales. Move tools to a cleaner row/overflow action or compact icon buttons with tooltips.
   - Keep `SegmentedCapsule` (Mobile / Mobile Internet / Home) accessible when scrolled (currently only family capsules sit in `PinnedHeaderSliver`).
   - Add one-tap **Copy Code** button and favorite indicator on `PackageRow` (`lib/features/content/content_widgets.dart`) so counter staff don't have to open detail just to copy `*319*52#`.
2. **`lib/features/codes/codes_screen.dart`**:
   - Distinguish hotlines (`ItemType.contact`), network USSD codes, and wallet codes visually using `TintedIcon` in `CodeRow` or dedicated leading icons.
   - Add quick category filter chips (e.g., All / Hotlines / Balance / Internet / Wallet / Cancel VAS).
3. **`lib/features/content/item_detail_screen.dart`**:
   - Restore a dedicated **Conflict Comparison Card** (`status == ItemStatus.conflict`) showing conflicting values side-by-side instead of only `_ReviewNote`.
   - Persist `_StepsChecklist` completion state (e.g., in an in-memory session provider keyed by `item.id`) and add a progress counter (`2 / 5`) + reset button.
   - Add **"Copy Summary for Customer" / "Share"** action (`SharePlus` / formatted clipboard text) and **"Customer View Mode"** toggle (hiding `TrustLine`, `_ReviewNote`, `Sources`, and internal notes when showing the screen to a customer).
4. **`lib/features/search/search_screen.dart`**:
   - In the idle state (empty query), add **popular quick-search chips** (e.g., `خدمة العملاء`, `حكاية`, `شحن`, `سلفني`, `المحفظة`, `بدل فاقد`).
   - In empty search results (`searchEmptyTitle`), add a non-dead-end CTA to clear section filter or add a custom item (`ToolRoutes.newItem`).
5. **Responsive Wide Layout (`width >= 600` / `840`)**:
   - In `TabScaffold` (`lib/core/widgets/masthead.dart`) and `PageScaffold` (`lib/core/widgets/page_scaffold.dart`), constrain scrolling body width on desktop/tablet (e.g., centered `ConstrainedBox(maxWidth: 840)`) so cards and segmented controls don't stretch across wide monitors.
   - Add desktop/web keyboard shortcut (`Ctrl+K` or `/`) to open `AppRoutes.search`.
6. **`lib/features/more/more_screen.dart`**:
   - Add a **Knowledge Base Summary & Backup** card (total items, officially verified count, `latestAsOf`, shortcut to export edits, and clear history/recent searches button).

### Priority 3: Content & Localization Upgrades
1. **Merge verified official findings**: Review `docs/dev/official-findings-2026-11-25.md` and incorporate verified items into `assets/content/*.json` following `assets/content/SCHEMA.md` (with `checked_at: "2026-11-25"` and `type: "official_site"`).
2. **Unify Arabic copy tone in `lib/l10n/app_ar.arb`**: Core UI uses clean formal Arabic while `tools*`/`editor*`/`notes*`/`training*` use heavy Egyptian slang (`مفيش`, `اتشال`, `دوس`, `خلاص`). Harmonize the tone so the entire app feels consistent and professional, then regenerate `app_localizations*.dart` via `flutter gen-l10n`.

---

## 3. Coding Rules & Design Constraints to Respect
- **Colors**: `AppColors` (`lib/core/theme/app_colors.dart`) — Navy (`primary` / `masthead`) for structure/actions, Gold (`accentText` / `mastheadPrice`) **only for prices**, Green (`verified`) **only for confirmed status/best metrics**. Never use hardcoded `Color(...)` in feature widgets.
- **Icons**: Always add/use semantic constants in `AppIcons` (`lib/core/theme/app_icons.dart`); never call `Icons.*` directly in feature files.
- **Bidi / Codes**: Never use raw `Text` for strings that may contain `*...#` USSD codes or Arabic+English mixed numbers; always use `ProseText`, `CodeValue`, or `LtrText`.
- **Typography**: Minimum text size is `12sp` (`AppTypography.labelS`). Never use `fontSize < 12` or italic Arabic.
- **Documentation Integrity**: Preserve existing comments/docstrings unrelated to your changes. Always verify `file:///` paths and test runs before reporting results.
