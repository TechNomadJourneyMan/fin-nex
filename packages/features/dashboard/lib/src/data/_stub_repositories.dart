// In-memory stubs for the four repositories the dashboard reads from.
//
// These let the dashboard render in isolation (golden tests, web preview,
// pre-wiring) and serve as a contract reference for the real
// `fnx_data_local` implementations. They are intentionally simple — no
// streams, no persistence.
//
// TODO(F-DASH-WIRE): remove once the app overrides the providers with
// the real repositories.

import 'dart:async';

import 'package:fnx_domain/fnx_domain.dart';

/// Returns the canonical KZT currency used for stub seed data.
Currency get _kzt => Currency.kzt;

/// Builds a deterministic small seed of demo accounts + transactions.
class _SeedData {
  _SeedData(Ulid userId)
      : accounts = <Account>[
          Account(
            id: Ulid('00000000000000000000000A01'),
            userId: userId,
            type: AccountType.cash,
            name: 'Cash',
            currency: _kzt,
            balance: Money.major(85000, _kzt),
            initialBalance: Money.major(80000, _kzt),
            color: CategoryColor('#3D5AFE'),
            isArchived: false,
            includeInTotal: true,
            sortOrder: 0,
            createdAt: DateTime.utc(2025, 1, 1),
            updatedAt: DateTime.utc(2025, 1, 1),
          ),
          Account(
            id: Ulid('00000000000000000000000A02'),
            userId: userId,
            type: AccountType.debitCard,
            name: 'Card',
            currency: _kzt,
            balance: Money.major(245000, _kzt),
            initialBalance: Money.major(200000, _kzt),
            color: CategoryColor('#00A87D'),
            isArchived: false,
            includeInTotal: true,
            sortOrder: 1,
            createdAt: DateTime.utc(2025, 1, 1),
            updatedAt: DateTime.utc(2025, 1, 1),
          ),
        ];

  final List<Account> accounts;
}

/// Trivial in-memory [AccountsRepository].
class StubAccountsRepository implements AccountsRepository {
  /// Default constructor.
  StubAccountsRepository();

  final Map<Ulid, List<Account>> _byUser = <Ulid, List<Account>>{};
  final Map<Ulid, StreamController<List<Account>>> _streams =
      <Ulid, StreamController<List<Account>>>{};

  List<Account> _seedFor(Ulid userId) =>
      _byUser.putIfAbsent(userId, () => _SeedData(userId).accounts);

  @override
  Future<Account?> getById(Ulid id) async {
    for (final list in _byUser.values) {
      for (final a in list) {
        if (a.id == id) return a;
      }
    }
    return null;
  }

  @override
  Future<List<Account>> list(Ulid userId) async => List<Account>.from(
        _seedFor(userId),
      );

  @override
  Future<void> softDelete(Ulid id) async {
    // No-op for the stub.
  }

  @override
  Future<void> upsert(Account account) async {
    final list = _seedFor(account.userId);
    final idx = list.indexWhere((a) => a.id == account.id);
    if (idx == -1) {
      list.add(account);
    } else {
      list[idx] = account;
    }
    _streams[account.userId]?.add(List<Account>.from(list));
  }

  @override
  Stream<List<Account>> watchAll(Ulid userId) {
    final ctrl = _streams.putIfAbsent(
      userId,
      () => StreamController<List<Account>>.broadcast(),
    );
    scheduleMicrotask(() => ctrl.add(List<Account>.from(_seedFor(userId))));
    return ctrl.stream;
  }
}

/// Trivial in-memory [TransactionsRepository].
class StubTransactionsRepository implements TransactionsRepository {
  /// Default constructor.
  StubTransactionsRepository();

  final Map<Ulid, List<Transaction>> _byUser = <Ulid, List<Transaction>>{};
  final Map<Ulid, StreamController<List<Transaction>>> _streams =
      <Ulid, StreamController<List<Transaction>>>{};

  List<Transaction> _seedFor(Ulid userId) {
    return _byUser.putIfAbsent(userId, () {
      final now = DateTime.now();
      final account = Ulid('00000000000000000000000A02');
      return <Transaction>[
        for (int i = 0; i < 8; i++)
          Transaction(
            id: Ulid(_padId(i)),
            userId: userId,
            accountId: account,
            type: i.isEven ? TransactionType.expense : TransactionType.income,
            amount: Money.major(1200 + i * 350, _kzt),
            occurredAt: now.subtract(Duration(hours: i * 6)),
            createdAt: now.subtract(Duration(hours: i * 6)),
            updatedAt: now.subtract(Duration(hours: i * 6)),
            source: 'manual',
            attachmentIds: const <Ulid>[],
            tagIds: const <Ulid>[],
            description: i.isEven ? 'Coffee' : 'Refund',
          ),
      ];
    });
  }

