# Pocket Flow — Build Status (v1.0)

Snapshot of the post-integration state after the 18-agent build. The Flutter
SDK install runs in parallel with the build, so `flutter analyze` / `flutter
test` validation happens after this document is written.

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
- **App shell** (`apps/finnex`)
  - `MainShell` with Material 3 `NavigationBar` (Home / Transactions /
    Analytics / Settings) and a context-aware FAB on the Transactions tab.
  - Composed `GoRouter` via `StatefulShellRoute.indexedStack` plus
    top-level routes for auth, onboarding, transaction forms, categories,
    budgets, and notifications.
  - `Pocket FlowApp` reads `themeMode` and `locale` from the settings
    providers and supplies the full `AppL10n` delegate chain.
  - Cross-feature provider overrides in `apps/finnex/lib/providers.dart`.
- **Web deploy** — `vercel.json` + `web/index.html` ready for `flutter build web`.
- **Backend** — Fastify + Prisma + Postgres scaffold under `backend/`.

## Stubbed (works end-to-end with fake data / providers)

- **Auth** — `StubAuthRepository`. UI flows fully clickable; sessions are
  in-memory only. (`F-AUTH-OAUTH`, `F-AUTH-OTP-REAL`, `F-AUTH-WIRE`.)
- **Transactions / Accounts / Categories repositories** at the app layer —
  the in-memory implementations in `apps/finnex/lib/providers.dart` start
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
- `apps/finnex/lib/providers.dart` uses a single fixed demo user ULID
  (`kDemoUserId`); once real auth lands, replace these overrides with a
  derived provider that watches `authControllerProvider`.
- `analytics` / `transactions` feature providers throw `UnimplementedError`
  by default — they must be overridden at the app layer (already done) or
  in any host that mounts the pages directly (e.g. storybook / goldens).
- No code-gen is run anywhere in v1; if you add freezed/json_serializable
  or riverpod_generator in a package, also add it to the Melos
  `build_runner_build` group.
- Native iOS / Android directories under `apps/finnex/` are placeholder
  scaffolds — full mobile build requires `flutter create --platforms=...`.

## Validation hooks (run after Flutter SDK install)

- `melos bootstrap`
- `melos run analyze`
- `melos run test`
- `cd apps/finnex && flutter build web --release`
