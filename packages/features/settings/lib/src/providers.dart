// Riverpod providers for the PocketFlow settings feature.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/locale_controller.dart';
import 'controllers/notification_prefs_controller.dart';
import 'controllers/privacy_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/theme_controller.dart';
import 'preferences_store.dart';

/// Provides the [PreferencesStore] used by the settings feature.
///
/// Override in tests with [InMemoryPreferencesStore].
final preferencesStoreProvider = Provider<PreferencesStore>((ref) {
  return SharedPreferencesStore();
});

/// Active theme mode. Persists on every change.
final themeProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController(ref.watch(preferencesStoreProvider));
});

/// Active locale. `null` means "follow the system".
final localeProvider =
    StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(ref.watch(preferencesStoreProvider));
});

/// Notification preferences (daily, weekly, limits, insights).
final notificationPrefsProvider = StateNotifierProvider<
    NotificationPrefsController, NotificationPrefs>((ref) {
  return NotificationPrefsController(ref.watch(preferencesStoreProvider));
});

/// Privacy / security preferences.
final privacyProvider =
    StateNotifierProvider<PrivacyController, PrivacyPrefs>((ref) {
  return PrivacyController(ref.watch(preferencesStoreProvider));
});

/// The top-level [SettingsController] composed from the smaller providers.
final settingsControllerProvider =
    Provider<SettingsController>((ref) {
  return SettingsController(ref);
});
