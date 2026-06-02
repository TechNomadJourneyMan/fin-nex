import 'package:pf_domain/domain.dart';
import 'package:test/test.dart';

import '../_fixtures.dart';

/// Minimal in-memory transactions repo for engine tests.
class _MemTxRepo implements TransactionsRepository {
  final Map<String, Transaction> _store = <String, Transaction>{};

  List<Transaction> get all => _store.values.toList(growable: false);

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async =>
      _store.values
          .where((Transaction t) => t.userId == userId && t.deletedAt == null)
          .toList(growable: false);

  @override
  Future<Transaction?> getById(Ulid id) async => _store[id.value];

  @override
  Future<void> upsert(Transaction tx) async => _store[tx.id.value] = tx;

  @override
  Future<void> softDelete(Ulid id) async {
    final Transaction? t = _store[id.value];
    if (t != null) {
      _store[id.value] = t.copyWith(deletedAt: DateTime.now().toUtc());
    }
  }

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) =>
      Stream<List<Transaction>>.value(all);
}

/// Minimal in-memory recurring-rules repo for engine tests.
class _MemRuleRepo implements RecurringRulesRepository {
  final Map<String, RecurringRule> _store = <String, RecurringRule>{};

  @override
  Future<void> delete(Ulid id) async => _store.remove(id.value);

  @override
  Future<RecurringRule?> getById(Ulid id) async => _store[id.value];

  @override
  Future<List<RecurringRule>> list(Ulid userId) async => _store.values
      .where((RecurringRule r) => r.userId == userId)
      .toList(growable: false);

  @override
  Future<void> upsert(RecurringRule rule) async =>
      _store[rule.id.value] = rule;

  @override
  Stream<List<RecurringRule>> watchAll(Ulid userId) =>
      Stream<List<RecurringRule>>.value(_store.values.toList());
}

RecurringRule _monthlyRule({required DateTime nextRunAt}) => RecurringRule(
      id: Fixtures.categoryId, // any stable ulid is fine here
      userId: Fixtures.userId,
      accountId: Fixtures.accountId,
      type: TransactionType.expense,
      amount: Fixtures.kzt(1500),
      categoryId: Fixtures.categoryId,
      description: 'Rent',
      cadence: RecurrenceCadence.monthly,
      interval: 1,
      nextRunAt: nextRunAt,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  group('RecurringEngine (monthly rule)', () {
    late _MemTxRepo txRepo;
    late _MemRuleRepo ruleRepo;
    late RecurringEngine engine;

    setUp(() {
      txRepo = _MemTxRepo();
      ruleRepo = _MemRuleRepo();
      engine = RecurringEngine(rules: ruleRepo, transactions: txRepo);
    });

    test('produces no txn before it is due', () async {
      await ruleRepo.upsert(_monthlyRule(nextRunAt: DateTime.utc(2026, 6, 1)));

      final RecurringRunResult res =
          await engine.run(Fixtures.userId, now: DateTime.utc(2026, 5, 15));

      expect(res.created, isEmpty);
      expect(txRepo.all, isEmpty);
      final RecurringRule? after = await ruleRepo.getById(Fixtures.categoryId);
      expect(after!.nextRunAt, DateTime.utc(2026, 6, 1));
    });

    test('materialises exactly one txn when due and advances nextRunAt',
        () async {
      await ruleRepo.upsert(_monthlyRule(nextRunAt: DateTime.utc(2026, 6, 1)));

      final RecurringRunResult res =
          await engine.run(Fixtures.userId, now: DateTime.utc(2026, 6, 1, 9));

      expect(res.created, hasLength(1));
      expect(txRepo.all, hasLength(1));
      final Transaction tx = txRepo.all.single;
      expect(tx.occurredAt, DateTime.utc(2026, 6, 1));
      expect(tx.recurringRuleId, Fixtures.categoryId);
      expect(tx.source, 'recurring');
      expect(tx.amount, Fixtures.kzt(1500));

      final RecurringRule? after = await ruleRepo.getById(Fixtures.categoryId);
      expect(after!.nextRunAt, DateTime.utc(2026, 7, 1));
    });

    test('is idempotent on re-run over the same window', () async {
      await ruleRepo.upsert(_monthlyRule(nextRunAt: DateTime.utc(2026, 6, 1)));

      await engine.run(Fixtures.userId, now: DateTime.utc(2026, 6, 1, 9));
      // Re-run at the same instant: nextRunAt is now July, so nothing new.
      final RecurringRunResult second =
          await engine.run(Fixtures.userId, now: DateTime.utc(2026, 6, 1, 9));

      expect(second.created, isEmpty);
      expect(txRepo.all, hasLength(1));
    });

    test('catches up multiple missed occurrences, no duplicates', () async {
      await ruleRepo.upsert(_monthlyRule(nextRunAt: DateTime.utc(2026, 3, 1)));

      // App opened in June after missing Mar/Apr/May/Jun occurrences.
      final RecurringRunResult res =
          await engine.run(Fixtures.userId, now: DateTime.utc(2026, 6, 10));

      expect(res.created, hasLength(4));
      final RecurringRule? after = await ruleRepo.getById(Fixtures.categoryId);
      expect(after!.nextRunAt, DateTime.utc(2026, 7, 1));

      // Idempotent re-run produces nothing.
      final RecurringRunResult again =
          await engine.run(Fixtures.userId, now: DateTime.utc(2026, 6, 10));
      expect(again.created, isEmpty);
      expect(txRepo.all, hasLength(4));
    });

    test('respects endAt and paused', () async {
      await ruleRepo.upsert(
        _monthlyRule(nextRunAt: DateTime.utc(2026, 6, 1)).copyWith(
          endAt: DateTime.utc(2026, 6, 1),
        ),
      );
      final RecurringRunResult ended =
          await engine.run(Fixtures.userId, now: DateTime.utc(2026, 12, 1));
      expect(ended.created, isEmpty);

      await ruleRepo.upsert(
        _monthlyRule(nextRunAt: DateTime.utc(2026, 6, 1))
            .copyWith(paused: true),
      );
      final RecurringRunResult paused =
          await engine.run(Fixtures.userId, now: DateTime.utc(2026, 12, 1));
      expect(paused.created, isEmpty);
    });

    test('clamps day-of-month on short months', () {
      final RecurringRule jan31 = _monthlyRule(
        nextRunAt: DateTime.utc(2026, 1, 31),
      );
      expect(
        jan31.advanceFrom(DateTime.utc(2026, 1, 31)),
        DateTime.utc(2026, 2, 28),
      );
    });
  });
}
