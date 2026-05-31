# FinNex — Backlog

Lightweight backlog. Use `engineering:tech-debt` skill to populate / triage.

## Now (in flight)

_None yet — initial v1.0 build is complete pending Flutter SDK install + analyze._

## Next (v1.1)

- **F-DATA-WIRE** — Replace in-memory app providers (`apps/finnex/lib/providers.dart`)
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
