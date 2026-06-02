# Pocket Flow — Build Status (v1.0)

Snapshot of the post-integration state after the 18-agent build, followed by the
UX iteration (Prompts 1-8: adaptive shell, motion, feedback, a11y, polish,
search/command-palette, golden tests, and this final regression).

## Done — Native + Calendar iteration

Shipped on `main`, validated by `flutter analyze` (14 pre-existing info lints,
0 new errors), `dart format`, the package + app test suites, and a
`flutter build web --release`. iOS *simulator* link is knowingly broken on
Google MLKit (no arm64-sim slice) — verified via Web build + analyze + tests,
not iOS sim builds. Android cannot be built in this env (no SDK).

- **F-NATIVE-PLATFORMS** — iOS + Android registered as managed platforms.
  `ios/Runner.xcodeproj` present; bundle id / applicationId `kz.pocketflow.app`;
  iOS deployment target 16.0; Podfile uses `use_frameworks! :linkage => :static`
  and excludes arm64 for the simulator slice. CocoaPods 1.16.2.
- **F-MOBILE-POPUP** — Phone quick actions (Add / AI / Subscriptions) collapse
  into a single FAB that opens a popup bottom sheet so nothing floats over
  content; tablet/desktop keep the docked corner island (`shell/main_shell.dart`).
- **F-CALENDAR** — `pf_calendar` `CalendarService` with a device backend
  (EventKit / Calendar Provider via `device_calendar`) and a Google Calendar
  API backend, selected by `createCalendarService()` (web → Google, mobile →
  device; stub under analyze/test). Settings → Calendar connect section.
- **F-CAL-REMINDERS** — Subscription + budget reminders synced to the calendar
  (`pf_feat_budgets/reminders.dart`, calendar `reminder_service`).
- **F-SPEND-CALENDAR** — Full-screen spending heatmap calendar with per-day
  drilldown (`analytics/pages/spending_calendar_page.dart`).
- **F-RECURRING** — Recurring-rules engine (`RecurringEngine`, domain use-case
  `run_recurring_rules`) with a rules page + make-recurring dialog, materialised
  idempotently on app start and synced to the calendar.
- **F-PUSH-LOCAL** — Local payment-reminder push via
  `flutter_local_notifications` + `timezone` (`NativeNotificationsService`,
  `PaymentReminderSync`); no-op on web. Driven by `HomeSurfaceUpdater`.
- **F-HOME-WIDGETS** — Home-screen widget scaffold via `home_widget`
  (`WidgetBridge`, `WidgetPayload`) pushing balance / next-payment / today-spend;
  WidgetKit + Glance native targets still need manual wiring (see BACKLOG).
- **F-SHARE-ICS** — Share service + ICS calendar export
  (`services/share_service.dart`, calendar `ics_export`).

### Regression notes (this iteration)

- Fixed a **startup-side-effect regression**: `app.dart` fired the recurring
  engine, native notification permission, and home-widget refresh from a
  post-frame callback gated only on `!kIsWeb`. Under `flutter test` `kIsWeb` is
  `false`, so those native-plugin paths ran with no platform channel and left a
  pending 10 s timer — failing `smoke_test.dart` (and cascading into
  `a11y/text_scaling_test.dart`). Added a web-safe `isFlutterTest` guard
  (`services/test_env*.dart`, conditional `dart:io` import) and skipped the
  native startup block + `_refreshHomeSurfaces()` under test. Both tests green
  again; production behaviour is unchanged.
- App tests: **26 pass / 2 skip / 10 fail**. All 10 failures are the
  pre-existing golden pixel-diff drift (dashboard/history/analytics/transaction
  goldens, ~8.7% diff) — confirmed identical at the pre-iteration commit
  `fd8322c`, tracked under F-GOLDEN-STABILITY; not a regression.
- Touched-package suites green: `pf_calendar` (15), `pf_feat_transactions` (33),
  `pf_feat_notifications` (18), `pf_feat_analytics` (14), plus the new
  `run_recurring_rules` (domain) and `reminders` (budgets) tests. The residual
  `pf_domain` (5) and `pf_feat_budgets` (4) failures are the pre-existing
  F-TEST-DRIFT cases (final-class mock / invalid ULID), not new.
- **Web release build:** succeeds; `build/web` totals **44 MB**
  (`main.dart.js` ≈ 5.2 MB; MaterialIcons tree-shaken 1.6 MB → 37 KB). Wasm
  dry-run flags `flutter_secure_storage_web` / `flutter_gemma` as wasm-incompatible
  (informational only — the JS build is the target).

## Done — UX iteration (Prompts 1-8)

