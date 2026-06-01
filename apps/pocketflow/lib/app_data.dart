// Application data module.
//
// Owns the local sqflite database, exposes ready-to-use domain repositories
// (adapters bridging the sqflite-shaped repos in `pf_data_local` to the
// `Ulid`/`Money`-typed contracts in `pf_domain`).
//
// Created at app bootstrap and held for the app's lifetime; tear down via
// [dispose] when running multiple isolated app instances (tests).
//
// Bootstrap is FAILSAFE: [openOrFallback] never throws. If sqflite cannot
// be opened (web without worker, locked file, corrupt IndexedDB, plugin
// missing) the module degrades to an in-memory implementation so the UI
// always loads. [AppDataModule.fallbackReason] surfaces the underlying
// error so the UI can warn the user that persistence is disabled.

import 'dart:async';

// Only import the symbol we need from flutter/foundation to avoid the
// `Category` annotation clashing with the domain `Category` entity.
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pf_data_local/pf_data_local.dart' as local;
import 'package:pf_domain/pf_domain.dart';

/// Lazily-constructed singleton holding the database and adapter repositories.
class AppDataModule {
  AppDataModule._(
    this._db,
    this.transactions,
    this.accounts,
    this.categories, {
    AnalyticsRepository? analytics,
    this.fallbackReason,
    this.isInMemory = false,
  }) : analytics = analytics ??
            _LiveAnalyticsRepository(
              transactions: transactions,
              accounts: accounts,
            );

  final local.PfDatabase? _db;

  /// Domain-shaped transactions repository.
  final TransactionsRepository transactions;

  /// Domain-shaped accounts repository.
  final AccountsRepository accounts;

  /// Domain-shaped categories repository.
  final CategoriesRepository categories;

  /// Live analytics repository computed over [transactions] + [accounts].
  final AnalyticsRepository analytics;

  /// Non-null when the module fell back to an in-memory implementation.
  /// Holds a short, user-presentable description of the underlying error.
  final String? fallbackReason;

  /// True when this module is non-persistent (in-memory only).
  final bool isInMemory;

  /// True when persistence is working.
  bool get isPersistent => fallbackReason == null && !isInMemory;

  /// Opens the application database, runs first-time seed (default account)
  /// and returns the wired module. Throws if sqflite cannot be opened —
  /// prefer [openOrFallback] in production code paths.
  static Future<AppDataModule> open({
    required Ulid demoUserId,
    bool inMemory = false,
  }) async {
    final local.PfDatabase db = inMemory
        ? await local.PfDatabase.openInMemory()
        : await local.PfDatabase.open();

    final local.TransactionsDao txDao = local.TransactionsDao(db);
    final local.AccountsDao acctDao = local.AccountsDao(db);
    final local.CategoriesDao catDao = local.CategoriesDao(db);

    final local.TransactionsRepository txRepo =
        local.TransactionsRepositoryImpl(txDao);
    final local.AccountsRepository acctRepo =
        local.AccountsRepositoryImpl(acctDao);
    final local.CategoriesRepository catRepo =
        local.CategoriesRepositoryImpl(catDao);

    final IdMapper ids = IdMapper();
    // Prime the mapper for system categories so surrogate ULIDs are stable
    // before the first UI read.
    final List<local.CategoryRow> seededCats =
        await catRepo.list(demoUserId.value);
    for (final local.CategoryRow row in seededCats) {
      ids.stringToUlid(row.id);
    }

    await _seedDefaultAccountIfNeeded(
      acctRepo: acctRepo,
      demoUserId: demoUserId,
      ids: ids,
    );

    final _TransactionsAdapter txAdapter = _TransactionsAdapter(txRepo, ids);
    final _AccountsAdapter acctAdapter = _AccountsAdapter(acctRepo, ids);
    final _CategoriesAdapter catAdapter = _CategoriesAdapter(catRepo, ids);

    return AppDataModule._(db, txAdapter, acctAdapter, catAdapter);
  }

