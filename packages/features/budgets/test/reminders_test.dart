// Tests for budget → calendar reminder sync via the in-memory
// StubCalendarService. Verifies the "last 3 days" window, idempotent re-sync,
// and removal when disabled.

import 'package:flutter/material.dart' show DateTimeRange, Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pf_calendar/pf_calendar.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_domain/domain.dart';
import 'package:pf_feat_budgets/pf_feat_budgets.dart';

void main() {
  late AppL10n l10n;

  setUpAll(() async {
    await initializeDateFormatting('en');
    l10n = await AppL10n.delegate.load(const Locale('en'));
  });

  final userId = Ulid('00000000000000000000000SER');
  final budgetId = Ulid('00000000000000000000BDGET1');
  const calId = 'stub-primary';

  Budget mkBudget({DateTime? endsOn, bool isActive = true}) {
    final now = DateTime.utc(2026, 6, 1);
    return Budget(
      id: budgetId,
      userId: userId,
      name: 'Groceries',
      period: BudgetPeriod.monthly,
      amount: Money(BigInt.from(5000000), Currency.kzt),
      startsOn: now,
      endsOn: endsOn,
      alertThresholds: const <int>[80, 100],
      rolloverUnspent: false,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
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

  BudgetRemindersSync sync(
          {required bool enabled, String? calendarId = calId}) =>
      BudgetRemindersSync(
        reminderService: reminderService,
        calendarId: calendarId,
        enabled: enabled,
        l10n: l10n,
      );

  test('isBudgetEnding: true within 3 days, false otherwise', () {
    final now = DateTime(2026, 6, 28);
    expect(
      isBudgetEnding(mkBudget(endsOn: DateTime(2026, 6, 30)), now: now),
      isTrue,
    );
    expect(
      isBudgetEnding(mkBudget(endsOn: DateTime(2026, 7, 15)), now: now),
      isFalse,
    );
    expect(isBudgetEnding(mkBudget(), now: now), isFalse); // no end date
  });

  test('ending + enabled → exactly one event', () async {
    final endsOn = DateTime.now().add(const Duration(days: 2));
    await sync(enabled: true).sync(mkBudget(endsOn: endsOn));

    final events = await stub.eventsInRange(calId, wideRange());
    expect(events, hasLength(1));
    expect(events.single.title, contains('Groceries'));
    expect(events.single.sourceId, 'budget:${budgetId.value}');
  });

  test('re-sync is idempotent', () async {
    final endsOn = DateTime.now().add(const Duration(days: 2));
    final b = mkBudget(endsOn: endsOn);
    await sync(enabled: true).sync(b);
    await sync(enabled: true).sync(b);
    await sync(enabled: true).sync(b);
    expect(await stub.eventsInRange(calId, wideRange()), hasLength(1));
  });

  test('disabled removes any existing event', () async {
    final endsOn = DateTime.now().add(const Duration(days: 2));
    final b = mkBudget(endsOn: endsOn);
    await sync(enabled: true).sync(b);
    expect(await stub.eventsInRange(calId, wideRange()), hasLength(1));

    await sync(enabled: false).sync(b);
    expect(await stub.eventsInRange(calId, wideRange()), isEmpty);
  });

  test('not ending → no event even when enabled', () async {
    final endsOn = DateTime.now().add(const Duration(days: 30));
    await sync(enabled: true).sync(mkBudget(endsOn: endsOn));
    expect(await stub.eventsInRange(calId, wideRange()), isEmpty);
  });
}
