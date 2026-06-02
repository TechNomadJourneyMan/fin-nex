# Pocket Flow — Backlog

Lightweight backlog. Use `engineering:tech-debt` skill to populate / triage.

## Done (Native + Calendar iteration)

Moved to STATUS.md "Done" section — F-NATIVE-PLATFORMS, F-MOBILE-POPUP,
F-CALENDAR, F-CAL-REMINDERS, F-SPEND-CALENDAR, F-RECURRING, F-PUSH-LOCAL,
F-HOME-WIDGETS, F-SHARE-ICS. This supersedes the earlier `F-NATIVE-SCAFFOLD`
and the local-push half of `F-PUSH` (remote FCM/APNS still pending). The
WidgetKit/Glance *native UI targets* (formerly F-IOS-WIDGET / F-ANDROID-WIDGET)
are now tracked as F-WIDGETKIT-TARGET below — the Dart-side bridge is shipped.

## Done (UX iteration, Prompts 1-8)

Moved to STATUS.md "Done" section — F-ADAPTIVE-SHELL, F-MOTION, F-SOUND-V1,
F-A11Y-BASE, F-HIGH-CONTRAST, F-COMMAND-PALETTE, F-SEARCH-FILTERS,
F-LOTTIE-EMPTY, F-GOLDEN-TESTS.

## Now (in flight)

_None — Native + Calendar iteration complete; see follow-ups below._

## Next — Native + Calendar follow-ups

- **F-OAUTH-CLIENT-ID** — Provision a real Google OAuth client id (web + iOS +
  Android) for the Google Calendar backend. The `GoogleCalendarService`
  currently expects a configured client; without a real id the web/Google
  calendar path cannot authenticate against a live account.
- **F-IOS-SIM-MLKIT** — The iOS *simulator* link fails on Google MLKit (no
  arm64-sim slice). Add a build-config gate (exclude MLKit / SMS-parser deps for
  the simulator slice, or use an xcframework with a sim stub) so `flutter run`
  on the simulator links. Device builds are unaffected.
- **F-ANDROID-CI** — Install the Android SDK in CI and add an
  `assembleDebug` / `flutter build apk` job. Android code/config is written but
  was never built in this env.
- **F-WIDGETKIT-TARGET** — Wire the iOS WidgetKit extension target (Swift) to
  the `home_widget` payload group + add the Glance/AppWidget provider on
  Android. `WidgetBridge`/`WidgetPayload` push the data; the native widget UI
  targets are not yet added to the Xcode/Gradle projects.
- **F-DATA-WIRE-RECURRING** — Persist recurring rules. The recurring engine +
  rules repository currently run against the in-memory app providers (same gap
  as F-DATA-WIRE); back them with the Drift-backed `pf_data_local` store so
  rules survive reload and so the materialised transactions persist.
- **F-CAL-WEB-DEVICE** — On web there is no device calendar; only the Google
  API backend applies. Decide UX for users who decline Google connect (currently
  the device backend is mobile-only and the web path no-ops without OAuth).

## Next (v1.1)

- **F-REBRAND-OMNIFI** — Remove the leftover internal codename "OMNIFI OS" from
  the app-bar badge and the splash screen; per the rebrand rule all
  user-facing strings must read "Pocket Flow". (Found during Prompt 8 QA.)
- **F-I18N-GAPS** — Several dashboard / AI-chat / splash strings are hardcoded
  (mostly Russian: "Последние операции", "ПОДПИСКИ", "Почти готово…") instead of
  going through `AppL10n`. Route them through the en/ru/kk ARBs. (Found during
  Prompt 8 QA — UI currently shows mixed English + Russian.)
- **F-LIGHT-THEME-DEFAULT** — The app is dark-first and the "light" path keeps a
  near-black aesthetic; decide whether a real light surface is in scope and wire
  the theme toggle / `prefers-color-scheme` accordingly.
- **F-PRIVACY-MODE** — Balance/amount blur ("privacy mode") toggle from the
  app bar and Settings (spec'd in 05_ux_spec, not yet built).
- **F-STREAK** — Daily logging streak + the Achievements surface beyond the
  current placeholder page.
- **F-AUTH-REAL** — Replace `StubAuthRepository` with the real backend session
  flow (umbrella for the F-AUTH-* items below); derive `currentUserId*` from
  `authControllerProvider` instead of `kDemoUserId`.
- **F-GOLDEN-STABILITY** — Stabilise the 2 `transaction_form` goldens (single-
  file run hangs / full-run pixel flakiness) and make `pf_core_theme` goldens
  use offline fonts so they don't hit `fonts.gstatic.com` in CI.
- **F-TEST-DRIFT** — Repair the pre-existing failing unit tests not touched by
  the UX iteration: `pf_domain` (final-class mock of `Transaction`),
  `pf_data_api` (`AuthFailure` type removed), `pf_feat_budgets` (invalid
  Crockford ULID "…BUDG01" in test data), `pf_feat_settings` `theme_provider`
  (async state not reflected synchronously).

- **F-DATA-WIRE** — Replace in-memory app providers (`apps/pocketflow/lib/providers.dart`)
  with the Drift-backed repositories from `fnx_data_local`, wrapped by
  `fnx_data_sync` for offline queueing.
- **F-AUTH-OAUTH** — Real Apple / Google OAuth (currently the `auth` feature
  exposes the UI but uses `StubAuthRepository`).
- **F-AUTH-OTP-REAL** — Phone OTP via Twilio / Mobizon (currently stubbed).
- **F-AUTH-WIRE** — Override `authRepositoryProvider` in app composition with
  the `fnx_data_api` implementation, then derive `currentUserId*` providers
  from `authControllerProvider` instead of the hardcoded `kDemoUserId`.
- **F-PUSH** — FCM / APNS push integration (notifications service is no-op
  on Web and `flutter_local_notifications`-based on native — no remote push).
- **F-BACKGROUND-SYNC** — `workmanager` / `BGTaskScheduler` integration so the
  sync queue drains while the app is backgrounded.
- **F-WEB-CONNECTIVITY** — Replace coarse `navigator.onLine` polling with the
  `online` / `offline` events and `connection` API where available.

## Later (v1.x and beyond)

- **F-IOS-WIDGET** — iOS WidgetKit integration (deferred to v1.1+).
- **F-ANDROID-WIDGET** — Android Glance integration (deferred).
- **F-SQLCIPHER** — SQLCipher encryption on native targets. Plain Drift on Web
  is fine; SQLCipher requires native FFI which would block the Web build.
- **F-RECEIPT-VALIDATION** — App Store / Google Play receipt validation on the
  backend for the Pro subscription.
- **F-EXPORT-PDF** — PDF export of statements (CSV export ships in v1).
- **F-MULTI-CURRENCY-FX** — Live FX rates with per-day caching for
  multi-currency accounts (v1 uses static settings-default rates).
- **F-NATIVE-SCAFFOLD** — `flutter create --platforms=ios,android .` to
  regenerate native scaffolding once mobile is in scope.

## Won't

- Sync via WebSockets — REST + push notifications is sufficient for MVP.
- freezed/json_serializable code-gen for the data layer in v1 — avoiding
  `build_runner` keeps the bootstrap path simple. The domain layer uses
  plain immutable classes.