  /// Failsafe entrypoint. Tries [open] up to two times (persistent → in-memory
  /// sqflite → pure-Dart in-memory). Never throws. Always returns a usable
  /// module so the UI can render even when storage is broken.
  ///
  /// On the way down it records the first error in [AppDataModule.fallbackReason]
  /// so the UI can surface a warning banner.
  static Future<AppDataModule> openOrFallback({
    required Ulid demoUserId,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    Object? firstError;

    // 1. Try persistent sqflite.
    try {
      return await open(demoUserId: demoUserId).timeout(timeout);
    } catch (e, st) {
      firstError = e;
      debugPrint('AppDataModule.open() failed (persistent): $e\n$st');
    }

    // 2. Try in-memory sqflite (same SQL engine, no disk).
    try {
      final AppDataModule m =
          await open(demoUserId: demoUserId, inMemory: true).timeout(timeout);
      return AppDataModule._(
        m._db,
        m.transactions,
        m.accounts,
        m.categories,
        fallbackReason: _shortError(firstError),
        isInMemory: true,
      );
    } catch (e, st) {
      debugPrint('AppDataModule.open(inMemory:true) failed: $e\n$st');
      // firstError is already populated from the first try{} above.
    }

    // 3. Last resort — pure-Dart in-memory adapters. Always succeeds.
    final _PureInMemoryModule pure = _PureInMemoryModule(demoUserId);
    return AppDataModule._(
      null,
      pure.transactions,
      pure.accounts,
      pure.categories,
      fallbackReason: _shortError(firstError) ??
          'Local storage is unavailable. Running in-memory.',
      isInMemory: true,
    );
  }

  static String? _shortError(Object? e) {
    if (e == null) return null;
    final String s = e.toString().replaceAll('\n', ' ');
    return s.length > 240 ? '${s.substring(0, 237)}...' : s;
  }

  /// Closes the database.
  Future<void> dispose() async => _db?.close();

  static Future<void> _seedDefaultAccountIfNeeded({
    required local.AccountsRepository acctRepo,
    required Ulid demoUserId,
    required IdMapper ids,
  }) async {
    final List<local.AccountRow> existing = await acctRepo.list(demoUserId.value);
    if (existing.isNotEmpty) {
      return;
    }
    final DateTime now = DateTime.now().toUtc();
    final Ulid id = Ulid.now(at: now);
    await acctRepo.save(
      local.AccountRow(
        id: id.value,
        userId: demoUserId.value,
        typeCode: AccountType.cash.code,
        name: 'Кошелёк',
        currency: Currency.kzt.code,
        balanceMinor: 0,
        initialBalanceMinor: 0,
        color: '#1F8FFF',
        icon: 'account_balance_wallet',
        sortOrder: 0,
        clientId: id.value,
        createdAt: now,
        updatedAt: now,
        syncState: local.SyncState.pending,
        version: 1,
        dirty: true,
      ),
    );
    ids.stringToUlid(id.value);
  }
}

/// Bidirectional `String <-> Ulid` mapping.
///
/// The local database stores arbitrary string primary keys (including
/// non-ULID strings such as `'food_groceries'` for seeded system categories).
/// The domain layer requires every identifier to be a valid 26-character
/// Crockford base-32 ULID. This mapper transparently bridges both worlds.
class IdMapper {
  /// Public default constructor.
  IdMapper();

  final Map<String, Ulid> _toUlid = <String, Ulid>{};
  final Map<String, String> _toString = <String, String>{};

  /// Converts a raw database string id to a domain [Ulid].
  ///
  /// Strings that already satisfy the ULID format are wrapped directly;
  /// everything else gets a deterministic surrogate so the same input always
  /// maps to the same [Ulid] across sessions.
  Ulid stringToUlid(String raw) {
    final Ulid? cached = _toUlid[raw];
    if (cached != null) return cached;
    Ulid u;
    try {
      u = Ulid(raw);
    } on ArgumentError {
      u = _surrogateFor(raw);
    }
    _toUlid[raw] = u;
    _toString[u.value] = raw;
    return u;
  }

  /// Resolves a domain [Ulid] back to the underlying database string id.
  ///
  /// Falls back to the ULID's literal value when the mapper has never seen
  /// the id (the common case for fresh ULIDs created in the UI).
  String ulidToString(Ulid id) {
    final String? cached = _toString[id.value];
    if (cached != null) return cached;
    _toString[id.value] = id.value;
    _toUlid[id.value] = id;
    return id.value;
  }

  /// Optional helper for nullable conversion.
  Ulid? maybeStringToUlid(String? raw) =>
      raw == null ? null : stringToUlid(raw);

  /// Optional helper for nullable conversion.
  String? maybeUlidToString(Ulid? id) => id == null ? null : ulidToString(id);

