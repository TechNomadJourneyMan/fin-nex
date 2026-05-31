// Application data module.
//
// Owns the local sqflite database, exposes ready-to-use domain repositories
// (adapters bridging the sqflite-shaped repos in `fnx_data_local` to the
// `Ulid`/`Money`-typed contracts in `fnx_domain`).
//
// Created at app bootstrap and held for the app's lifetime; tear down via
// [dispose] when running multiple isolated app instances (tests).

import 'dart:async';

import 'package:fnx_data_local/fnx_data_local.dart' as local;
import 'package:fnx_domain/fnx_domain.dart';

/// Lazily-constructed singleton holding the database and adapter repositories.
class AppDataModule {
  AppDataModule._(
    this._db,
    this.transactions,
    this.accounts,
    this.categories,
  );

  final local.FnxDatabase _db;

  /// Domain-shaped transactions repository backed by sqflite.
  final TransactionsRepository transactions;

  /// Domain-shaped accounts repository backed by sqflite.
  final AccountsRepository accounts;

  /// Domain-shaped categories repository backed by sqflite.
  final CategoriesRepository categories;

  /// Opens the application database, runs first-time seed (default account)
  /// and returns the wired module.
  static Future<AppDataModule> open({
    required Ulid demoUserId,
    bool inMemory = false,
  }) async {
    final local.FnxDatabase db = inMemory
        ? await local.FnxDatabase.openInMemory()
        : await local.FnxDatabase.open();

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

  /// Closes the database.
  Future<void> dispose() => _db.close();

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
  Stream<List<Transaction>> watchAll(Ulid userId) => _repo
      .watch(_ids.ulidToString(userId))
      .map((List<local.TransactionRow> rows) =>
          rows.map(_toDomain).toList(growable: false));

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async {
    final String? accountId = filter.accountIds.isEmpty
        ? null
        : _ids.ulidToString(filter.accountIds.first);
    final String? categoryId = filter.categoryIds.isEmpty
        ? null
        : _ids.ulidToString(filter.categoryIds.first);
    final String? typeCode = filter.types.isEmpty ? null : filter.types.first;
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
  }

  @override
  Future<Transaction?> getById(Ulid id) async {
    final local.TransactionRow? row =
        await _repo.findById(_ids.ulidToString(id));
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> upsert(Transaction tx) => _repo.save(_toRow(tx));

  @override
  Future<void> softDelete(Ulid id) =>
      _repo.remove(_ids.ulidToString(id));
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
  Stream<List<Account>> watchAll(Ulid userId) =>
      _repo.watch(_ids.ulidToString(userId)).map(
            (List<local.AccountRow> rows) =>
                rows.map(_toDomain).toList(growable: false),
          );

  @override
  Future<List<Account>> list(Ulid userId) async {
    final List<local.AccountRow> rows =
        await _repo.list(_ids.ulidToString(userId));
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<Account?> getById(Ulid id) async {
    final local.AccountRow? row =
        await _repo.findById(_ids.ulidToString(id));
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> upsert(Account account) => _repo.save(_toRow(account));

  @override
  Future<void> softDelete(Ulid id) => _repo.remove(_ids.ulidToString(id));
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
  Stream<List<Category>> watchAll(Ulid userId) =>
      _repo.watch(_ids.ulidToString(userId)).map(
            (List<local.CategoryRow> rows) =>
                rows.map(_toDomain).toList(growable: false),
          );

  @override
  Future<List<Category>> list(Ulid userId) async {
    final List<local.CategoryRow> rows =
        await _repo.list(_ids.ulidToString(userId));
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<Category?> getById(Ulid id) async {
    final local.CategoryRow? row =
        await _repo.findById(_ids.ulidToString(id));
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> upsert(Category category) => _repo.save(_toRow(category));

  @override
  Future<void> softDelete(Ulid id) => _repo.remove(_ids.ulidToString(id));
}
