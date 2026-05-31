# NEXT STEPS — wiring `fnx_e2e_crypto` into sync

This package (`fnx_e2e_crypto`) is the **foundation only**. It is intentionally
*not* wired into the app or the sync engine yet — `apps/finnex/pubspec.yaml` is
untouched and `fnx_data_sync` does not depend on it. The merger owns the
integration described below.

## What this package gives you

```dart
import 'package:fnx_e2e_crypto/fnx_e2e_crypto.dart';

// 1. Derive a 256-bit master key from the user's passphrase + per-user salt.
final masterKey = await deriveMasterKey(
  passphrase: userPassphrase,
  salt: accountSalt,            // >=16 random bytes, stored per account
);                              // iterations defaults to kPbkdf2Iterations (200k)

// 2. Show a stable visual fingerprint for device-to-device key verification.
final fp = await fingerprint(masterKey);   // e.g. "K7QP4M2RX9T0Z"

// 3. Encrypt a payload into a self-contained envelope.
final envelope = await encrypt(masterKey, utf8.encode(jsonPayload));

// 4. Serialize to a single base64 wire string (nonce || ciphertext || mac).
final blob = EncryptedBlob.encode(envelope);

// 5. On the other side: decode + decrypt (throws EnvelopeAuthException on
//    wrong key / tampering).
final plaintext = await decrypt(masterKey, EncryptedBlob.decode(blob));
```

## Target architecture: `EncryptedSyncService` decorator

`fnx_data_sync` defines an abstract `SyncService` (see
`packages/data/sync/lib/src/sync_contracts.dart`):

```dart
abstract class SyncService {
  Future<Result<List<PushAck>, Failure>> push(List<SyncQueueRow> batch);
  Future<Result<PullPage, Failure>> pull({
    required String entityTable,
    String? cursor,
    int limit = 100,
  });
}
```

The clean integration is a **decorator** that wraps the real (Dio-backed)
`SyncService` and encrypts on the way out / decrypts on the way in. The server
never sees plaintext — it stores and returns the base64 blob in place of the
entity payload.

```dart
// Lives in fnx_data_sync (which would add a dependency on fnx_e2e_crypto),
// NOT in this package — keep fnx_e2e_crypto free of sync types.
class EncryptedSyncService implements SyncService {
  EncryptedSyncService(this._inner, this._masterKey);

  final SyncService _inner;
  final List<int> _masterKey;

  @override
  Future<Result<List<PushAck>, Failure>> push(List<SyncQueueRow> batch) async {
    // For each row: take its plaintext JSON payload, encrypt it, and replace
    // the payload field with { "enc": "<base64 blob>" } before delegating.
    final encrypted = <SyncQueueRow>[];
    for (final row in batch) {
      final blob = EncryptedBlob.encode(
        await encrypt(_masterKey, utf8.encode(row.payloadJson)),
      );
      encrypted.add(row.copyWith(payloadJson: jsonEncode({'enc': blob})));
    }
    return _inner.push(encrypted);
  }

  @override
  Future<Result<PullPage, Failure>> pull({
    required String entityTable,
    String? cursor,
    int limit = 100,
  }) async {
    final page = await _inner.pull(
      entityTable: entityTable, cursor: cursor, limit: limit,
    );
    return page.map((p) => PullPage(
      nextCursor: p.nextCursor,
      hasMore: p.hasMore,
      entities: [
        for (final e in p.entities)
          RemoteEntity(
            entityTable: e.entityTable,
            serverId: e.serverId,
            serverVersion: e.serverVersion,
            updatedAt: e.updatedAt,
            deletedAt: e.deletedAt,
            // Decrypt the { "enc": "..." } wrapper back into the real payload.
            payload: jsonDecode(utf8.decode(
              await decrypt(_masterKey, EncryptedBlob.decode(e.payload['enc'] as String)),
            )) as Map<String, Object?>,
          ),
      ],
    ));
  }
}
```

> Note: `RemoteEntity.payload` is currently a synchronously-decoded
> `Map<String, Object?>`. Because `decrypt` is async, the pull-side mapping must
> happen in an async loop (as above) before the `PullPage` is constructed —
> don't try to decrypt lazily inside a synchronous getter.

## Integration checklist for the merger

1. Add `fnx_e2e_crypto: { path: ../../services/e2e_crypto }` to
   `packages/data/sync/pubspec.yaml` dependencies.
2. Add `EncryptedSyncService` (above) in `packages/data/sync/lib/src/` and
   export it from `fnx_data_sync.dart`.
3. Decide the **key lifecycle**:
   - Generate a per-account random salt at signup; store it server-side
     (non-secret) and locally.
   - Derive the master key once at unlock; keep it in memory only (never write
     it to sqflite/`flutter_secure_storage` un-wrapped). On native, consider
     wrapping it with the SQLCipher/secure-enclave abstraction already present.
   - Surface `fingerprint(masterKey)` in Settings so users can verify two
     devices share the same key before trusting sync.
4. Server-side (`backend/`): the entity `payload` column becomes opaque
   ciphertext. Strip any server logic that reads inside the payload (search,
   server-side categorization) — it cannot work on E2E-encrypted data. Conflict
   resolution must rely on metadata (`serverVersion`, `updatedAt`) only.
5. Wire the decorator in `apps/finnex/lib/providers.dart`: when the user has an
   unlocked master key, provide `EncryptedSyncService(realService, key)` instead
   of the raw service. Until then, `apps/finnex/pubspec.yaml` stays untouched —
   E2E is opt-in.
6. Migration: existing plaintext rows on the server must be re-encrypted on
   first sync after enabling E2E (one-shot re-push of the local outbox).

## Crypto parameters (don't change silently)

- KDF: PBKDF2-HMAC-SHA256, `kPbkdf2Iterations = 200_000`, 32-byte output.
- Cipher: AES-GCM-256, 12-byte nonce (random per message), 16-byte tag.
- Wire: base64(`nonce` ‖ `ciphertext` ‖ `mac`).
- Fingerprint: first 8 bytes of SHA-256(key), Crockford base32, 13 chars.

These are part of the on-wire/at-rest format. Changing any of them requires a
versioned migration, not an in-place edit.
