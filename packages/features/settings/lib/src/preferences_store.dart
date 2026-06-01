// Tiny wrapper around `shared_preferences` so the rest of the feature can
// depend on a stable interface and tests can drop in an in-memory map.

import 'package:shared_preferences/shared_preferences.dart';

/// Read/write contract for the small settings blob we persist locally.
///
/// We deliberately keep this surface tiny — theme, locale, and a few
/// notification flags. Anything richer (per-user defaults, biometric
/// enrolment material) lives in the platform-secure stores.
abstract class PreferencesStore {
  /// Read a string value (defaulting to `null`).
  Future<String?> getString(String key);

  /// Write a string value. Removes the key when [value] is `null`.
  Future<void> setString(String key, String? value);

  /// Read a bool value (defaulting to `null`).
  Future<bool?> getBool(String key);

  /// Write a bool value.
  Future<void> setBool(String key, bool value);
}

/// Concrete implementation backed by `shared_preferences`.
class SharedPreferencesStore implements PreferencesStore {
  /// Default constructor.
  SharedPreferencesStore();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String?> getString(String key) async => (await _prefs).getString(key);

  @override
  Future<void> setString(String key, String? value) async {
    final prefs = await _prefs;
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }

  @override
  Future<bool?> getBool(String key) async => (await _prefs).getBool(key);

  @override
  Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }
}

/// In-memory store useful for tests.
class InMemoryPreferencesStore implements PreferencesStore {
  /// Default constructor.
  InMemoryPreferencesStore([Map<String, Object?>? seed])
      : _data = <String, Object?>{...?seed};

  final Map<String, Object?> _data;

  @override
  Future<String?> getString(String key) async => _data[key] as String?;

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<bool?> getBool(String key) async => _data[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    _data[key] = value;
  }
}

/// Canonical keys used in the preferences blob.
abstract final class PreferenceKeys {
  /// Active theme: `system` | `light` | `dark`.
  static const String theme = 'fnx.theme';

  /// Active locale: BCP-47 tag (`en`, `ru`, `kk`).
  static const String locale = 'fnx.locale';

  /// High-contrast accessibility theme enabled.
  static const String highContrast = 'pf_high_contrast';

  /// Daily reminder enabled.
  static const String dailyReminder = 'fnx.notif.daily';

  /// Weekly recap enabled.
  static const String weeklyRecap = 'fnx.notif.weekly';

  /// Limit warnings enabled.
  static const String limitWarnings = 'fnx.notif.limits';

  /// Insights notifications enabled.
  static const String insights = 'fnx.notif.insights';

  /// Biometric lock on app open.
  static const String biometric = 'fnx.privacy.biometric';

  /// Hide balances until auth.
  static const String hideBalances = 'fnx.privacy.hideBalances';
}
