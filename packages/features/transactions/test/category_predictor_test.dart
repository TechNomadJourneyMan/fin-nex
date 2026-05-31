import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:fnx_feat_transactions/transactions.dart';

import '_fakes.dart';

void main() {
  group('CategoryPredictor', () {
    final Ulid user = Ulid.now();
    final Ulid account = Ulid.now();
    final Ulid food = Ulid.now();
    final Ulid taxi = Ulid.now();

    test('returns most-frequent category in window', () {
      final DateTime now = DateTime.utc(2026, 5, 31, 12);
      final List<Transaction> txs = <Transaction>[
        for (int i = 0; i < 5; i++)
          makeTransaction(
            id: Ulid.now(),
            userId: user,
            accountId: account,
            categoryId: food,
            occurredAt: now.subtract(Duration(days: i)),
          ),
        makeTransaction(
          id: Ulid.now(),
          userId: user,
          accountId: account,
          categoryId: taxi,
          occurredAt: now.subtract(const Duration(days: 1)),
        ),
      ];
      final CategoryPredictor predictor = const CategoryPredictor();
      final Ulid? result = predictor.predict(
        transactions: txs,
        type: TransactionType.expense,
        now: now,
      );
      expect(result?.value, food.value);
    });

    test('ignores transactions outside window', () {
      final DateTime now = DateTime.utc(2026, 5, 31);
      final List<Transaction> txs = <Transaction>[
        makeTransaction(
          id: Ulid.now(),
          userId: user,
          accountId: account,
          categoryId: food,
          occurredAt: now.subtract(const Duration(days: 90)),
        ),
        makeTransaction(
          id: Ulid.now(),
          userId: user,
          accountId: account,
          categoryId: taxi,
          occurredAt: now.subtract(const Duration(days: 1)),
        ),
      ];
      final CategoryPredictor predictor = const CategoryPredictor();
      final Ulid? result = predictor.predict(
        transactions: txs,
        type: TransactionType.expense,
        now: now,
      );
      expect(result?.value, taxi.value);
    });

    test('returns null when empty', () {
      final CategoryPredictor predictor = const CategoryPredictor();
      expect(
        predictor.predict(
          transactions: const <Transaction>[],
          type: TransactionType.expense,
        ),
        isNull,
      );
    });

    test('predictAccount returns most-recent account', () {
      final DateTime now = DateTime.utc(2026, 5, 31);
      final Ulid acc2 = Ulid.now();
      final List<Transaction> txs = <Transaction>[
        makeTransaction(
          id: Ulid.now(),
          userId: user,
          accountId: account,
          categoryId: food,
          occurredAt: now.subtract(const Duration(days: 3)),
        ),
        makeTransaction(
          id: Ulid.now(),
          userId: user,
          accountId: acc2,
          categoryId: food,
          occurredAt: now.subtract(const Duration(hours: 1)),
        ),
      ];
      expect(
        const CategoryPredictor()
            .predictAccount(transactions: txs, type: TransactionType.expense)
            ?.value,
        acc2.value,
      );
    });
  });
}