  /// Deterministic 32-bit FNV-1a + xorshift to produce a stable 26-char
  /// Crockford base-32 ULID surrogate.
  ///
  /// Uses only 32-bit operations so the output is identical on the Dart VM
  /// and on JavaScript (web).
  static Ulid _surrogateFor(String input) {
    const String alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    int h = 0x811c9dc5;
    for (final int c in input.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF;
    }
    int state = h == 0 ? 0xdeadbeef : h;
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < 26; i++) {
      state ^= (state << 13) & 0xFFFFFFFF;
      state ^= (state >> 17) & 0xFFFFFFFF;
      state ^= (state << 5) & 0xFFFFFFFF;
      state &= 0xFFFFFFFF;
      buf.write(alphabet[state & 31]);
    }
    return Ulid(buf.toString());
  }
}

/// Catches sqflite_common_ffi_web's intermittent "Bad state: Database N not
/// found" errors and returns a safe fallback instead of propagating up.
///
/// The Web worker occasionally loses its database handle (idle, GC, page
/// freeze). When that happens our streams used to emit errors and pages
/// turned blank. This wrapper degrades gracefully — the UI shows the last
/// good snapshot or an empty list.
Future<T> _safeDb<T>(Future<T> Function() op, T fallback) async {
  try {
    return await op();
  } catch (e) {
    final String msg = e.toString();
    if (msg.contains('Database') && msg.contains('not found')) {
      debugPrint('sqflite handle lost — degraded read: $e');
      return fallback;
    }
    rethrow;
  }
}

Stream<T> _safeStream<T>(Stream<T> Function() build, T fallback) {
  late StreamController<T> ctrl;
  StreamSubscription<T>? sub;
  void subscribe() {
    try {
      sub = build().listen(
        ctrl.add,
        onError: (Object e, StackTrace st) {
          final String msg = e.toString();
          if (msg.contains('Database') && msg.contains('not found')) {
            debugPrint('sqflite stream handle lost — emitting fallback: $e');
            ctrl.add(fallback);
          } else {
            ctrl.addError(e, st);
          }
        },
      );
    } catch (e) {
      ctrl.add(fallback);
    }
  }

  ctrl = StreamController<T>(
    onListen: subscribe,
    onCancel: () => sub?.cancel(),
  );
  return ctrl.stream;
}

class _TransactionsAdapter implements TransactionsRepository {
  _TransactionsAdapter(this._repo, this._ids);

  final local.TransactionsRepository _repo;
  final IdMapper _ids;

  Transaction _toDomain(local.TransactionRow r) {
    final Currency currency =
        Currency.tryParse(r.currency) ?? Currency.kzt;
    return Transaction(
      id: _ids.stringToUlid(r.id),
      userId: _ids.stringToUlid(r.userId),
      accountId: _ids.stringToUlid(r.accountId),
      type: TransactionType.parse(r.typeCode),
      amount: Money(BigInt.from(r.amountMinor), currency),
      categoryId: _ids.maybeStringToUlid(r.categoryId),
      occurredAt: r.occurredAt,
      description: r.note,
      transferAccountId: _ids.maybeStringToUlid(r.transferAccountId),
      transferGroupId: _ids.maybeStringToUlid(r.transferGroupId),
      recurringRuleId: _ids.maybeStringToUlid(r.recurringRuleId),
      source: r.source,
      externalRef: r.externalRef,
      lat: r.lat,
      lng: r.lng,
      attachmentIds: const <Ulid>[],
      tagIds: const <Ulid>[],
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
    );
  }

