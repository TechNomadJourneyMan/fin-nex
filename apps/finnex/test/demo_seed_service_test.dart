// Tests for DemoSeedService — seeding, idempotency, and clearDemo.
//
// Uses an in-memory TransactionsRepository fake (no sqflite) and the
// SharedPreferences mock so the whole suite runs without platform plugins.

import 'dart:async';

import 'package:pocketflow/onboarding/demo_seed_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory [TransactionsRepository] backing the tests. Stores rows in a
/// list and exposes the non-deleted snapshot via [live].
class _FakeTransactionsRepository implements TransactionsRepository {
  final List<Transaction> rows = <Transaction>[];

  /// Non-deleted rows.
  List<Transaction> get live =>
      rows.where((Transaction t) => t.deletedAt == null).toList();

  @override
  Future<Transaction?> getById(Ulid id) async {
    for (final Transaction t in rows) {
      if (t.id.value == id.value) return t;
    }
    return null;
  }

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async {
    return rows
        .where((Transaction t) => t.userId.value == userId.value)
        .toList();
  }

  @override
  Future<void> softDelete(Ulid id) async {
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].id.value == id.value) {
        rows[i] = rows[i].copyWith(deletedAt: DateTime.now().toUtc());
        break;
      }
    }
  }

  @override
  Future<void> upsert(Transaction tx) async {
    final int idx =
        rows.indexWhere((Transaction t) => t.id.value == tx.id.value);
    if (idx >= 0) {
      rows[idx] = tx;
    } else {
      rows.add(tx);
    }
  }

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) =>
      Stream<List<Transaction>>.value(live);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Ulid userId = Ulid('00000000000000000000000001');

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  DemoSeedService make(_FakeTransactionsRepository repo) =>
      DemoSeedService(repo, userId, Currency.kzt);

  test('seedIfNeeded inserts exactly four demo transactions', () async {
    final _FakeTransactionsRepository repo = _FakeTransactionsRepository();
    await make(repo).seedIfNeeded();

    expect(repo.live, hasLength(4));
    expect(
      repo.live.every((Transaction t) => t.source == kDemoSource),
      isTrue,
    );
    expect(repo.live.every((Transaction t) => t.userId == userId), isTrue);

    final List<Transaction> expenses = repo.live
        .where((Transaction t) => t.type == TransactionType.expense)
        .toList();
    final List<Transaction> income = repo.live
        .where((Transaction t) => t.type == TransactionType.income)
        .toList();
    expect(expenses, hasLength(3));
    expect(income, hasLength(1));

    // Зарплата = 350 000 KZT → 35 000 000 minor units (2 minor digits).
    expect(income.single.description, 'Зарплата');
    expect(income.single.amount.minor, BigInt.from(35000000));
    expect(income.single.amount.currency, Currency.kzt);
  });

  test('seedIfNeeded is idempotent — second call is a no-op', () async {
    final _FakeTransactionsRepository repo = _FakeTransactionsRepository();
    final DemoSeedService svc = make(repo);

    await svc.seedIfNeeded();
    expect(repo.live, hasLength(4));
    expect(await svc.hasSeeded(), isTrue);

    await svc.seedIfNeeded();
    await svc.seedIfNeeded();
    expect(repo.live, hasLength(4), reason: 'must not duplicate demo rows');
  });

  test('seedIfNeeded skips entirely when the flag is already set', () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{kDemoSeededKey: true},
    );
    final _FakeTransactionsRepository repo = _FakeTransactionsRepository();

    await make(repo).seedIfNeeded();
    expect(repo.live, isEmpty);
  });

  test('clearDemo soft-deletes demo rows and resets the flags', () async {
    final _FakeTransactionsRepository repo = _FakeTransactionsRepository();
    final DemoSeedService svc = make(repo);
    await svc.seedIfNeeded();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kDemoBannerDismissedKey, true);

    await svc.clearDemo();

    // All demo rows soft-deleted (still present, but deletedAt set).
    expect(repo.live, isEmpty);
    expect(repo.rows, hasLength(4));
    expect(
      repo.rows.every((Transaction t) => t.deletedAt != null),
      isTrue,
    );

    // Flags reset → behaves like a fresh install.
    expect(await svc.hasSeeded(), isFalse);
    expect(prefs.getBool(kDemoBannerDismissedKey), isNull);
  });

  test('clearDemo leaves non-demo transactions untouched', () async {
    final _FakeTransactionsRepository repo = _FakeTransactionsRepository();
    final DateTime now = DateTime.now().toUtc();
    final Transaction manual = Transaction(
      id: Ulid.now(),
      userId: userId,
      accountId: kDemoAccountId,
      type: TransactionType.expense,
      amount: Money.major(100, Currency.kzt),
      occurredAt: now,
      createdAt: now,
      updatedAt: now,
      source: 'manual',
      attachmentIds: const <Ulid>[],
      tagIds: const <Ulid>[],
    );
    await repo.upsert(manual);

    final DemoSeedService svc = make(repo);
    await svc.seedIfNeeded();
    expect(repo.live, hasLength(5));

    await svc.clearDemo();

    expect(repo.live, hasLength(1));
    expect(repo.live.single.source, 'manual');
  });
}
