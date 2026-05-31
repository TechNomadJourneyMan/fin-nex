// Thin facade that exposes the four sub-controllers as a single object so
// the settings pages can `ref.read(settingsControllerProvider)` and call
// e.g. `controller.setTheme(...)` without juggling four notifiers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Facade exposing the most common settings mutations.
class SettingsController {
  /// Default constructor.
  SettingsController(this._ref);

  final Ref _ref;

  /// Persist the new [ThemeMode].
  Future<void> setTheme(ThemeMode mode) =>
      _ref.read(themeProvider.notifier).set(mode);

  /// Persist the new locale (or `null` to follow the system).
  Future<void> setLocale(Locale? locale) =>
      _ref.read(localeProvider.notifier).set(locale);

  /// Toggle a specific notification preference by [key].
  Future<void> setNotificationFlag(String key, bool value) {
    final ctl = _ref.read(notificationPrefsProvider.notifier);
    switch (key) {
      case 'daily':
        return ctl.setDailyReminder(value);
      case 'weekly':
        return ctl.setWeeklyRecap(value);
      case 'limits':
        return ctl.setLimitWarnings(value);
      case 'insights':
        return ctl.setInsights(value);
    }
    throw ArgumentError.value(key, 'key', 'Unknown notification flag');
  }

  /// Toggle the biometric lock flag.
  Future<void> setBiometric(bool value) =>
      _ref.read(privacyProvider.notifier).setBiometric(value);

  /// Toggle the hide-balances flag.
  Future<void> setHideBalances(bool value) =>
      _ref.read(privacyProvider.notifier).setHideBalances(value);
}