  local.TransactionRow _toRow(Transaction tx) {
    return local.TransactionRow(
      id: _ids.ulidToString(tx.id),
      userId: _ids.ulidToString(tx.userId),
      accountId: _ids.ulidToString(tx.accountId),
      typeCode: tx.type.code,
      categoryId: _ids.maybeUlidToString(tx.categoryId),
      amountMinor: tx.amount.minor.toInt(),
      currency: tx.amount.currency.code,
      occurredAt: tx.occurredAt,
      note: tx.description,
      transferAccountId: _ids.maybeUlidToString(tx.transferAccountId),
      transferGroupId: _ids.maybeUlidToString(tx.transferGroupId),
      recurringRuleId: _ids.maybeUlidToString(tx.recurringRuleId),
      source: tx.source,
      externalRef: tx.externalRef,
      lat: tx.lat,
      lng: tx.lng,
      clientId: _ids.ulidToString(tx.id),
      createdAt: tx.createdAt,
      updatedAt: tx.updatedAt,
      deletedAt: tx.deletedAt,
      syncState: local.SyncState.pending,
      version: 1,
      dirty: true,
    );
  }

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) => _safeStream<List<Transaction>>(
        () => _repo.watch(_ids.ulidToString(userId)).map(
              (List<local.TransactionRow> rows) =>
                  rows.map(_toDomain).toList(growable: false),
            ),
        const <Transaction>[],
      );

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async {
    return _safeDb<List<Transaction>>(() async {
      final String? accountId = filter.accountIds.isEmpty
          ? null
          : _ids.ulidToString(filter.accountIds.first);
      final String? categoryId = filter.categoryIds.isEmpty
          ? null
          : _ids.ulidToString(filter.categoryIds.first);
      final String? typeCode =
          filter.types.isEmpty ? null : filter.types.first;
      final List<local.TransactionRow> rows = await _repo.list(
        _ids.ulidToString(userId),
        from: filter.from,
        to: filter.to,
        accountId: accountId,
        categoryId: categoryId,
        typeCode: typeCode,
        limit: filter.limit,
      );
      return rows.map(_toDomain).toList(growable: false);
    }, const <Transaction>[]);
  }

  @override
  Future<Transaction?> getById(Ulid id) async {
    return _safeDb<Transaction?>(() async {
      final local.TransactionRow? row =
          await _repo.findById(_ids.ulidToString(id));
      return row == null ? null : _toDomain(row);
    }, null);
  }

  @override
  Future<void> upsert(Transaction tx) =>
      _safeDb<void>(() => _repo.save(_toRow(tx)), null);

  @override
  Future<void> softDelete(Ulid id) =>
      _safeDb<void>(() => _repo.remove(_ids.ulidToString(id)), null);
}

class _AccountsAdapter implements AccountsRepository {
  _AccountsAdapter(this._repo, this._ids);

  final local.AccountsRepository _repo;
  final IdMapper _ids;

  Account _toDomain(local.AccountRow r) {
    final Currency currency =
        Currency.tryParse(r.currency) ?? Currency.kzt;
    return Account(
      id: _ids.stringToUlid(r.id),
      userId: _ids.stringToUlid(r.userId),
      type: AccountType.parse(r.typeCode),
      name: r.name,
      currency: currency,
      balance: Money(BigInt.from(r.balanceMinor), currency),
      initialBalance: Money(BigInt.from(r.initialBalanceMinor), currency),
      creditLimit: r.creditLimitMinor == null
          ? null
          : Money(BigInt.from(r.creditLimitMinor!), currency),
      bankCode: r.bankCode,
      lastFour: r.lastFour,
      color: CategoryColor(r.color),
      icon: r.icon,
      isArchived: r.isArchived,
      includeInTotal: r.includeInTotal,
      sortOrder: r.sortOrder,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
    );
  }

  local.AccountRow _toRow(Account a) {
    return local.AccountRow(
      id: _ids.ulidToString(a.id),
      userId: _ids.ulidToString(a.userId),
      typeCode: a.type.code,
      name: a.name,
      currency: a.currency.code,
      balanceMinor: a.balance.minor.toInt(),
      initialBalanceMinor: a.initialBalance.minor.toInt(),
      creditLimitMinor: a.creditLimit?.minor.toInt(),
      bankCode: a.bankCode,
      lastFour: a.lastFour,
      color: a.color.hex,
      icon: a.icon,
      isArchived: a.isArchived,
      includeInTotal: a.includeInTotal,
      sortOrder: a.sortOrder,
      clientId: _ids.ulidToString(a.id),
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
      deletedAt: a.deletedAt,
      syncState: local.SyncState.pending,
      version: 1,
      dirty: true,
    );
  }

  @override
  Stream<List<Account>> watchAll(Ulid userId) => _safeStream<List<Account>>(
        () => _repo.watch(_ids.ulidToString(userId)).map(
              (List<local.AccountRow> rows) =>
                  rows.map(_toDomain).toList(growable: false),
            ),
        const <Account>[],
      );

  @override
  Future<List<Account>> list(Ulid userId) async {
    return _safeDb<List<Account>>(() async {
      final List<local.AccountRow> rows =
          await _repo.list(_ids.ulidToString(userId));
      return rows.map(_toDomain).toList(growable: false);
    }, const <Account>[]);
  }