  static String _padId(int i) {
    final tail = i.toRadixString(32).toUpperCase().padLeft(2, '0');
    return '00000000000000000000000B$tail';
  }

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) {
    final ctrl = _streams.putIfAbsent(
      userId,
      () => StreamController<List<Transaction>>.broadcast(),
    );
    scheduleMicrotask(
      () => ctrl.add(List<Transaction>.from(_seedFor(userId))),
    );
    return ctrl.stream;
  }

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async {
    var rows = _seedFor(userId).where((t) {
      if (filter.from != null && t.occurredAt.isBefore(filter.from!)) {
        return false;
      }
      if (filter.to != null && !t.occurredAt.isBefore(filter.to!)) {
        return false;
      }
      return true;
    }).toList();
    rows.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    if (filter.limit != null && rows.length > filter.limit!) {
      rows = rows.sublist(0, filter.limit);
    }
    return rows;
  }

  @override
  Future<Transaction?> getById(Ulid id) async {
    for (final list in _byUser.values) {
      for (final t in list) {
        if (t.id == id) return t;
      }
    }
    return null;
  }

  @override
  Future<void> upsert(Transaction tx) async {
    final list = _seedFor(tx.userId);
    final idx = list.indexWhere((t) => t.id == tx.id);
    if (idx == -1) {
      list.insert(0, tx);
    } else {
      list[idx] = tx;
    }
    _streams[tx.userId]?.add(List<Transaction>.from(list));
  }

  @override
  Future<void> softDelete(Ulid id) async {
    // No-op for the stub.
  }
}

/// Trivial in-memory [AnalyticsRepository] computing zero-aggregates.
class StubAnalyticsRepository implements AnalyticsRepository {
  /// Default constructor.
  StubAnalyticsRepository();

  @override
  Future<DashboardSummary> dashboardSummary(Ulid userId) async {
    return DashboardSummary(
      netWorth: Money.major(330000, _kzt),
      incomeMonth: Money.major(180000, _kzt),
      expenseMonth: Money.major(95000, _kzt),
      savingsRate: 0.47,
    );
  }

  @override
  Future<List<CategoryBreakdownSlice>> categoryBreakdown(
    Ulid userId, {
    required DateTime from,
    required DateTime to,
  }) async {
    return <CategoryBreakdownSlice>[
      CategoryBreakdownSlice(
        categoryId: Ulid('00000000000000000000000C01'),
        amount: Money.major(35000, _kzt),
        percent: 0.36,
      ),
      CategoryBreakdownSlice(
        categoryId: Ulid('00000000000000000000000C02'),
        amount: Money.major(22000, _kzt),
        percent: 0.22,
      ),
      CategoryBreakdownSlice(
        categoryId: Ulid('00000000000000000000000C03'),
        amount: Money.major(18000, _kzt),
        percent: 0.18,
      ),
      CategoryBreakdownSlice(
        categoryId: Ulid('00000000000000000000000C04'),
        amount: Money.major(13000, _kzt),
        percent: 0.13,
      ),
      CategoryBreakdownSlice(
        categoryId: Ulid('00000000000000000000000C05'),
        amount: Money.major(7000, _kzt),
        percent: 0.11,
      ),
    ];
  }

  @override
  Future<List<CashflowBucket>> cashflow(
    Ulid userId, {
    required DateTime from,
    required DateTime to,
    required int bucketDays,
  }) async {
    final out = <CashflowBucket>[];
    var cursor = from;
    var i = 0;
    while (cursor.isBefore(to)) {
      out.add(
        CashflowBucket(
          bucketStart: cursor,
          income: Money.major(20000 + (i * 1300) % 9000, _kzt),
          expense: Money.major(10000 + (i * 1700) % 12000, _kzt),
        ),
      );
      cursor = cursor.add(Duration(days: bucketDays));
      i++;
    }
    return out;
  }
}

/// Trivial in-memory [CategoriesRepository].
class StubCategoriesRepository implements CategoriesRepository {
  /// Default constructor.
  StubCategoriesRepository();

  @override
  Stream<List<Category>> watchAll(Ulid userId) async* {
    yield await list(userId);
  }

  @override
  Future<List<Category>> list(Ulid userId) async {
    return <Category>[
      _cat('00000000000000000000000C01', 'Food', '#FF7043'),
      _cat('00000000000000000000000C02', 'Transport', '#42A5F5'),
      _cat('00000000000000000000000C03', 'Cafe', '#AB47BC'),
      _cat('00000000000000000000000C04', 'Shopping', '#26A69A'),
      _cat('00000000000000000000000C05', 'Other', '#9E9E9E'),
    ];
  }

  Category _cat(String id, String name, String hex) => Category(
        id: Ulid(id),
        type: CategoryType.expense,
        name: name,
        iconKey: 'category.$name',
        color: CategoryColor(hex),
        isSystem: true,
        isArchived: false,
        sortOrder: 0,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      );

  @override
  Future<Category?> getById(Ulid id) async {
    for (final c in await list(Ulid('00000000000000000000000000'))) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> upsert(Category category) async {
    // No-op for the stub.
  }

  @override
  Future<void> softDelete(Ulid id) async {
    // No-op for the stub.
  }
}
