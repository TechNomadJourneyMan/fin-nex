import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_data_local/fnx_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // sqflite has no Flutter plugin binding in unit tests, so we wire the
  // FFI factory and use an in-memory database.
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('FnxDatabase (in-memory)', () {
    late FnxDatabase db;

    setUp(() async {
      db = await FnxDatabase.openInMemory(factory: databaseFactoryFfi);
    });

    tearDown(() async {
      await db.close();
    });

    test('seeds 28 system categories on first open', () async {
      final dao = CategoriesDao(db);
      expect(await dao.countSystem(), 28);
      final all = await dao.listSystem();
      final ids = all.map((c) => c.id).toSet();
      expect(ids, contains('food_groceries'));
      expect(ids, contains('income_salary'));
      expect(ids, contains('transfer_internal'));
    });

    test('insert + read + filter a transaction', () async {
      const userId = '01HXKVUSER00000000000000AA';
      const accountId = '01HXKVACC00000000000000AA';
      final account = AccountRow(
        id: accountId,
        userId: userId,
        typeCode: 'cash',
        name: 'Кошелёк',
        currency: 'KZT',
        initialBalanceMinor: 0,
        clientId: accountId,
        createdAt: DateTime.utc(2026, 5, 1),
        updatedAt: DateTime.utc(2026, 5, 1),
        syncState: SyncState.pending,
        version: 1,
        dirty: true,
      );
      await AccountsDao(db).upsert(account);

      final txDao = TransactionsDao(db);
      final tx = TransactionRow(
        id: '01HXKVTX0000000000000001AA',
        userId: userId,
        accountId: accountId,
        typeCode: 'expense',
        categoryId: 'food_groceries',
        amountMinor: 250000,
        currency: 'KZT',
        occurredAt: DateTime.utc(2026, 5, 15, 12, 0),
        clientId: '01HXKVTX0000000000000001AA',
        createdAt: DateTime.utc(2026, 5, 15, 12, 0),
        updatedAt: DateTime.utc(2026, 5, 15, 12, 0),
        syncState: SyncState.pending,
        version: 1,
        dirty: true,
      );
      await txDao.upsert(tx);

      final fetched = await txDao.getById(tx.id);
      expect(fetched, isNotNull);
      expect(fetched!.amountMinor, 250000);
      expect(fetched.categoryId, 'food_groceries');

      final inMay = await txDao.listForUser(
        userId,
        from: DateTime.utc(2026, 5, 1),
        to: DateTime.utc(2026, 5, 31, 23, 59, 59),
      );
      expect(inMay, hasLength(1));

      final sum = await txDao.sumForUser(
        userId,
        typeCode: 'expense',
        from: DateTime.utc(2026, 5, 1),
        to: DateTime.utc(2026, 5, 31, 23, 59, 59),
      );
      expect(sum, 250000);

      // Soft-delete removes from default listing.
      await txDao.softDelete(tx.id);
      final stillThere = await txDao.listForUser(userId);
      expect(stillThere, isEmpty);
      final includingDeleted =
          await txDao.listForUser(userId, includeDeleted: true);
      expect(includingDeleted, hasLength(1));
      expect(includingDeleted.first.deletedAt, isNotNull);
    });

    test('AccountsDao.recomputeBalance sums income and expense', () async {
      const userId = '01HXKVUSER00000000000000BB';
      const accountId = '01HXKVACC00000000000000BB';
      await AccountsDao(db).upsert(AccountRow(
        id: accountId,
        userId: userId,
        typeCode: 'debit_card',
        name: 'Kaspi Gold',
        currency: 'KZT',
        initialBalanceMinor: 100000,
        clientId: accountId,
        createdAt: DateTime.utc(2026, 5, 1),
        updatedAt: DateTime.utc(2026, 5, 1),
        syncState: SyncState.synced,
        version: 1,
        dirty: false,
      ));
      final txDao = TransactionsDao(db);
      await txDao.upsert(TransactionRow(
        id: '01HXKVTX0000000000000010BB',
        userId: userId,
        accountId: accountId,
        typeCode: 'income',
        categoryId: 'income_salary',
        amountMinor: 500000,
        currency: 'KZT',
        occurredAt: DateTime.utc(2026, 5, 5),
        clientId: '01HXKVTX0000000000000010BB',
        createdAt: DateTime.utc(2026, 5, 5),
        updatedAt: DateTime.utc(2026, 5, 5),
        syncState: SyncState.pending,
        version: 1,
        dirty: true,
      ));
      await txDao.upsert(TransactionRow(
        id: '01HXKVTX0000000000000011BB',
        userId: userId,
        accountId: accountId,
        typeCode: 'expense',
        categoryId: 'food_groceries',
        amountMinor: 75000,
        currency: 'KZT',
        occurredAt: DateTime.utc(2026, 5, 10),
        clientId: '01HXKVTX0000000000000011BB',
        createdAt: DateTime.utc(2026, 5, 10),
        updatedAt: DateTime.utc(2026, 5, 10),
        syncState: SyncState.pending,
        version: 1,
        dirty: true,
      ));

      final balance = await AccountsDao(db).recomputeBalance(accountId);
      expect(balance, 100000 + 500000 - 75000);
    });

    test('SyncQueueDao FIFO and status transitions', () async {
      final dao = SyncQueueDao(db);
      final id = await dao.enqueue(SyncQueueRow(
        entityTable: 'transactions',
        entityId: '01HXKVTX0000000000000099AA',
        op: SyncOp.upsert,
        payload: '{"amount_minor":1000}',
        enqueuedAt: DateTime.utc(2026, 5, 31),
      ));
      expect(id, greaterThan(0));
      final pending = await dao.pending();
      expect(pending, hasLength(1));
      await dao.markInFlight(id);
      await dao.markDone(id);
      expect(await dao.pending(), isEmpty);
    });

    test('Repository implementations satisfy contracts', () async {
      final txRepo = TransactionsRepositoryImpl(TransactionsDao(db));
      final acctRepo = AccountsRepositoryImpl(AccountsDao(db));
      final catRepo = CategoriesRepositoryImpl(CategoriesDao(db));
      final budgetRepo = BudgetsRepositoryImpl(BudgetsDao(db));
      final settingsRepo = SettingsRepositoryImpl(SettingsDao(db));

      expect(txRepo, isA<TransactionsRepository>());
      expect(acctRepo, isA<AccountsRepository>());
      expect(catRepo, isA<CategoriesRepository>());
      expect(budgetRepo, isA<BudgetsRepository>());
      expect(settingsRepo, isA<SettingsRepository>());

      const userId = '01HXKVUSER00000000000000CC';
      final cats = await catRepo.list(userId, typeCode: 'expense');
      expect(cats.where((c) => c.isSystem).length, greaterThan(20));
    });
  });
}
