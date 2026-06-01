# Web Compatibility Audit

Snapshot taken during initial scaffolding. Scope: all `lib/` Dart files in
`apps/pocketflow/` and `packages/`. Test files are out of scope (tests run on
the Dart VM, not in the browser).

## Status legend

- OK = web-safe as written
- GUARDED = uses a native API but is gated by `kIsWeb` or conditional imports
- TODO = needs work before web build can succeed

## Findings

### 1. `packages/data/local` — Drift / sqflite setup — GUARDED

- `lib/src/database/factory_io.dart` imports `dart:io`, `path_provider`,
  `sqflite` — native only.
- `lib/src/database/factory_web.dart` imports `sqflite_common_ffi_web` —
  web only.
- `lib/src/database/factory_stub.dart` is the conditional-import fallback.
- `lib/src/database/fnx_database.dart` uses the standard
  `factory_stub.dart if (dart.library.io) factory_io.dart if (dart.library.html) factory_web.dart`
  pattern. Looks correct.

Action: none. Verify at first `flutter build web` that
`sqflite_common_ffi_web` is pinned to a version compatible with Flutter
3.24.5 (the package currently lists `path_provider: ^2.1.4` and
`sqflite: ^2.x`).

### 2. `packages/features/notifications` — flutter_local_notifications — GUARDED

- `lib/src/services/notifications_service.dart` does **not** import the
  `flutter_local_notifications` package at file scope; the `_NativeNotificationsService`
  is currently a stub that only `debugPrint`s. `NotificationsService.native()`
  factory throws `UnsupportedError` on web via `kIsWeb` check.
- `pubspec.yaml` lists `flutter_local_notifications: 17.2.2` as a direct
  dependency.

Action: when wiring the real plugin (TODO F-NOTIF), put the
`flutter_local_notifications` import behind a conditional import
(`notifications_native.dart` / `notifications_web_stub.dart`) so the web
tree-shake never has to evaluate the plugin's platform interface. Until
then the current stub is web-safe.

### 3. `packages/features/categories/lib/src/data/in_memory_categories_repository.dart` — OK

Comment references "no dart:io, no native bindings" — file is pure Dart.
No action.

### 4. `packages/features/onboarding/lib/src/controllers/onboarding_controller.dart` — OK

Only references `flutter_local_notifications` in comments / TODOs. No
import. No action.

### 5. `dart:io` usage — OK (tests only)

The only `dart:io` import is in
`packages/core/l10n/test/fnx_core_l10n_test.dart`, which reads ARB files
from disk during unit tests. Test code never ships to the browser.

### 6. `dart:ffi` — OK

No matches in `apps/pocketflow/lib/` or `packages/`.

## Top-5 critical fixes

None blocking. The two highest-risk areas (Drift native DB, local
notifications) are already insulated behind conditional imports / runtime
`kIsWeb` checks. If `flutter build web` fails after the first end-to-end
wiring pass, expected culprits in order:

1. `sqflite_common_ffi_web` version skew — verify lockfile.
2. `flutter_local_notifications` accidentally pulled into web tree by a
   feature file importing it at top level (should always go through
   `NotificationsService` interface).
3. `path_provider` web stub — package ships a web implementation that
   throws on most methods; avoid calling it on web. The Drift factory
   isolation handles this today.
4. Any new feature file importing `dart:io` directly. Add a CI grep:
   `! grep -rn "^import 'dart:io'" apps/ packages/*/lib`.
5. Plugins with no web support (e.g. `flutter_secure_storage` older
   versions) — pin to versions with web support or wrap in conditional
   imports.