  @override
  Future<Account?> getById(Ulid id) async {
    return _safeDb<Account?>(() async {
      final local.AccountRow? row =
          await _repo.findById(_ids.ulidToString(id));
      return row == null ? null : _toDomain(row);
    }, null);
  }

  @override
  Future<void> upsert(Account account) =>
      _safeDb<void>(() => _repo.save(_toRow(account)), null);

  @override
  Future<void> softDelete(Ulid id) =>
      _safeDb<void>(() => _repo.remove(_ids.ulidToString(id)), null);
}

class _CategoriesAdapter implements CategoriesRepository {
  _CategoriesAdapter(this._repo, this._ids);

  final local.CategoriesRepository _repo;
  final IdMapper _ids;

  Category _toDomain(local.CategoryRow r) => Category(
        id: _ids.stringToUlid(r.id),
        userId: r.userId == null ? null : _ids.stringToUlid(r.userId!),
        type: CategoryType.parse(r.typeCode),
        parentId: r.parentId == null ? null : _ids.stringToUlid(r.parentId!),
        name: r.name,
        nameI18nKey: r.nameI18nKey,
        iconKey: r.icon,
        color: CategoryColor(r.color),
        isSystem: r.isSystem,
        isArchived: r.isArchived,
        sortOrder: r.sortOrder,
        monthlyLimit: r.monthlyLimitMinor == null
            ? null
            : Money(BigInt.from(r.monthlyLimitMinor!), Currency.kzt),
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
      );

  local.CategoryRow _toRow(Category c) => local.CategoryRow(
        id: _ids.ulidToString(c.id),
        userId: c.userId == null ? null : _ids.ulidToString(c.userId!),
        typeCode: c.type.code,
        parentId: c.parentId == null ? null : _ids.ulidToString(c.parentId!),
        name: c.name,
        nameI18nKey: c.nameI18nKey,
        icon: c.iconKey,
        color: c.color.hex,
        isSystem: c.isSystem,
        isArchived: c.isArchived,
        sortOrder: c.sortOrder,
        monthlyLimitMinor: c.monthlyLimit?.minor.toInt(),
        clientId: _ids.ulidToString(c.id),
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        deletedAt: c.deletedAt,
        syncState: local.SyncState.pending,
        version: 1,
        dirty: true,
      );

  @override
  Stream<List<Category>> watchAll(Ulid userId) => _safeStream<List<Category>>(
        () => _repo.watch(_ids.ulidToString(userId)).map(
              (List<local.CategoryRow> rows) =>
                  rows.map(_toDomain).toList(growable: false),
            ),
        const <Category>[],
      );

  @override
  Future<List<Category>> list(Ulid userId) async {
    return _safeDb<List<Category>>(() async {
      final List<local.CategoryRow> rows =
          await _repo.list(_ids.ulidToString(userId));
      return rows.map(_toDomain).toList(growable: false);
    }, const <Category>[]);
  }

  @override
  Future<Category?> getById(Ulid id) async {
    return _safeDb<Category?>(() async {
      final local.CategoryRow? row =
          await _repo.findById(_ids.ulidToString(id));
      return row == null ? null : _toDomain(row);
    }, null);
  }

  @override
  Future<void> upsert(Category category) =>
      _safeDb<void>(() => _repo.save(_toRow(category)), null);

  @override
  Future<void> softDelete(Ulid id) =>
      _safeDb<void>(() => _repo.remove(_ids.ulidToString(id)), null);
}

// ---------------------------------------------------------------------------
// Live analytics computed over [TransactionsRepository] + [AccountsRepository].
//
// Replaces the dashboard's seeded StubAnalyticsRepository so the home screen
// reflects real persisted data instead of demo fixtures.

class _LiveAnalyticsRepository implements AnalyticsRepository {
  _LiveAnalyticsRepository({
    required this.transactions,
    required this.accounts,
  });

  final TransactionsRepository transactions;
  final AccountsRepository accounts;

