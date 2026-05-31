// F-02: At-rest encryption key provider.
//
// Threat model:
// • Protects the local sqflite database against offline disk access (lost
//   device, USB tar dump, jailbroken backup extraction).
// • Does NOT defend against a fully compromised process; the key is held
//   in memory while the DB is open.
//
// Web has no Keychain/Keystore equivalent strong enough to make this
// useful — the [WebNoopEncryptionKeyProvider] returns null so the database
// stays plain. Native iOS/Android use [SecureStorageKeyProvider] which
// pulls a 256-bit key from flutter_secure_storage (Keychain / Keystore).
//
// Wiring into sqflite_sqlcipher is performed by AppDataModule on native
// targets — see the TODO marker in app_data.dart.

import 'package:flutter/foundation.dart';

/// Provides the AES-256 key used by SQLCipher.
abstract interface class EncryptionKeyProvider {
  /// Returns a base64-encoded 32-byte key, or null when encryption is
  /// disabled (e.g. on Web).
  Future<String?> getOrCreateKey();
}

/// Web (and tests): no key, no encryption. The data layer falls back to
/// plain sqflite_common_ffi_web.
class WebNoopEncryptionKeyProvider implements EncryptionKeyProvider {
  const WebNoopEncryptionKeyProvider();

  @override
  Future<String?> getOrCreateKey() async => null;
}

/// Native (iOS / Android / desktop): generates a 32-byte key on first use
/// and persists it via flutter_secure_storage. Activate by depending on
/// flutter_secure_storage and replacing this stub.
///
/// Left as a class-with-throw stub so the contract is visible without
/// pulling the dep into the Web build.
class SecureStorageKeyProvider implements EncryptionKeyProvider {
  const SecureStorageKeyProvider();

  @override
  Future<String?> getOrCreateKey() async {
    if (kIsWeb) {
      // Defensive: should never be constructed on Web.
      return null;
    }
    throw UnimplementedError(
      'SecureStorageKeyProvider requires flutter_secure_storage. '
      'Wire it up in a native build profile (apps/finnex/lib/services/'
      'encryption_key_provider.dart). For Web preview we use the no-op.',
    );
  }
}

/// Convenience: picks the right provider for the current target.
EncryptionKeyProvider defaultEncryptionKeyProvider() {
  if (kIsWeb) return const WebNoopEncryptionKeyProvider();
  return const SecureStorageKeyProvider();
}
