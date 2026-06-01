# Merge Report — Iteration 3

**App:** Pocket Flow (internal: finnex / fnx_*)
**Date:** 2026-05-31
**Baseline:** `980387c` (fix: transaction save + sqflite handle loss + dark-theme bleed)
**Head:** `c812cdd`
**Branch:** main (no worktree isolation; eight agents committed directly)

---

## 1. Commit Summary (since 980387c)

| Commit | Type / Scope | Summary | Files |
|--------|--------------|---------|-------|
| `bb5702b` | chore(deploy) | vercel smoke test (agent-report stamp) | 1 |
| `6677a94` | fix(settings) | finish Pocket Flow → Pocket Flow rebrand in About page (+3 .arb locales, generated l10n, profile default name, "OmniFi OS · design philosophy" subtitle) | 10 |
| `ade75c9` | feat(e2e) | AES-GCM-256 client-side envelope cipher + PBKDF2 key derivation (new `fnx_e2e_crypto` pkg, 23 tests) | 10 |
| `11cec07` | feat(auth) | wire `HttpAuthRepository` to backend `/v1/auth/sign-in` + token/device-id persistence | 9 |
| `5a928ac` | feat(local-llm) | on-device Gemma 3n E4B int4 (`fnx_local_llm`) + `/settings/local-llm` page (Web no-op) | 15 |
| `d6f947b` | fix(transactions) | remove duplicate in-page Add FAB; Dynamic Island "+" owns the new-transaction action | 3 |
| `672be06` | feat(transactions) | swipe right = edit / left = delete with Cupertino confirm + undo SnackBar + haptics | 3 |
| `c812cdd` | feat(onboarding) | first-run demo transactions with dismissable dashboard banner | 7 |

Net: **47 files changed, +3432 / −95** across the iteration.

---

## 2. Per-Task Verdict

| Task | Verdict | Notes |
|------|---------|-------|
| Settings rebrand (Pocket Flow → Pocket Flow) | ✅ done | About + Profile + 3 ARB locales + regenerated l10n. Visible strings only; package identifiers untouched per policy. |
| E2E crypto envelope | ⚠️ partial | Crypto package complete and tested (23 tests), but **not yet wired** into app/sync — opt-in `EncryptedSyncService` decorator documented in `NEXT_STEPS.md` only. |
| Auth wiring to backend | ⚠️ partial | `HttpAuthRepository` + `AuthSessionStore` + `DeviceIdStore` live and providers wired; smoke tests pass. `onRefresh` body, email/password `method=password` DTO, and account-delete call left as TODOs. |
| On-device LLM (Gemma) | ⚠️ partial | Package, use-cases, settings/playground page, provider wiring, and prompt-template tests all landed; `flutter analyze` clean. Native-asset tests blocked locally by Xcode-license `objective_c` hook (Web build unaffected). |
| Transactions: remove duplicate FAB | ✅ done | Dynamic Island owns "+"; empty-state inline CTA kept; regression test asserts no `FloatingActionButton`. |
| Transactions: swipe edit/delete | ✅ done | Dismissible rows, confirm dialog, undo SnackBar (3s), haptics; `swipe_delete_test.dart`. |
| Onboarding demo seed | ✅ done | `DemoSeedService` seeds 4 demo txns, dashboard banner with delete/dismiss; 5 tests pass. |
| Vercel deploy verification | ✅ done | See §5. |

Skipped: none (❌ none).

---

## 3. Files Touched per Logical Area

| Area | Files |
|------|-------|
| `apps/finnex/` | 10 (main.dart, providers.dart, routes.dart, pubspec.yaml, DECISIONS.md, onboarding/demo_seed_service.dart, pages/local_llm_settings_page.dart, services/auth_session_store.dart, services/device_id_provider.dart, test/demo_seed_service_test.dart) |
| `packages/core/` | 7 (l10n: 4 generated + 3 .arb) |
| `packages/features/` | 7 (dashboard ×2, settings ×3, transactions: history_page.dart + 2 tests) |
| `packages/services/` | 19 (e2e_crypto ×10, local_llm ×9) |
| `backend/` | 0 (no source changes; only untracked `package-lock.json`) |
| repo root | 1 (`.agent-report.md`) |

---

## 4. Known Follow-ups

**TODO markers added (all intentional, tracked by ticket):**
- `TODO(F-AUTH-REFRESH)` — `http_auth_repository.dart`: exchange refresh token for new access token (`onRefresh` body unimplemented).
- `TODO(F-AUTH-SECURE)` — Web stores a short-lived in-memory access token; secure storage caveat documented.
- `TODO(F-AUTH-DELETE)` — account-delete backend call not yet made; UI returns to signed-out state only.
- `TODO(F-LEGAL)` ×2 — `about_page.dart`: open privacy / terms URLs.

**Tests skipped / blocked:**
- `fnx_local_llm` native-asset tests are blocked **locally** by the `objective_c` Xcode-license hook. Prompt-template (offline) tests pass; Web build is unaffected. CI/Web does not hit this path.
- All other test suites pass: e2e_crypto (23), auth smoke (3), demo_seed (5), no_history_fab (1), swipe_delete.

**Deps needing a manual `flutter pub get`:**
- `apps/finnex/pubspec.yaml` adds: `fnx_local_llm` (path dep), `shared_preferences ^2.3.2`, `dio ^5.7.0`.
- New packages with their own resolution: `fnx_local_llm` (`flutter_gemma ^0.10.0`, `path_provider ^2.1.4`), `fnx_e2e_crypto` (`cryptography ^2.7.0`, `convert ^3.1.1`, `meta ^1.15.0`).
- Run `flutter pub get` in `apps/finnex/` (and `gen-l10n` in `packages/core/l10n/`) before building.

**Untracked, intentionally not committed:**
- `.claude/` (agent harness config)
- `backend/package-lock.json` (npm lockfile; commit separately if backend deps changed)

---

## 5. Vercel Verification (from vercel-verify / deploy agent)

From `.agent-report.md`:

> **status=UP** — url=https://fin-nex.vercel.app
> `main.dart.js` = 4,501,853 bytes (~4.5 MB release), `manifest.json` name = "Pocket Flow",
> `sqflite_sw.js` = 200, `flutter_service_worker.js` = 200, index title = "Pocket Flow".
> Recommendation: deployment healthy; no action needed. Consider adding `/healthz` or a version stamp for future automated checks.

**Live URL:** https://fin-nex.vercel.app — **HEALTHY**

---

## 6. Verification Commands (run before pushing)

```bash
cd packages/core/l10n && flutter pub get && flutter gen-l10n
cd apps/finnex && flutter pub get
cd apps/finnex && dart run sqflite_common_ffi_web:setup
cd apps/finnex && flutter build web --release --no-tree-shake-icons
```

> Flutter version constraint: Vercel builds with **Flutter 3.32.5 (Dart 3.8)**. Avoid `SwitchListTile.activeThumbColor` (use `activeColor`) and digit separators (`1_000_000`). `Color.withValues(alpha:)` is fine.

---

## 7. Push

```bash
git push origin main
```

*(Do not push from the synthesizer agent — the orchestrator performs the push.)*