Shipped on branch `rebrand/pocket-flow`, validated by `flutter analyze`,
`dart format`, the test suites, a `flutter build web --release`, and manual QA
of the running app (screenshots in `docs/screenshots/`):

- **F-ADAPTIVE-SHELL** — `MainShell` swaps a Material 3 `NavigationRail`
  (desktop, ≥ medium width) for a bottom `NavigationBar` (compact width), with
  localized destination labels. Verified live at 1280x800 (rail) and 430-500px
  (bottom bar).
- **F-MOTION** — Hero transitions (balance card / tx icon → Transaction
  Details via `kPfBalanceHeroTag`), animated lists, pull-to-refresh.
- **F-SOUND-V1** — `pf_core_feedback` haptic + sound service with a
  Settings → Sound & Haptics section (haptics on, sound off by default, Preview
  cue). No-op-safe on Web.
- **F-A11Y-BASE** — chart semantics, a contrast audit tool
  (`tools/audit_contrast.dart`), and reduced-motion support.
- **F-HIGH-CONTRAST** — `highContrastProvider` swaps
  `PfTheme.lightHighContrast()` / `darkHighContrast()` at the app root; toggled
  from Settings → Accessibility.
- **F-COMMAND-PALETTE** — Cmd/Ctrl+K command palette (`command_palette.dart`,
  `intents.dart`) with Add expense/income, Search, Open Dashboard/Transactions/
  Analytics/Settings, Toggle theme, Switch language. Verified live via trusted
  Cmd+K.
- **F-SEARCH-FILTERS** — History search field + filter chips (All / Income /
  Expense / Category / Date range) with a `transaction_filters_notifier`.
- **F-LOTTIE-EMPTY** — Lottie-backed empty states (`PfEmptyState` in
  `pf_core_widgets`, depends on `lottie`), plus skeleton loaders and
  swipe-to-delete with an Undo `SnackBar`.
- **F-GOLDEN-TESTS** — offline-font golden harness + goldens for dashboard
  (en/ru/kk × light/dark), history, analytics, and the transaction form.

## Metrics (post-iteration)

- **Aggregate line coverage:** 39.2% (5,340 / 13,616 lines across 307 source
  files; merged `coverage/lcov.info`, generated by `tools/coverage.sh`).
- **Web release build:** succeeds; `build/web` totals **44 MB**
  (`main.dart.js` ≈ 5.0 MB; MaterialIcons tree-shaken to ~36 KB).
- **`flutter analyze`:** 14 issues, all pre-existing (13 info + 1
  `widget_test.dart` MyApp-stub error). The previously-documented
  `smoke_test.dart` error was fixed in Prompt 7, so the count dropped 15 → 14.
- **`dart format --set-exit-if-changed .`:** clean (0 changed) after the
  iteration was formatted.
- **Tests:** app 31 pass / 3 fail; the failures are 2 timing-flaky
  `transaction_form` goldens and the pre-existing `widget_test.dart` stub.
  Package suites pass except pre-existing test/source drift in `pf_domain`
  (final-class mock), `pf_data_api` (removed `AuthFailure` type),
  `pf_feat_budgets` (invalid ULID in test data), `pf_feat_settings`
  (`theme_provider` async-state), and `pf_core_theme` goldens (network Google
  Fonts in the sandbox). None were introduced by Prompts 1-8.

## Implemented (v1.0)

- **Monorepo skeleton** — Melos 6 workspace, root `pubspec.yaml`, `melos.yaml`,
  `vercel.json` for Web deploy, `analysis_options.yaml`.
- **Core packages**
  - `fnx_core_tokens` — design tokens (color, spacing, type, motion).
  - `fnx_core_theme` — Material 3 themes (`FnxTheme.light()` / `dark()`) +
    `BuildContext` extensions.
  - `fnx_core_widgets` — shared widgets (buttons, cards, sheets).
  - `fnx_core_charts` — `fl_chart` wrappers.
  - `fnx_core_l10n` — `AppL10n` with en / ru / kk.
- **Domain layer** (`packages/domain`) — value objects, entities,
  repository interfaces, use-cases; pure Dart, no Flutter import.
- **Data layer**
  - `fnx_data_local` — sqflite-backed DAOs, repository impls, seeders.
  - `fnx_data_api` — Dio-based API client (skeleton for backend hookup).
  - `fnx_data_sync` — outbox/queue wrapper around the local repos.
