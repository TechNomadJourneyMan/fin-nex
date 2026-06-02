// Riverpod providers for the PocketFlow settings feature.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_calendar/pf_calendar.dart';

import 'controllers/calendar_controller.dart';
import 'controllers/high_contrast_controller.dart';
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
final themeProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController(ref.watch(preferencesStoreProvider));
});

/// Active locale. `null` means "follow the system".
final localeProvider = StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(ref.watch(preferencesStoreProvider));
});

/// Whether the high-contrast accessibility theme is enabled. Persists on
/// every change under the `pf_high_contrast` key.
final highContrastProvider =
    StateNotifierProvider<HighContrastController, bool>((ref) {
  return HighContrastController(ref.watch(preferencesStoreProvider));
});

/// Notification preferences (daily, weekly, limits, insights).
final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsController, NotificationPrefs>(
        (ref) {
  return NotificationPrefsController(ref.watch(preferencesStoreProvider));
});

/// Privacy / security preferences.
final privacyProvider =
    StateNotifierProvider<PrivacyController, PrivacyPrefs>((ref) {
  return PrivacyController(ref.watch(preferencesStoreProvider));
});

/// Drives the "Connect calendar" flow. Reads the platform [CalendarService]
/// from [calendarServiceProvider] (defaults to the in-memory stub; the app
/// overrides it at the root with the device / Google backend).
final calendarControllerProvider =
    StateNotifierProvider<CalendarController, CalendarConnectState>((ref) {
  return CalendarController(
    ref.watch(calendarServiceProvider),
    ref.watch(preferencesStoreProvider),
  );
});

/// The top-level [SettingsController] composed from the smaller providers.
final settingsControllerProvider = Provider<SettingsController>((ref) {
  return SettingsController(ref);
});
