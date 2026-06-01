// Tests for the budget calculator — verifies period windowing and the
// spend totals it computes from a list of transactions.

import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/domain.dart';

import 'package:pf_feat_budgets/pf_feat_budgets.dart';

void main() {
  group('BudgetCalculator', () {
    final calc = const BudgetCalculator();
    final userId = Ulid('00000000000000000000000000');
    final accountId = Ulid('00000000000000000000ACCT01');
    final foodCat = Ulid('00000000000000000000CATF01');
    final taxiCat = Ulid('00000000000000000000CATT01');

    Budget mkBudget({
      List<Ulid> cats = const <Ulid>[],
      int limitMinor = 100000,
      BudgetPeriod period = BudgetPeriod.monthly,
      List<int> thresholds = const <int>[50, 80, 100],
    }) {
      final now = DateTime.now().toUtc();
      return Budget(
        id: Ulid('00000000000000000000BUDG01'),
        userId: userId,
        name: 'Test',
        period: period,
        amount: Money(BigInt.from(limitMinor), Currency.kzt),
        categoryIds: cats,
        alertThresholds: thresholds,
        rolloverUnspent: false,
        isActive: true,
        startsOn: now,
        createdAt: now,
        updatedAt: now,
      );
    }

    Transaction mkTx({
      required int minor,
      required DateTime at,
      Ulid? categoryId,
      TransactionType type = TransactionType.expense,
      bool deleted = false,
    }) {
      final now = DateTime.now().toUtc();
      return Transaction(
        id: Ulid.now(),
        userId: userId,
        accountId: accountId,
        type: type,
        amount: Money(BigInt.from(minor), Currency.kzt),
        categoryId: categoryId,
        occurredAt: at,
        createdAt: now,
        updatedAt: now,
        source: 'manual',
        attachmentIds: const <Ulid>[],
        tagIds: const <Ulid>[],
        deletedAt: deleted ? now : null,
      );
    }

    test('monthly window is current calendar month', () {
      final budget = mkBudget();
      final now = DateTime(2026, 5, 15, 10);
      final w = calc.periodWindow(budget, now);
      expect(w.start, DateTime(2026, 5, 1));
      expect(w.end, DateTime(2026, 6, 1));
    });

    test('weekly window is Mon–Sun ISO week', () {
      final budget = mkBudget(period: BudgetPeriod.weekly);
      // 2026-05-15 is a Friday.
      final now = DateTime(2026, 5, 15);
      final w = calc.periodWindow(budget, now);
      expect(w.start.weekday, DateTime.monday);
      expect(w.end.difference(w.start), const Duration(days: 7));
    });

    test('sums expense transactions in window, skips others', () {
      final budget = mkBudget(cats: <Ulid>[foodCat]);
      final inWindow = DateTime(2026, 5, 10);
      final outOfWindow = DateTime(2026, 4, 28);

      final txs = <Transaction>[
        mkTx(minor: 5000, at: inWindow, categoryId: foodCat),
        mkTx(minor: 7500, at: inWindow, categoryId: foodCat),
        // Wrong category — excluded.
        mkTx(minor: 9000, at: inWindow, categoryId: taxiCat),
        // Outside window — excluded.
        mkTx(minor: 4000, at: outOfWindow, categoryId: foodCat),
        // Income — excluded.
        mkTx(
          minor: 20000,
          at: inWindow,
          categoryId: foodCat,
          type: TransactionType.income,
        ),
        // Deleted — excluded.
        mkTx(
          minor: 8000,
          at: inWindow,
          categoryId: foodCat,
          deleted: true,
        ),
      ];

      final spent = calc.spent(budget, txs, now: DateTime(2026, 5, 20));
      expect(spent.minor.toInt(), 12500);
    });

    test('hitThreshold returns highest threshold reached', () {
      final budget = mkBudget(limitMinor: 10000);
      final at = DateTime(2026, 5, 10);
      final txs = <Transaction>[
        mkTx(minor: 8500, at: at),
      ];
      expect(calc.hitThreshold(budget, txs, now: DateTime(2026, 5, 11)), 80);
    });

    test('hitThreshold null when below first threshold', () {
      final budget = mkBudget(limitMinor: 10000);
      final at = DateTime(2026, 5, 10);
      final txs = <Transaction>[
        mkTx(minor: 2000, at: at),
      ];
      expect(calc.hitThreshold(budget, txs, now: DateTime(2026, 5, 11)),
          isNull);
    });

    test('ratio is zero for zero-cap budget', () {
      final budget = mkBudget(limitMinor: 0);
      expect(
        calc.ratio(budget, const <Transaction>[],
            now: DateTime(2026, 5, 11)),
        0.0,
      );
    });
  });
}