  @override
  Future<DashboardSummary> dashboardSummary(Ulid userId) async {
    final List<Account> accs = await accounts.list(userId);
    final List<Transaction> txs = await transactions.list(
      userId,
      const TransactionFilter(),
    );

    final Currency primary =
        accs.isEmpty ? Currency.kzt : accs.first.currency;
    Money netWorth = Money.zero(primary);
    for (final Account a in accs) {
      if (!a.includeInTotal || a.deletedAt != null) continue;
      if (a.currency == primary) {
        netWorth = netWorth + a.balance;
      } else {
        // No FX rate available — fall back to ignoring foreign currencies.
        // (Real implementation would convert via ExchangeRate cache.)
      }
    }

    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month);
    Money income = Money.zero(primary);
    Money expense = Money.zero(primary);
    for (final Transaction t in txs) {
      if (t.deletedAt != null) continue;
      if (t.occurredAt.isBefore(monthStart)) continue;
      if (t.amount.currency != primary) continue;
      switch (t.type) {
        case TransactionType.income:
          income = income + t.amount;
        case TransactionType.expense:
          expense = expense + t.amount;
        case TransactionType.transfer:
        case TransactionType.adjustment:
          break;
      }
    }

    double savingsRate = 0;
    if (!income.isZero) {
      final double i = income.minor.toDouble();
      final double e = expense.minor.toDouble();
      savingsRate = ((i - e) / i).clamp(-1.0, 1.0);
    }

    return DashboardSummary(
      netWorth: netWorth,
      incomeMonth: income,
      expenseMonth: expense,
      savingsRate: savingsRate,
    );
  }

  @override
  Future<List<CategoryBreakdownSlice>> categoryBreakdown(
    Ulid userId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final List<Transaction> txs = await transactions.list(
      userId,
      TransactionFilter(from: from, to: to),
    );
    final Map<Ulid, BigInt> totals = <Ulid, BigInt>{};
    Currency? primary;
    BigInt grandTotal = BigInt.zero;
    for (final Transaction t in txs) {
      if (t.deletedAt != null) continue;
      if (t.type != TransactionType.expense) continue;
      if (t.categoryId == null) continue;
      primary ??= t.amount.currency;
      if (t.amount.currency != primary) continue;
      totals[t.categoryId!] =
          (totals[t.categoryId!] ?? BigInt.zero) + t.amount.minor;
      grandTotal += t.amount.minor;
    }
    if (grandTotal == BigInt.zero || primary == null) {
      return const <CategoryBreakdownSlice>[];
    }
    final List<CategoryBreakdownSlice> slices = totals.entries
        .map(
          (MapEntry<Ulid, BigInt> e) => CategoryBreakdownSlice(
            categoryId: e.key,
            amount: Money(e.value, primary!),
            percent: e.value.toDouble() / grandTotal.toDouble(),
          ),
        )
        .toList(growable: false)
      ..sort(
        (CategoryBreakdownSlice a, CategoryBreakdownSlice b) =>
            b.amount.minor.compareTo(a.amount.minor),
      );
    return slices;
  }

  @override
  Future<List<CashflowBucket>> cashflow(
    Ulid userId, {
    required DateTime from,
    required DateTime to,
    required int bucketDays,
  }) async {
    final List<Transaction> txs = await transactions.list(
      userId,
      TransactionFilter(from: from, to: to),
    );
    if (txs.isEmpty) return const <CashflowBucket>[];
    final Currency primary = txs.first.amount.currency;
    final Map<int, _BucketAcc> buckets = <int, _BucketAcc>{};
    final Duration step = Duration(days: bucketDays);
    for (final Transaction t in txs) {
      if (t.deletedAt != null) continue;
      if (t.amount.currency != primary) continue;
      final int slot = t.occurredAt.difference(from).inDays ~/ bucketDays;
      final _BucketAcc acc = buckets.putIfAbsent(
        slot,
        () => _BucketAcc(from.add(step * slot), primary),
      );
      switch (t.type) {
        case TransactionType.income:
          acc.income = acc.income + t.amount;
        case TransactionType.expense:
          acc.expense = acc.expense + t.amount;
        case TransactionType.transfer:
        case TransactionType.adjustment:
          break;
      }
    }
    final List<CashflowBucket> out = buckets.values
        .map(
          (_BucketAcc a) => CashflowBucket(
            bucketStart: a.start,
            income: a.income,
            expense: a.expense,
          ),
        )
        .toList(growable: false)
      ..sort(
        (CashflowBucket a, CashflowBucket b) =>
            a.bucketStart.compareTo(b.bucketStart),
      );
    return out;
  }
}

class _BucketAcc {
  _BucketAcc(this.start, Currency currency)
      : income = Money.zero(currency),
        expense = Money.zero(currency);
  final DateTime start;
  Money income;
  Money expense;
}

