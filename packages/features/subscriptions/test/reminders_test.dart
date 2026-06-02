// Tests for subscription → calendar reminder sync, driven by the in-memory
// StubCalendarService. Verifies: reminders ON produces exactly one event,
// toggling OFF removes it, and re-sync is idempotent.

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_calendar/pf_calendar.dart';
import 'package:pf_domain/domain.dart';
import 'package:pf_feat_subscriptions/pf_feat_subscriptions.dart';

void main() {
  final userId = Ulid('00000000000000000000000SER');
  final netflixId = Ulid('0000000000000000000NETFXAA');
  const calId = 'stub-primary';

  DetectedSubscription mkSub({String? calendarEventId}) {
    final now = DateTime.utc(2026, 5, 31);
    return DetectedSubscription(
      id: netflixId,
      userId: userId,
      merchantName: 'Netflix',
      amount: Money(BigInt.from(199000), Currency.kzt),
      period: BillingPeriod.monthly,
      nextBillingDate: DateTime.now().add(const Duration(days: 5)),
      createdAt: now,
      updatedAt: now,
      calendarEventId: calendarEventId,
    );
  }

  DateTimeRange wideRange() => DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 365)),
        end: DateTime.now().add(const Duration(days: 365)),
      );

  late StubCalendarService stub;
  late PfReminderService reminderService;

  setUp(() async {
    stub = StubCalendarService();
    await stub.requestPermission();
    reminderService = PfReminderService(stub);
  });

  SubscriptionRemindersSync sync(
    DetectedSubscriptionsRepository repo, {
    required bool enabled,
    String? calendarId = calId,
  }) =>
      SubscriptionRemindersSync(
        reminderService: reminderService,
        repository: repo,
        calendarId: calendarId,
        enabled: enabled,
      );

  test('reminders ON → exactly one event, id stored on the record', () async {
    final repo = InMemoryDetectedSubscriptionsRepository([mkSub()]);
    final sub = (await repo.getById(netflixId))!;

    await sync(repo, enabled: true).sync(sub);

    final events = await stub.eventsInRange(calId, wideRange());
    expect(events, hasLength(1));
    expect(events.single.title, startsWith('Netflix'));
    expect(events.single.sourceId, 'subscription:${netflixId.value}');

    final stored = await repo.getById(netflixId);
    expect(stored!.calendarEventId, events.single.id);
  });

  test('re-sync is idempotent (single event, no duplicates)', () async {
    final repo = InMemoryDetectedSubscriptionsRepository([mkSub()]);

    for (var i = 0; i < 3; i++) {
      final sub = (await repo.getById(netflixId))!;
      await sync(repo, enabled: true).sync(sub);
    }

    final events = await stub.eventsInRange(calId, wideRange());
    expect(events, hasLength(1));
  });

  test('toggling OFF removes the event and clears the stored id', () async {
    final repo = InMemoryDetectedSubscriptionsRepository([mkSub()]);

    // ON first.
    await sync(repo, enabled: true).sync((await repo.getById(netflixId))!);
    expect(await stub.eventsInRange(calId, wideRange()), hasLength(1));

    // Now OFF.
    await sync(repo, enabled: false).sync((await repo.getById(netflixId))!);

    expect(await stub.eventsInRange(calId, wideRange()), isEmpty);
    final stored = await repo.getById(netflixId);
    expect(stored!.calendarEventId, isNull);
  });

  test('no calendar connected → no event created', () async {
    final repo = InMemoryDetectedSubscriptionsRepository([mkSub()]);
    await sync(repo, enabled: true, calendarId: null)
        .sync((await repo.getById(netflixId))!);
    expect(await stub.eventsInRange(calId, wideRange()), isEmpty);
  });

  test('cancelled subscription has no reminder even when ON', () async {
    final cancelled = mkSub().copyWith(cancelledAt: DateTime.now().toUtc());
    final repo = InMemoryDetectedSubscriptionsRepository([cancelled]);
    await sync(repo, enabled: true).sync(cancelled);
    expect(await stub.eventsInRange(calId, wideRange()), isEmpty);
  });
}
