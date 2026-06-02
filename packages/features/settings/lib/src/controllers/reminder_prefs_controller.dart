import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences_store.dart';

/// SharedPreferences key for the "subscription reminders" toggle. Matches the
/// key the subscriptions feature reads (`pf_reminders_subscriptions`).
const String kSubscriptionRemindersKey = 'pf_reminders_subscriptions';

/// SharedPreferences key for the "budget reminders" toggle. Matches the key
/// the budgets feature reads (`pf_reminders_budgets`).
const String kBudgetRemindersKey = 'pf_reminders_budgets';

/// Toggle state for calendar reminder generation.
class ReminderPrefs {
  /// Creates a prefs snapshot.
  const ReminderPrefs({
    this.subscriptions = false,
    this.budgets = false,
    this.loaded = false,
  });

  /// Whether subscription due-date reminders are written to the calendar.
  ///
  /// Defaults to ON once a calendar is connected (handled at load time), OFF
  /// otherwise.
  final bool subscriptions;

  /// Whether budget end-of-period reminders are written to the calendar.
  /// Defaults to OFF.
  final bool budgets;

  /// Whether the persisted values have been read yet.
  final bool loaded;

  /// Returns a copy with the given fields replaced.
  ReminderPrefs copyWith({bool? subscriptions, bool? budgets, bool? loaded}) {
    return ReminderPrefs(
      subscriptions: subscriptions ?? this.subscriptions,
      budgets: budgets ?? this.budgets,
      loaded: loaded ?? this.loaded,
    );
  }
}

/// Persists the two reminder toggles in [PreferencesStore].
///
/// The subscription toggle defaults to ON when [calendarConnected] and no
/// value has been stored yet; the budget toggle defaults to OFF.
class ReminderPrefsController extends StateNotifier<ReminderPrefs> {
  /// Creates the controller and loads persisted values.
  ReminderPrefsController(this._store, {required bool calendarConnected})
      : _calendarConnected = calendarConnected,
        super(const ReminderPrefs()) {
    // ignore: discarded_futures
    _load();
  }

  final PreferencesStore _store;
  final bool _calendarConnected;

  Future<void> _load() async {
    final subs = await _store.getBool(kSubscriptionRemindersKey);
    final budgets = await _store.getBool(kBudgetRemindersKey);
    state = state.copyWith(
      subscriptions: subs ?? _calendarConnected,
      budgets: budgets ?? false,
      loaded: true,
    );
  }

  /// Sets the subscription-reminders toggle and persists it.
  Future<void> setSubscriptions(bool value) async {
    state = state.copyWith(subscriptions: value);
    await _store.setBool(kSubscriptionRemindersKey, value);
  }

  /// Sets the budget-reminders toggle and persists it.
  Future<void> setBudgets(bool value) async {
    state = state.copyWith(budgets: value);
    await _store.setBool(kBudgetRemindersKey, value);
  }
}
