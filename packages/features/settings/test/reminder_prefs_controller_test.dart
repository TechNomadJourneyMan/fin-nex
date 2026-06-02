// Verifies the reminder toggle defaults and SharedPreferences persistence.

import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_settings/settings.dart';

void main() {
  group('ReminderPrefsController', () {
    test('defaults: subscriptions ON when calendar connected, budgets OFF',
        () async {
      final store = InMemoryPreferencesStore();
      final ctrl = ReminderPrefsController(store, calendarConnected: true);
      // Allow the async _load() to complete.
      await Future<void>.delayed(Duration.zero);
      expect(ctrl.state.loaded, isTrue);
      expect(ctrl.state.subscriptions, isTrue);
      expect(ctrl.state.budgets, isFalse);
    });

    test('defaults: subscriptions OFF when no calendar connected', () async {
      final store = InMemoryPreferencesStore();
      final ctrl = ReminderPrefsController(store, calendarConnected: false);
      await Future<void>.delayed(Duration.zero);
      expect(ctrl.state.subscriptions, isFalse);
    });

    test('persisted values win over the default', () async {
      final store = InMemoryPreferencesStore(<String, Object?>{
        kSubscriptionRemindersKey: false,
        kBudgetRemindersKey: true,
      });
      final ctrl = ReminderPrefsController(store, calendarConnected: true);
      await Future<void>.delayed(Duration.zero);
      expect(ctrl.state.subscriptions, isFalse);
      expect(ctrl.state.budgets, isTrue);
    });

    test('setters persist to the store', () async {
      final store = InMemoryPreferencesStore();
      final ctrl = ReminderPrefsController(store, calendarConnected: false);
      await Future<void>.delayed(Duration.zero);

      await ctrl.setSubscriptions(true);
      await ctrl.setBudgets(true);

      expect(await store.getBool(kSubscriptionRemindersKey), isTrue);
      expect(await store.getBool(kBudgetRemindersKey), isTrue);
      expect(ctrl.state.subscriptions, isTrue);
      expect(ctrl.state.budgets, isTrue);
    });
  });
}
