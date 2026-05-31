// Persistent auth-token store for Pocket Flow.
//
// Holds the current [AuthSession]'s tokens (access + refresh + expiry) and
// mirrors them into `shared_preferences` so a returning user stays signed in
// across app launches.
//
// PRIVACY CAVEAT (Web):
//   On Flutter Web, `shared_preferences` is backed by `window.localStorage`,
//   which is plaintext and readable by any same-origin script. Storing the
//   refresh token there is acceptable for the current preview/MVP but is NOT
//   secure long-term. Follow-up: migrate native (iOS/Android/desktop) targets
//   to `flutter_secure_storage` (Keychain / Keystore) and keep only a
//   short-lived in-memory access token on Web. Tracked as TODO(F-AUTH-SECURE).

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable snapshot of the persisted session tokens.
class AuthSessionTokens {
  /// Default constructor.
  const AuthSessionTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Short-lived bearer token.
  final String accessToken;

  /// Long-lived refresh token.
  final String refreshToken;

  /// [accessToken] expiry moment (UTC).
  final DateTime expiresAt;

  /// True when [expiresAt] is in the past.
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  /// Decode from a JSON map.
  factory AuthSessionTokens.fromJson(Map<String, dynamic> json) =>
      AuthSessionTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String).toUtc(),
      );

  /// Encode to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt.toUtc().toIso8601String(),
      };
}

/// Owns the in-memory + persisted auth session for the app.
///
/// State is `null` when signed out. On construction the caller should hydrate
/// the store from disk via [hydrate]; the bootstrap sequence does this before
/// the first frame.
class AuthSessionStore extends StateNotifier<AuthSessionTokens?> {
  /// Creates a store backed by [_prefs].
  AuthSessionStore(this._prefs) : super(null);

  final SharedPreferences _prefs;

  /// `shared_preferences` key holding the JSON-encoded token bundle.
  static const String prefsKey = 'pf.auth.tokens';

  /// Loads any previously persisted tokens into [state]. Safe to call once at
  /// bootstrap; tolerates corrupt/legacy data by clearing it.
  void hydrate() {
    final raw = _prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      state = AuthSessionTokens.fromJson(json);
    } catch (_) {
      // Corrupt payload — drop it so the user re-authenticates cleanly.
      _prefs.remove(prefsKey);
      state = null;
    }
  }

  /// Returns the current access token, or `null` when signed out.
  ///
  /// Wired into [DioFactory.create]'s `getAccessToken` callback.
  Future<String?> getAccessToken() async => state?.accessToken;

  /// Returns the current refresh token, or `null` when signed out.
  Future<String?> getRefreshToken() async => state?.refreshToken;

  /// Persists [tokens] in memory and on disk.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    final tokens = AuthSessionTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt.toUtc(),
    );
    state = tokens;
    await _prefs.setString(prefsKey, jsonEncode(tokens.toJson()));
  }

  /// Clears the session from memory and disk.
  Future<void> clear() async {
    state = null;
    await _prefs.remove(prefsKey);
  }
}
