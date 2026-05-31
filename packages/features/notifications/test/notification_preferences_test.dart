import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_feat_notifications/fnx_feat_notifications.dart';

void main() {
  group('NotificationPreferences', () {
    test('defaults enables every type', () {
      final prefs = NotificationPreferences.defaults();
      for (final t in NotificationPreferenceType.values) {
        expect(prefs.isEnabled(t), isTrue, reason: t.key);
      }
    });

    test('setEnabled returns a copy with the type flipped', () {
      final prefs = NotificationPreferences.defaults();
      final next = prefs.setEnabled(
        NotificationPreferenceType.dailyReminder,
        false,
      );
      expect(prefs.isEnabled(NotificationPreferenceType.dailyReminder), isTrue);
      expect(next.isEnabled(NotificationPreferenceType.dailyReminder), isFalse);
      expect(next.isEnabled(NotificationPreferenceType.insight), isTrue);
    });

    test('round-trips through JSON', () {
      final prefs = NotificationPreferences.defaults()
          .setEnabled(NotificationPreferenceType.syncError, false)
          .setEnabled(NotificationPreferenceType.weeklyRecap, false);
      final restored = NotificationPreferences.fromJson(prefs.toJson());
      expect(restored, prefs);
    });

    test('parse round-trips with key', () {
      for (final t in NotificationPreferenceType.values) {
        expect(NotificationPreferenceType.parse(t.key), t);
      }
    });
  });
}
