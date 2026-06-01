// Notification preferences — bundled here so the Settings → Notifications
// page can render and toggle them with a single notifier.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences_store.dart';

/// Immutable bag of notification toggles.
class NotificationPrefs {
  /// Default constructor.
  const NotificationPrefs({
    required this.dailyReminder,
    required this.weeklyRecap,
    required this.limitWarnings,
    required this.insights,
  });

  /// Daily "log today's expenses" reminder.
  final bool dailyReminder;

  /// Weekly summary recap.
  final bool weeklyRecap;

  /// Push when nearing or exceeding a category limit.
  final bool limitWarnings;

  /// Smart insight notifications.
  final bool insights;

  /// All four flags toggled to their startup defaults.
  static const NotificationPrefs defaults = NotificationPrefs(
    dailyReminder: true,
    weeklyRecap: true,
    limitWarnings: true,
    insights: false,
  );

  /// Returns a copy with the given fields replaced.
  NotificationPrefs copyWith({
    bool? dailyReminder,
    bool? weeklyRecap,
    bool? limitWarnings,
    bool? insights,
  }) =>
      NotificationPrefs(
        dailyReminder: dailyReminder ?? this.dailyReminder,
        weeklyRecap: weeklyRecap ?? this.weeklyRecap,
        limitWarnings: limitWarnings ?? this.limitWarnings,
        insights: insights ?? this.insights,
      );
}

/// StateNotifier owning [NotificationPrefs] and persisting individual flags.
class NotificationPrefsController extends StateNotifier<NotificationPrefs> {
  /// Default constructor. Hydrates from the [PreferencesStore].
  NotificationPrefsController(this._store) : super(NotificationPrefs.defaults) {
    _hydrate();
  }

  final PreferencesStore _store;

  Future<void> _hydrate() async {
    final daily = await _store.getBool(PreferenceKeys.dailyReminder);
    final weekly = await _store.getBool(PreferenceKeys.weeklyRecap);
    final limits = await _store.getBool(PreferenceKeys.limitWarnings);
    final insights = await _store.getBool(PreferenceKeys.insights);
    state = state.copyWith(
      dailyReminder: daily ?? state.dailyReminder,
      weeklyRecap: weekly ?? state.weeklyRecap,
      limitWarnings: limits ?? state.limitWarnings,
      insights: insights ?? state.insights,
    );
  }

  /// Toggle the daily reminder.
  Future<void> setDailyReminder(bool value) async {
    state = state.copyWith(dailyReminder: value);
    await _store.setBool(PreferenceKeys.dailyReminder, value);
  }

  /// Toggle the weekly recap.
  Future<void> setWeeklyRecap(bool value) async {
    state = state.copyWith(weeklyRecap: value);
    await _store.setBool(PreferenceKeys.weeklyRecap, value);
  }

  /// Toggle limit warnings.
  Future<void> setLimitWarnings(bool value) async {
    state = state.copyWith(limitWarnings: value);
    await _store.setBool(PreferenceKeys.limitWarnings, value);
  }

  /// Toggle insight notifications.
  Future<void> setInsights(bool value) async {
    state = state.copyWith(insights: value);
    await _store.setBool(PreferenceKeys.insights, value);
  }
}
