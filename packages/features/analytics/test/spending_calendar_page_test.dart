// Widget tests for [SpendingCalendarPage].
//
// Mounts the page with an overridden transactions repository seeded with a
// known month of expenses, then asserts:
//   * the grid renders one cell per day of the visible month, and
//   * tapping a populated day opens the day-detail bottom sheet listing that
//     day's transactions with the day total.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_theme/pf_core_theme.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_analytics/analytics.dart';

class _FakeTransactionsRepository implements TransactionsRepository {
  _FakeTransactionsRepository(this._rows);
  final List<Transaction> _rows;

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) async* {
    yield _rows
        .where((Transaction t) => t.deletedAt == null)
        .toList(growable: false);
  }

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async =>
      _rows;

  @override
  Future<Transaction?> getById(Ulid id) async => null;

  @override
  Future<void> upsert(Transaction tx) async {}

  @override
  Future<void> softDelete(Ulid id) async {}
}

Transaction _tx({
  required Ulid userId,
  required Ulid accountId,
  required int minor,
  required DateTime occurredAt,
}) {
  return Transaction(
    id: Ulid.now(),
    userId: userId,
    accountId: accountId,
    type: TransactionType.expense,
    amount: Money(BigInt.from(minor), Currency.kzt),
    categoryId: Ulid.now(),
    occurredAt: occurredAt,
    createdAt: occurredAt,
    updatedAt: occurredAt,
    source: 'manual',
    attachmentIds: const <Ulid>[],
    tagIds: const <Ulid>[],
  );
}

Widget _host(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: PfTheme.light(),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: PfLocales.all,
      home: const SpendingCalendarPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Ulid user = Ulid.now();
  final Ulid account = Ulid.now();

  // March 2026 has 31 days. Seed spend on the 3rd, 10th and 20th.
  final DateTime anchor = DateTime(2026, 3, 1);
  final List<Transaction> txs = <Transaction>[
    _tx(
      userId: user,
      accountId: account,
      minor: 250000,
      occurredAt: DateTime(2026, 3, 3, 9),
    ),
    _tx(
      userId: user,
      accountId: account,
      minor: 90000,
      occurredAt: DateTime(2026, 3, 3, 18),
    ),
    _tx(
      userId: user,
      accountId: account,
      minor: 1500000,
      occurredAt: DateTime(2026, 3, 10, 10),
    ),
    _tx(
      userId: user,
      accountId: account,
      minor: 40000,
      occurredAt: DateTime(2026, 3, 20, 12),
    ),
  ];

  List<Override> overrides() => <Override>[
        analyticsCurrentUserIdProvider.overrideWithValue(user),
        analyticsTransactionsRepositoryProvider
            .overrideWithValue(_FakeTransactionsRepository(txs)),
        analyticsDisplayCurrencyProvider.overrideWithValue(Currency.kzt),
        calendarMonthProvider.overrideWith((Ref ref) => anchor),
      ];

  testWidgets('renders one cell per day of the month', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(overrides()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SpendingCalendarPage), findsOneWidget);

    // Each day of March (1..31) renders a numbered cell. Assert a handful of
    // representative day numbers are present.
    for (final String label in <String>['1', '15', '31']) {
      expect(find.text(label), findsWidgets);
    }

    // The 32nd day must not exist (March has 31 days).
    expect(find.text('32'), findsNothing);
  });

  testWidgets('tapping a populated day opens the detail sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(overrides()));
    await tester.pumpAndSettle();

    // Day 3 has two expenses. Tapping its cell opens the bottom sheet.
    await tester.tap(find.text('3').first);
    await tester.pumpAndSettle();

    // The sheet lists the day's transactions via PfTransactionItem rows.
    expect(find.byType(PfTransactionItem), findsNWidgets(2));
  });

  testWidgets('tapping an empty day does not open the sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(overrides()));
    await tester.pumpAndSettle();

    // Day 5 has no spend — tapping is a no-op.
    await tester.tap(find.text('5').first);
    await tester.pumpAndSettle();

    expect(find.byType(PfTransactionItem), findsNothing);
  });
}
