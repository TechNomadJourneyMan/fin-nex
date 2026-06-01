import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_transactions/transactions.dart';

import '_fakes.dart';

void main() {
  group('TransactionsController.applyFilter', () {
    final Ulid user = Ulid.now();
    final Ulid acc1 = Ulid.now();
    final Ulid acc2 = Ulid.now();
    final Ulid catFood = Ulid.now();
    final Ulid catTaxi = Ulid.now();

    final DateTime now = DateTime.utc(2026, 5, 31, 12);
    final List<Transaction> txs = <Transaction>[
      makeTransaction(
        id: Ulid.now(),
        userId: user,
        accountId: acc1,
        categoryId: catFood,
        occurredAt: now.subtract(const Duration(days: 1)),
        description: 'Coffee',
      ),
      makeTransaction(
        id: Ulid.now(),
        userId: user,
        accountId: acc2,
        categoryId: catTaxi,
        occurredAt: now.subtract(const Duration(days: 10)),
        description: 'Yandex ride',
      ),
      makeTransaction(
        id: Ulid.now(),
        userId: user,
        accountId: acc1,
        categoryId: catFood,
        type: TransactionType.income,
        occurredAt: now.subtract(const Duration(days: 2)),
        description: null,
      ),
      makeTransaction(
        id: Ulid.now(),
        userId: user,
        accountId: acc1,
        categoryId: catFood,
        occurredAt: now,
        deletedAt: now,
      ),
    ];

    test('strips soft-deleted rows', () {
      final List<Transaction> result =
          TransactionsController.applyFilter(txs, const TransactionFilterState());
      expect(result.length, 3);
      expect(result.every((Transaction t) => t.deletedAt == null), isTrue);
    });

    test('filters by category', () {
      final List<Transaction> result = TransactionsController.applyFilter(
        txs,
        TransactionFilterState(categoryIds: <Ulid>[catTaxi]),
      );
      expect(result.length, 1);
      expect(result.first.description, 'Yandex ride');
    });

    test('filters by account', () {
      final List<Transaction> result = TransactionsController.applyFilter(
        txs,
        TransactionFilterState(accountIds: <Ulid>[acc2]),
      );
      expect(result.length, 1);
      expect(result.first.accountId.value, acc2.value);
    });

    test('filters by type', () {
      final List<Transaction> result = TransactionsController.applyFilter(
        txs,
        const TransactionFilterState(types: <TransactionType>[TransactionType.income]),
      );
      expect(result.length, 1);
      expect(result.first.type, TransactionType.income);
    });

    test('filters by date range', () {
      final List<Transaction> result = TransactionsController.applyFilter(
        txs,
        TransactionFilterState(
          from: now.subtract(const Duration(days: 3)),
          to: now.add(const Duration(seconds: 1)),
        ),
      );
      expect(result.length, 2);
    });

    test('filters by search text (case-insensitive)', () {
      final List<Transaction> result = TransactionsController.applyFilter(
        txs,
        const TransactionFilterState(searchText: 'COFFEE'),
      );
      expect(result.length, 1);
      expect(result.first.description, 'Coffee');
    });

    test('returns rows sorted newest-first', () {
      final List<Transaction> result =
          TransactionsController.applyFilter(txs, const TransactionFilterState());
      for (int i = 0; i < result.length - 1; i++) {
        expect(
          result[i].occurredAt.isAfter(result[i + 1].occurredAt) ||
              result[i].occurredAt.isAtSameMomentAs(result[i + 1].occurredAt),
          isTrue,
        );
      }
    });
  });

  group('TransactionFilterState', () {
    test('isEmpty is true for default ctor', () {
      expect(const TransactionFilterState().isEmpty, isTrue);
    });

    test('copyWith with clearFrom drops the bound', () {
      final TransactionFilterState s = TransactionFilterState(
        from: DateTime.utc(2026, 1, 1),
      );
      expect(s.copyWith(clearFrom: true).from, isNull);
    });
  });
}
