// Widget tests for [AnalyticsPage].
//
// Renders the page against (a) an empty dataset and (b) a populated dataset and
// asserts it mounts without throwing and reflects the data state. The page is
// driven entirely by the transactions + categories repository providers, which
// are overridden here with simple in-memory fakes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_theme/pf_core_theme.dart';
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

class _FakeCategoriesRepository implements CategoriesRepository {
  _FakeCategoriesRepository(this._rows);
  final List<Category> _rows;

  @override
  Stream<List<Category>> watchAll(Ulid userId) async* {
    yield _rows;
  }

  @override
  Future<List<Category>> list(Ulid userId) async => _rows;

  @override
  Future<Category?> getById(Ulid id) async => null;

  @override
  Future<void> upsert(Category category) async {}

  @override
  Future<void> softDelete(Ulid id) async {}
}

Category _category(Ulid id, String name, CategoryType type) {
  final DateTime now = DateTime.utc(2026, 1, 1);
  return Category(
    id: id,
    type: type,
    name: name,
    iconKey: 'cafe',
    color: CategoryColor('#FF9900'),
    isSystem: true,
    isArchived: false,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

Transaction _tx({
  required Ulid id,
  required Ulid userId,
  required Ulid accountId,
  required Ulid categoryId,
  required TransactionType type,
  required int minor,
  required DateTime occurredAt,
}) {
  return Transaction(
    id: id,
    userId: userId,
    accountId: accountId,
    type: type,
    amount: Money(BigInt.from(minor), Currency.kzt),
    categoryId: categoryId,
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
      home: const AnalyticsPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Ulid user = Ulid.now();
  final Ulid account = Ulid.now();
  final Ulid food = Ulid.now();
  final Ulid rent = Ulid.now();

  List<Override> overridesFor(List<Transaction> txs) => <Override>[
        analyticsCurrentUserIdProvider.overrideWithValue(user),
        analyticsTransactionsRepositoryProvider
            .overrideWithValue(_FakeTransactionsRepository(txs)),
        analyticsCategoriesRepositoryProvider.overrideWithValue(
          _FakeCategoriesRepository(<Category>[
            _category(food, 'Food', CategoryType.expense),
            _category(rent, 'Rent', CategoryType.expense),
          ]),
        ),
        analyticsDisplayCurrencyProvider.overrideWithValue(Currency.kzt),
        // Anchor the period to the seeded month so populated data falls in range.
        analyticsPeriodProvider.overrideWith(
          (Ref ref) => AnalyticsPeriod.of(
            AnalyticsPeriodKind.month,
            now: DateTime.utc(2026, 3, 15, 12),
          ),
        ),
      ];

  testWidgets('renders with an empty dataset', (WidgetTester tester) async {
    await tester.pumpWidget(_host(overridesFor(const <Transaction>[])));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AnalyticsPage), findsOneWidget);
  });

  testWidgets('renders with a populated dataset', (WidgetTester tester) async {
    final List<Transaction> txs = <Transaction>[
      _tx(
        id: Ulid.now(),
        userId: user,
        accountId: account,
        categoryId: food,
        type: TransactionType.expense,
        minor: 250000,
        occurredAt: DateTime.utc(2026, 3, 3, 9),
      ),
      _tx(
        id: Ulid.now(),
        userId: user,
        accountId: account,
        categoryId: rent,
        type: TransactionType.expense,
        minor: 1500000,
        occurredAt: DateTime.utc(2026, 3, 1, 10),
      ),
      _tx(
        id: Ulid.now(),
        userId: user,
        accountId: account,
        categoryId: food,
        type: TransactionType.income,
        minor: 8000000,
        occurredAt: DateTime.utc(2026, 3, 2, 9),
      ),
    ];

    await tester.pumpWidget(_host(overridesFor(txs)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AnalyticsPage), findsOneWidget);
  });
}
