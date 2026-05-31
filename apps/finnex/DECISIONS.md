# Pocket Flow app — engineering decisions

A running log of non-obvious decisions made in the app shell
(`apps/finnex`). Keep entries short; link to code where useful.

## Auth wiring (HttpAuthRepository → backend `/v1/auth/*`)

The auth feature is wired to the real backend through
`HttpAuthRepository` (`packages/data/api`), which implements the domain
`AuthRepository` and wraps the typed `AuthService` over an authenticated
`Dio`.

Composition (see `lib/providers.dart`):

- `sharedPreferencesProvider` — overridden at bootstrap with the loaded
  `SharedPreferences` instance.
- `authSessionStoreProvider` — `AuthSessionStore`, persists tokens.
- `deviceIdProvider` — `DeviceIdStore`, persists a stable ULID device id.
- `authedDioProvider` — `DioFactory.create(...)` with the FinNex
  interceptor stack (auth header, `X-Device-Id`, idempotency, retry,
  problem-details).
- `httpAuthRepositoryProvider` — `HttpAuthRepository(AuthService(dio), …)`
  with `onPersist`/`onClear` callbacks bound to the session store.
- `authRepositoryOverride` swaps the auth feature's in-memory stub for the
  backend-backed repo. It is only installed when `SharedPreferences` loaded
  successfully (boot stays failsafe; otherwise the stub is kept).

### Configuring the backend base URL

The API base URL defaults to `http://localhost:3000/v1`. Point the app at a
different backend at build/run time with a dart-define:

```sh
flutter run \
  --dart-define=POCKET_FLOW_API_BASE=https://api.example.com

flutter build web \
  --dart-define=POCKET_FLOW_API_BASE=https://api.example.com
```

### Token persistence & Web privacy caveat

Tokens (access + refresh + expiry) are persisted via `shared_preferences`
under the key `pf.auth.tokens`; the device id lives under `pf.device_id`.

On **Flutter Web**, `shared_preferences` is backed by
`window.localStorage`, which is plaintext and readable by any same-origin
script. Storing the refresh token there is acceptable for the current
preview/MVP but is not secure long-term.

**Follow-up (TODO `F-AUTH-SECURE`):** on native targets (iOS / Android /
desktop) migrate to `flutter_secure_storage` (Keychain / Keystore) and keep
only a short-lived in-memory access token on Web.

### Token refresh

`authedDioProvider`'s `onRefresh` currently returns the existing access
token (TODO `F-AUTH-REFRESH`). Once implemented it should call
`AuthService(refreshDio).refresh(refreshToken)` and update the session store,
so 401s are recovered transparently by the `AuthInterceptor`.

### Backend wire-shape note

The Dart DTOs (`auth_dto.dart`) decode snake_case token fields
(`access_token`, `refresh_token`, `expires_in`). The Fastify backend
(`backend/src/routes/auth.ts`) currently returns camelCase
(`accessToken`, …) and also supports `method=password` with `email` /
`password`, which the hand-rolled `SignInRequest` DTO does not yet model.
Aligning the DTOs and the backend response casing is tracked separately;
the smoke test (`packages/data/api/test/auth_smoke_test.dart`) asserts the
snake_case contract the DTOs declare.
