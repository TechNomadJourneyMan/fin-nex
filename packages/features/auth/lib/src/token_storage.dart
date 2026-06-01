// Token storage wrapper around flutter_secure_storage.
//
// On web, flutter_secure_storage falls back to wrapped localStorage so this
// works on all targets without conditional imports.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists OAuth/session tokens for the PocketFlow app.
///
/// Backed by [FlutterSecureStorage]; on web this delegates to wrapped
/// `window.localStorage` keys (handled by flutter_secure_storage itself).
class TokenStorage {
  /// Creates a token storage. Inject [storage] for testing.
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _accessKey = 'fnx.auth.access';
  static const String _refreshKey = 'fnx.auth.refresh';
  static const String _expiresKey = 'fnx.auth.expires';

  /// Writes [access], [refresh], and [expiresAt] atomically.
  Future<void> writeTokens({
    required String access,
    required String refresh,
    required DateTime expiresAt,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(
      key: _expiresKey,
      value: expiresAt.toUtc().toIso8601String(),
    );
  }

  /// Reads the access token, or `null` if absent.
  Future<String?> readAccess() => _storage.read(key: _accessKey);

  /// Reads the refresh token, or `null` if absent.
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  /// Reads the expiry timestamp, or `null` if absent.
  Future<DateTime?> readExpiresAt() async {
    final raw = await _storage.read(key: _expiresKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Deletes all stored tokens.
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _expiresKey);
  }
}
