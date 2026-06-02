import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_notifications/pf_feat_notifications.dart';

/// Records scheduling calls without touching any platform plugin.
class _FakeService implements NotificationsService {
  final List<int> cancelled = <int>[];
  final List<MapEntry<NotificationDisplay, DateTime>> scheduled =
      <MapEntry<NotificationDisplay, DateTime>>[];
  bool initialized = false;

  @override
  Future<void> init() async => initialized = true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> show(NotificationDisplay display) async {}

  @override
  Future<void> schedule(NotificationDisplay display, DateTime when) async {
    scheduled.add(MapEntry(display, when));
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<void> cancelAll() async {}
}

void main() {
  PaymentReminderInput input(String id, DateTime due) => PaymentReminderInput(
        sourceId: id,
        title: 'Netflix',
        amountLabel: '4990',
        dueDate: due,
      );

  test('sync cancels stale ids then schedules the fresh set', () async {
    final service = _FakeService();
    final sync = PaymentReminderSync(service: service);

    await sync.sync(
      [input('subscription:a', DateTime(2026, 6, 10))],
      now: DateTime(2026, 6, 1),
    );

    expect(service.initialized, isTrue);
    // Both reminder slots cancelled up front.
    expect(service.cancelled, hasLength(2));
    // Day-before + due-day scheduled.
    expect(service.scheduled, hasLength(2));
    expect(
      service.scheduled.map((e) => e.key.payload),
      everyElement('subscription:a'),
    );
  });

  test('disabled sync cancels but schedules nothing', () async {
    final service = _FakeService();
    final sync = PaymentReminderSync(service: service, enabled: false);

    await sync.sync(
      [input('subscription:a', DateTime(2026, 6, 10))],
      now: DateTime(2026, 6, 1),
    );

    expect(service.cancelled, isNotEmpty);
    expect(service.scheduled, isEmpty);
  });

  test('cancelFor cancels both slots per source', () async {
    final service = _FakeService();
    final sync = PaymentReminderSync(service: service);
    await sync.cancelFor(['subscription:a', 'subscription:b']);
    expect(service.cancelled, hasLength(4));
  });
}
