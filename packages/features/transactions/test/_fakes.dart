import 'dart:async';

import 'package:pf_domain/pf_domain.dart';

/// In-memory [TransactionsRepository] for tests. Stores rows in a list,
/// emits the live snapshot to all subscribers.
class FakeTransactionsRepository implements TransactionsRepository {
  final List<Transaction> _rows = <Transaction>[];
  final StreamController<List<Transaction>> _controller =
      StreamController<List<Transaction>>.broadcast();

  void _emit() {
    final List<Transaction> live = _rows
        .where((Transaction t) => t.deletedAt == null)
        .toList(growable: false);
    _controller.add(live);
  }

  /// Disposes the underlying stream controller.
  Future<void> dispose() => _controller.close();

  @override
  Future<Transaction?> getById(Ulid id) async {
    for (final Transaction t in _rows) {
      if (t.id.value == id.value) {
        return t;
      }
    }
    return null;
  }

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async {
    return _rows
        .where(
          (Transaction t) =>
              t.userId.value == userId.value && t.deletedAt == null,
        )
        .toList(growable: false);
  }

  @override
  Future<void> softDelete(Ulid id) async {
    for (int i = 0; i < _rows.length; i++) {
      if (_rows[i].id.value == id.value) {
        _rows[i] = _rows[i].copyWith(deletedAt: DateTime.now().toUtc());
        break;
      }
    }
    _emit();
  }

  @override
  Future<void> upsert(Transaction tx) async {
    final int idx =
        _rows.indexWhere((Transaction t) => t.id.value == tx.id.value);
    if (idx >= 0) {
      _rows[idx] = tx;
    } else {
      _rows.add(tx);
    }
    _emit();
  }

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) async* {
    yield _rows
        .where(
          (Transaction t) =>
              t.userId.value == userId.value && t.deletedAt == null,
        )
        .toList(growable: false);
    yield* _controller.stream.map(
      (List<Transaction> snap) => snap
          .where((Transaction t) => t.userId.value == userId.value)
          .toList(growable: false),
    );
  }
}

/// Minimal in-memory [AccountsRepository] backing the tests.
class FakeAccountsRepository implements AccountsRepository {
  /// Default ctor.
  FakeAccountsRepository(this._rows);
  final List<Account> _rows;

  @override
  Future<Account?> getById(Ulid id) async {
    for (final Account a in _rows) {
      if (a.id.value == id.value) {
        return a;
      }
    }
    return null;
  }

  @override
  Future<List<Account>> list(Ulid userId) async => _rows;

  @override
  Future<void> softDelete(Ulid id) async {}

  @override
  Future<void> upsert(Account account) async {}

  @override
  Stream<List<Account>> watchAll(Ulid userId) async* {
    yield _rows;
  }
}

/// Minimal in-memory [CategoriesRepository] backing the tests.
class FakeCategoriesRepository implements CategoriesRepository {
  /// Default ctor.
  FakeCategoriesRepository(this._rows);
  final List<Category> _rows;

  @override
  Future<Category?> getById(Ulid id) async {
    for (final Category c in _rows) {
      if (c.id.value == id.value) {
        return c;
      }
    }
    return null;
  }

  @override
  Future<List<Category>> list(Ulid userId) async => _rows;

  @override
  Future<void> softDelete(Ulid id) async {}

  @override
  Future<void> upsert(Category category) async {}

  @override
  Stream<List<Category>> watchAll(Ulid userId) async* {
    yield _rows;
  }
}

/// Constructs a [Transaction] with sensible test defaults.
Transaction makeTransaction({
  required Ulid id,
  required Ulid userId,
  required Ulid accountId,
  Ulid? categoryId,
  TransactionType type = TransactionType.expense,
  int minor = 1000,
  Currency currency = Currency.kzt,
  DateTime? occurredAt,
  String? description,
  DateTime? deletedAt,
}) {
  final DateTime when = (occurredAt ?? DateTime.now().toUtc());
  return Transaction(
    id: id,
    userId: userId,
    accountId: accountId,
    type: type,
    amount: Money(BigInt.from(minor), currency),
    categoryId: categoryId,
    occurredAt: when,
    description: description,
    createdAt: when,
    updatedAt: when,
    source: 'manual',
    attachmentIds: const <Ulid>[],
    tagIds: const <Ulid>[],
    deletedAt: deletedAt,
  );
}

/// Constructs a [Category] with sensible test defaults.
Category makeCategory({
  required Ulid id,
  Ulid? userId,
  String name = 'Cafe',
  CategoryType type = CategoryType.expense,
}) {
  final DateTime now = DateTime.now().toUtc();
  return Category(
    id: id,
    userId: userId,
    type: type,
    name: name,
    iconKey: 'cafe',
    color: CategoryColor('#FF9900'),
    isSystem: false,
    isArchived: false,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

/// Constructs an [Account] with sensible test defaults.
Account makeAccount({
  required Ulid id,
  required Ulid userId,
  String name = 'Cash',
  Currency currency = Currency.kzt,
}) {
  final DateTime now = DateTime.now().toUtc();
  return Account(
    id: id,
    userId: userId,
    type: AccountType.cash,
    name: name,
    currency: currency,
    balance: Money(BigInt.zero, currency),
    initialBalance: Money(BigInt.zero, currency),
    color: CategoryColor('#3366FF'),
    isArchived: false,
    includeInTotal: true,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}
