import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_feat_notifications/fnx_feat_notifications.dart';

void main() {
  group('NotificationsService.noop', () {
    test('init / show / cancel are non-throwing', () async {
      final svc = NotificationsService.noop();
      await svc.init();
      final granted = await svc.requestPermission();
      expect(granted, isTrue);
      await svc.show(
        const NotificationDisplay(
          id: 1,
          type: NotificationPreferenceType.dailyReminder,
          title: 'Test',
          body: 'Body',
        ),
      );
      await svc.schedule(
        const NotificationDisplay(
          id: 2,
          type: NotificationPreferenceType.insight,
          title: 'Future',
          body: 'Later',
        ),
        DateTime.now().add(const Duration(minutes: 5)),
      );
      await svc.cancel(1);
      await svc.cancelAll();
    });
  });
}
