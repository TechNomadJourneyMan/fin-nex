// Tests for the History page's filter state: the debounced
// TransactionFiltersNotifier and the derived filteredTransactionsProvider.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_transactions/transactions.dart';

import '_fakes.dart';

void main() {
  late FakeTransactionsRepository repo;
  late Ulid user;
  late Ulid account;
  late Ulid catFood;
  late Ulid catTaxi;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: <Override>[
        transactionsRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue(user),
        defaultCurrencyProvider.overrideWithValue(Currency.kzt),
      ],
    );
  }

  setUp(() async {
    user = Ulid.now();
    account = Ulid.now();
    catFood = Ulid.now();
    catTaxi = Ulid.now();
    repo = FakeTransactionsRepository();
    final DateTime now = DateTime.utc(2026, 5, 31, 12);
    await repo.upsert(
      makeTransaction(
        id: Ulid.now(),
        userId: user,
        accountId: account,
        categoryId: catFood,
        occurredAt: now.subtract(const Duration(days: 1)),
        description: 'Coffee at Starbucks',
      ),
    );
    await repo.upsert(
      makeTransaction(
        id: Ulid.now(),
        userId: user,
        accountId: account,
        categoryId: catTaxi,
        occurredAt: now.subtract(const Duration(days: 2)),
        description: 'Yandex ride',
      ),
    );
    await repo.upsert(
      makeTransaction(
        id: Ulid.now(),
        userId: user,
        accountId: account,
        categoryId: catFood,
        type: TransactionType.income,
        occurredAt: now.subtract(const Duration(days: 3)),
        description: 'Salary',
      ),
    );
  });

  tearDown(() async {
    await repo.dispose();
  });

  Future<List<Transaction>> readFiltered(ProviderContainer c) async {
    // Keep the underlying stream provider alive and wait for its first value.
    c.listen(filteredTransactionsProvider, (_, __) {});
    await c.read(transactionsStreamProvider.future);
    await Future<void>.delayed(Duration.zero);
    return c.read(filteredTransactionsProvider).valueOrNull ?? <Transaction>[];
  }

  test('no filter returns all live rows', () async {
    final ProviderContainer c = makeContainer();
    addTearDown(c.dispose);
    final List<Transaction> rows = await readFiltered(c);
    expect(rows.length, 3);
  });

  test('kind filter (expense) excludes income', () async {
    final ProviderContainer c = makeContainer();
    addTearDown(c.dispose);
    c.read(transactionFiltersProvider.notifier).setKind(TransactionType.expense);
    final List<Transaction> rows = await readFiltered(c);
    expect(rows.length, 2);
    expect(
      rows.every((Transaction t) => t.type == TransactionType.expense),
      isTrue,
    );
  });

  test('category filter restricts to selected categories', () async {
    final ProviderContainer c = makeContainer();
    addTearDown(c.dispose);
    c.read(transactionFiltersProvider.notifier).setCategoryIds(<Ulid>{catTaxi});
    final List<Transaction> rows = await readFiltered(c);
    expect(rows.length, 1);
    expect(rows.first.description, 'Yandex ride');
  });

  test('search query is debounced then applied', () async {
    final ProviderContainer c = makeContainer();
    addTearDown(c.dispose);
    c.read(transactionFiltersProvider.notifier).setQuery('coffee');

    // Immediately after typing, the query hasn't been committed yet.
    expect(c.read(transactionFiltersProvider).searchText, isNull);

    // After the debounce window elapses it applies.
    await Future<void>.delayed(
      TransactionFiltersNotifier.debounceWindow +
          const Duration(milliseconds: 50),
    );
    expect(c.read(transactionFiltersProvider).searchText, 'coffee');

    final List<Transaction> rows = await readFiltered(c);
    expect(rows.length, 1);
    expect(rows.first.description, 'Coffee at Starbucks');
  });

  test('blank query clears immediately (no debounce)', () async {
    final ProviderContainer c = makeContainer();
    addTearDown(c.dispose);
    c.read(transactionFiltersProvider.notifier).setQuery('coffee');
    await Future<void>.delayed(
      TransactionFiltersNotifier.debounceWindow +
          const Duration(milliseconds: 50),
    );
    expect(c.read(transactionFiltersProvider).searchText, 'coffee');

    c.read(transactionFiltersProvider.notifier).setQuery('   ');
    expect(c.read(transactionFiltersProvider).searchText, isNull);
  });

  test('date-range filter bounds the result set', () async {
    final ProviderContainer c = makeContainer();
    addTearDown(c.dispose);
    final DateTime now = DateTime.utc(2026, 5, 31, 12);
    c.read(transactionFiltersProvider.notifier).setDateRange(
          from: now.subtract(const Duration(days: 2, hours: 1)),
          to: now,
        );
    final List<Transaction> rows = await readFiltered(c);
    // Only the day-1 and day-2 expenses fall in range; the day-3 income is out.
    expect(rows.length, 2);
  });

  test('clear() resets every filter', () async {
    final ProviderContainer c = makeContainer();
    addTearDown(c.dispose);
    final TransactionFiltersNotifier n =
        c.read(transactionFiltersProvider.notifier);
    n
      ..setKind(TransactionType.expense)
      ..setCategoryIds(<Ulid>{catFood});
    n.clear();
    expect(c.read(transactionFiltersProvider).isEmpty, isTrue);
    final List<Transaction> rows = await readFiltered(c);
    expect(rows.length, 3);
  });
}