// ---------------------------------------------------------------------------
// Last-resort pure-Dart fallback.
//
// Used by [AppDataModule.openOrFallback] when BOTH the persistent and the
// in-memory sqflite paths have failed. No external dependencies, no plugins,
// no platform channels — guaranteed to work everywhere Dart runs. Data is
// lost on app restart; the UI banner derived from `fallbackReason` warns the
// user.

class _PureInMemoryModule {
  _PureInMemoryModule(Ulid userId)
      : transactions = _MemTransactionsRepo(),
        accounts = _MemAccountsRepo()..seed(userId),
        categories = _MemCategoriesRepo();

  final TransactionsRepository transactions;
  final AccountsRepository accounts;
  final CategoriesRepository categories;
}

class _MemTransactionsRepo implements TransactionsRepository {
  final List<Transaction> _items = <Transaction>[];
  final StreamController<List<Transaction>> _ctrl =
      StreamController<List<Transaction>>.broadcast();

  void _emit() => _ctrl.add(List<Transaction>.unmodifiable(_items));

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) async* {
    yield List<Transaction>.unmodifiable(_items);
    yield* _ctrl.stream;
  }

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async =>
      List<Transaction>.unmodifiable(_items);

  @override
  Future<Transaction?> getById(Ulid id) async {
    for (final Transaction t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> upsert(Transaction tx) async {
    final int idx = _items.indexWhere((Transaction t) => t.id == tx.id);
    if (idx >= 0) {
      _items[idx] = tx;
    } else {
      _items.add(tx);
    }
    _emit();
  }

  @override
  Future<void> softDelete(Ulid id) async {
    _items.removeWhere((Transaction t) => t.id == id);
    _emit();
  }
}

class _MemAccountsRepo implements AccountsRepository {
  final List<Account> _items = <Account>[];
  final StreamController<List<Account>> _ctrl =
      StreamController<List<Account>>.broadcast();

  void _emit() => _ctrl.add(List<Account>.unmodifiable(_items));

  void seed(Ulid userId) {
    final DateTime now = DateTime.now().toUtc();
    final Ulid id = Ulid.now(at: now);
    _items.add(
      Account(
        id: id,
        userId: userId,
        type: AccountType.cash,
        name: 'Кошелёк',
        currency: Currency.kzt,
        balance: Money.zero(Currency.kzt),
        initialBalance: Money.zero(Currency.kzt),
        color: CategoryColor('#1F8FFF'),
        icon: 'account_balance_wallet',
        isArchived: false,
        includeInTotal: true,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Stream<List<Account>> watchAll(Ulid userId) async* {
    yield List<Account>.unmodifiable(_items);
    yield* _ctrl.stream;
  }

  @override
  Future<List<Account>> list(Ulid userId) async =>
      List<Account>.unmodifiable(_items);

  @override
  Future<Account?> getById(Ulid id) async {
    for (final Account a in _items) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<void> upsert(Account account) async {
    final int idx = _items.indexWhere((Account a) => a.id == account.id);
    if (idx >= 0) {
      _items[idx] = account;
    } else {
      _items.add(account);
    }
    _emit();
  }

  @override
  Future<void> softDelete(Ulid id) async {
    _items.removeWhere((Account a) => a.id == id);
    _emit();
  }
}

class _MemCategoriesRepo implements CategoriesRepository {
  final List<Category> _items = <Category>[];
  final StreamController<List<Category>> _ctrl =
      StreamController<List<Category>>.broadcast();

  @override
  Stream<List<Category>> watchAll(Ulid userId) async* {
    yield List<Category>.unmodifiable(_items);
    yield* _ctrl.stream;
  }

  @override
  Future<List<Category>> list(Ulid userId) async =>
      List<Category>.unmodifiable(_items);

  @override
  Future<Category?> getById(Ulid id) async {
    for (final Category c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> upsert(Category category) async {
    final int idx = _items.indexWhere((Category c) => c.id == category.id);
    if (idx >= 0) {
      _items[idx] = category;
    } else {
      _items.add(category);
    }
    _ctrl.add(List<Category>.unmodifiable(_items));
  }

  @override
  Future<void> softDelete(Ulid id) async {
    _items.removeWhere((Category c) => c.id == id);
    _ctrl.add(List<Category>.unmodifiable(_items));
  }
}