- **Feature packages** (full UI + controllers + tests):
  - `fnx_feat_auth` — sign-in, sign-up, OTP, biometric, session devices,
    delete-account flow.
  - `fnx_feat_onboarding` — welcome → value props → setup account →
    permissions → first transaction.
  - `fnx_feat_dashboard` — balance card, quick stats, insight banner,
    recent transactions, top-categories pie.
  - `fnx_feat_transactions` — history, details, full form, expense / income
    quick-add sheets, category predictor.
  - `fnx_feat_categories` — list, form, color + icon pickers.
  - `fnx_feat_budgets` — list, form, limits, calculator.
  - `fnx_feat_analytics` — main page, category detail, calendar / heatmap.
  - `fnx_feat_notifications` — center, preferences page, cross-platform
    service (no-op on Web, `flutter_local_notifications` on native).
  - `fnx_feat_insights` — engine + rules, feed page.
  - `fnx_feat_settings` — profile, appearance, language, privacy, data,
    about + persisted theme/locale via `SharedPreferences`.
- **App shell** (`apps/pocketflow`)
  - `MainShell` with Material 3 `NavigationBar` (Home / Transactions /
    Analytics / Settings) and a context-aware FAB on the Transactions tab.
  - Composed `GoRouter` via `StatefulShellRoute.indexedStack` plus
    top-level routes for auth, onboarding, transaction forms, categories,
    budgets, and notifications.
  - `Pocket FlowApp` reads `themeMode` and `locale` from the settings
    providers and supplies the full `AppL10n` delegate chain.
  - Cross-feature provider overrides in `apps/pocketflow/lib/providers.dart`.
- **Web deploy** — `vercel.json` + `web/index.html` ready for `flutter build web`.
- **Backend** — Fastify + Prisma + Postgres scaffold under `backend/`.

## Stubbed (works end-to-end with fake data / providers)

- **Auth** — `StubAuthRepository`. UI flows fully clickable; sessions are
  in-memory only. (`F-AUTH-OAUTH`, `F-AUTH-OTP-REAL`, `F-AUTH-WIRE`.)
- **Transactions / Accounts / Categories repositories** at the app layer —
  the in-memory implementations in `apps/pocketflow/lib/providers.dart` start
  empty; users can create rows but nothing persists across reload.
  (`F-DATA-WIRE`.)
- **Analytics** — reads from the same in-memory transactions stream;
  shows the empty state until rows are added.
- **Notifications** — `InMemoryNotificationsRepository`; native channel
  is real but no remote push. (`F-PUSH`.)
- **Insights** — `_EmptyInsightsDataSource`; engine and rules are real.
- **Budgets** — in-memory repository with empty default; calculator is real.
- **Dashboard** — features its own rich seeded stub repos (cash + card
  accounts) so it always has something to render in isolation.

## Deferred (in BACKLOG)

- `F-IOS-WIDGET`, `F-ANDROID-WIDGET` — home-screen widgets (v1.1).
- `F-SQLCIPHER` — encrypted SQLite on native targets.
- `F-AUTH-OAUTH`, `F-AUTH-OTP-REAL` — real OAuth / phone OTP.
- `F-RECEIPT-VALIDATION` — App Store / Play receipt checks.
- `F-PUSH` — FCM / APNS.
- `F-BACKGROUND-SYNC` — `workmanager` / `BGTaskScheduler`.
- `F-WEB-CONNECTIVITY` — more robust offline detection on Web.
- `F-NATIVE-SCAFFOLD` — `flutter create --platforms=ios,android .` once
  mobile builds are in scope.
- `F-EXPORT-PDF` — PDF statement export.
- `F-MULTI-CURRENCY-FX` — live FX rates with daily cache.

## Known issues / TODOs

- The smoke test mounts `Pocket FlowApp` and verifies no exceptions, but cannot
  exercise navigation past the splash redirect without a pumped timer.
- `apps/pocketflow/lib/providers.dart` uses a single fixed demo user ULID
  (`kDemoUserId`); once real auth lands, replace these overrides with a
  derived provider that watches `authControllerProvider`.
- `analytics` / `transactions` feature providers throw `UnimplementedError`
  by default — they must be overridden at the app layer (already done) or
  in any host that mounts the pages directly (e.g. storybook / goldens).
- No code-gen is run anywhere in v1; if you add freezed/json_serializable
  or riverpod_generator in a package, also add it to the Melos
  `build_runner_build` group.
- Native iOS / Android directories under `apps/pocketflow/` are placeholder
  scaffolds — full mobile build requires `flutter create --platforms=...`.

## Validation hooks (run after Flutter SDK install)

- `melos bootstrap`
- `melos run analyze`
- `melos run test`
- `cd apps/pocketflow && flutter build web --release`
