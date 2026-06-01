# Pocket Flow — Architecture Decisions

This file records fixed technology choices for the build. Changing any of these
requires explicit consensus from all feature owners.

## Locked decisions

| #  | Decision | Date | Notes |
|----|----------|------|-------|
| 1  | Flutter 3.24+, Dart 3.5+ | 2026-05 | Stable channel only. |
| 2  | Riverpod 2.5+ for state | 2026-05 | No Provider, no BLoC. |
| 3  | go_router 14.x | 2026-05 | Single router exposed by features; bottom-nav via `StatefulShellRoute.indexedStack`. |
| 4  | Plain immutable Dart classes in `packages/domain` (no freezed in v1) | 2026-05 | Skips `build_runner` for the bootstrap path; freezed reserved for the data layer once needed. |
| 5  | sqflite (via `fnx_data_local`) instead of Drift for v1 | 2026-05 | Drift was the original plan but requires `build_runner` and has rougher Web support. sqflite-common-ffi + sqflite_common_ffi_web gives us cross-platform persistence without code-gen. Migration to Drift remains an option. |
| 6  | Dio for HTTP | 2026-05 | Interceptor stack lives in `packages/data/api`. retrofit deferred until generated code is on the table. |
| 7  | intl + flutter_localizations | 2026-05 | All user-facing strings via `AppL10n` (en / ru / kk). |
| 8  | fl_chart wrapped by `fnx_core_charts` | 2026-05 | Chart widgets never import fl_chart directly outside the wrapper. |
| 9  | Backend: Node 20 + Fastify + Prisma + Postgres | 2026-05 | Lives in `backend/`. |
| 10 | **Primary deploy target: Flutter Web on Vercel** | 2026-05 | Mobile (iOS / Android) is in scope but tracked separately. Any code path that uses dart:io / dart:ffi / native plugins is guarded by `kIsWeb` or conditional imports. Native scaffolding can be regenerated later via `flutter create --platforms=ios,android .`. |
| 11 | iOS / Android home-screen widgets deferred to v1.1 | 2026-05 | Not in initial MVP cut. See `F-IOS-WIDGET`, `F-ANDROID-WIDGET`. |
| 12 | Monorepo managed by Melos 6.x | 2026-05 | `pubspec.yaml` at root is workspace shell only. Globs: `apps/*`, `packages/**`. |
| 13 | No SQLCipher in v1 | 2026-05 | Plain DB only. SQLCipher requires native FFI which would block the Web build. See `F-SQLCIPHER`. |
| 14 | Auth stubs in v1 | 2026-05 | The `auth` feature exposes complete UI (sign-in, sign-up, OTP, biometric, device list, delete account) but defaults to `StubAuthRepository`. Real OAuth + OTP land in v1.1 — see `F-AUTH-OAUTH`, `F-AUTH-OTP-REAL`. |
| 15 | App-level cross-feature provider overrides live in `apps/pocketflow/lib/providers.dart` | 2026-05 | Features that require external repositories (`transactions`, `analytics`, `notifications`, `insights`) declare `UnimplementedError`-throwing defaults; the app supplies in-memory implementations until the data layer is wired. |
| 16 | Push notifications are no-op on Web and local-only on native in v1 | 2026-05 | `flutter_local_notifications` for scheduled reminders; remote FCM / APNS push deferred to `F-PUSH`. |

## Open questions

- Auth strategy for v1.1: email/password as a first-class option vs OAuth-only.
- Background sync cadence on Web — likely Service Worker `periodicSync` where supported, polling fallback elsewhere.
- Whether to migrate from sqflite to Drift once `build_runner` is acceptable in the toolchain.
