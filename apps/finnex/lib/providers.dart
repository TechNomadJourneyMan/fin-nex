// App-level Riverpod provider overrides.
//
// Most feature packages ship in-memory stub implementations that satisfy
// their repository contracts so the app boots and renders end-to-end on
// Web before the real Drift/API layers are wired. A few feature providers
// (transactions, analytics) deliberately throw [UnimplementedError] in
// their defaults; this file supplies the cross-feature glue.
//
// As real implementations land in `fnx_data_local` / `fnx_data_sync` /
// `fnx_data_api`, replace the in-memory stubs below with concrete
// constructors.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:fnx_feat_analytics/analytics.dart' as analytics;
import 'package:fnx_feat_insights/fnx_feat_insights.dart' as insights;
import 'package:fnx_feat_notifications/fnx_feat_notifications.dart'
    as notifications;
import 'package:fnx_feat_transactions/transactions.dart' as transactions;

/// The placeholder signed-in user ULID used until real auth is wired.
///
/// All feature `currentUserIdProvider` variants are overridden to this value
/// so streams resolve to the same in-memory data set.
final Ulid kDemoUserId = Ulid('00000000000000000000000001');

/// Cross-feature provider overrides applied at app bootstrap.
///
/// Pass these to [ProviderScope.overrides] so all features share a single
/// in-memory data set instead of throwing UnimplementedError on first read.
List<Override> buildAppProviderOverrides() {
  final _InMemoryTxRepo txRepo = _InMemoryTxRepo();
  final _InMemoryAccountsRepo accountsRepo = _InMemoryAccountsRepo();
  final _InMemoryCategoriesRepo categoriesRepo = _InMemoryCategoriesRepo();

  return <Override>[
    // Transactions feature
    transactions.currentUserIdProvider.overrideWithValue(kDemoUserId),
    transactions.transactionsRepositoryProvider.overrideWithValue(txRepo),
    transactions.accountsRepositoryProvider.overrideWithValue(accountsRepo),
    transactions.categoriesRepositoryProvider
        .overrideWithValue(categoriesRepo),

    // Analytics feature
    analytics.analyticsCurrentUserIdProvider.overrideWithValue(kDemoUserId),
    analytics.analyticsTransactionsRepositoryProvider.overrideWithValue(txRepo),
    analytics.analyticsCategoriesRepositoryProvider
        .overrideWithValue(categoriesRepo),

    // Notifications feature
    notifications.notificationsUserIdProvider.overrideWithValue(kDemoUserId),

    // Insights feature
    insights.insightsUserIdProvider.overrideWithValue(kDemoUserId),
  ];
}

/// Minimal in-memory transactions repository used until `fnx_data_local`
/// is wired. Satisfies the contract enough for the UI to compile and run.
// TODO(F-DATA-WIRE): replace with the Drift-backed implementation from
// `fnx_data_local` (wrapped by `fnx_data_sync`).
class _InMemoryTxRepo implements TransactionsRepository {
  final List<Transaction> _items = <Transaction>[];
  final StreamController<List<Transaction>> _controller =
      StreamController<List<Transaction>>.broadcast();

  void _emit() => _controller.add(List<Transaction>.unmodifiable(_items));

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) async* {
    yield List<Transaction>.unmodifiable(_items);
    yield* _controller.stream;
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

class _InMemoryAccountsRepo implements AccountsRepository {
  final List<Account> _items = <Account>[];
  final StreamController<List<Account>> _controller =
      StreamController<List<Account>>.broadcast();

  void _emit() => _controller.add(List<Account>.unmodifiable(_items));

  @override
  Stream<List<Account>> watchAll(Ulid userId) async* {
    yield List<Account>.unmodifiable(_items);
    yield* _controller.stream;
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
  Future<void> upsert(Account a) async {
    final int idx = _items.indexWhere((Account x) => x.id == a.id);
    if (idx >= 0) {
      _items[idx] = a;
    } else {
      _items.add(a);
    }
    _emit();
  }

  @override
  Future<void> softDelete(Ulid id) async {
    _items.removeWhere((Account a) => a.id == id);
    _emit();
  }
}

class _InMemoryCategoriesRepo implements CategoriesRepository {
  final List<Category> _items = <Category>[];
  final StreamController<List<Category>> _controller =
      StreamController<List<Category>>.broadcast();

  void _emit() => _controller.add(List<Category>.unmodifiable(_items));

  @override
  Stream<List<Category>> watchAll(Ulid userId) async* {
    yield List<Category>.unmodifiable(_items);
    yield* _controller.stream;
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
  Future<void> upsert(Category c) async {
    final int idx = _items.indexWhere((Category x) => x.id == c.id);
    if (idx >= 0) {
      _items[idx] = c;
    } else {
      _items.add(c);
    }
    _emit();
  }

  @override
  Future<void> softDelete(Ulid id) async {
    _items.removeWhere((Category c) => c.id == id);
    _emit();
  }
}
