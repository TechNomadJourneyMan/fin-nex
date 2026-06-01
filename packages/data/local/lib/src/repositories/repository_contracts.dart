// Minimal repository contracts used by the local persistence layer.
//
// These mirror the (intended) interfaces in `pf_domain`. As of v0.1 the
// domain package only exports its library declaration, so we define the
// contracts here to keep this layer self-contained and testable. When the
// domain package publishes real interfaces, the implementations in this
// folder will switch to `implements` against the domain types.

import '../models/account_row.dart';
import '../models/budget_row.dart';
import '../models/category_row.dart';
import '../models/setting_row.dart';
import '../models/transaction_row.dart';

/// Contract for persisting and querying transactions.
abstract class TransactionsRepository {
  /// Upserts a single transaction.
  Future<void> save(TransactionRow row);

  /// Returns the transaction with [id], or `null` when absent.
  Future<TransactionRow?> findById(String id);

  /// Lists transactions matching the given filters (newest first).
  Future<List<TransactionRow>> list(
    String userId, {
    DateTime? from,
    DateTime? to,
    String? accountId,
    String? categoryId,
    String? typeCode,
    int? limit,
  });

  /// Watches the filtered list of transactions.
  Stream<List<TransactionRow>> watch(
    String userId, {
    DateTime? from,
    DateTime? to,
    String? accountId,
    String? categoryId,
    String? typeCode,
  });

  /// Soft-deletes the transaction.
  Future<void> remove(String id, {String? deviceId});
}

/// Contract for persisting and querying accounts.
abstract class AccountsRepository {
  /// Upserts an account.
  Future<void> save(AccountRow row);

  /// Returns the account with [id], or `null` when absent.
  Future<AccountRow?> findById(String id);

  /// Lists active accounts for [userId].
  Future<List<AccountRow>> list(String userId);

  /// Watches the account list for [userId].
  Stream<List<AccountRow>> watch(String userId);

  /// Soft-deletes the account.
  Future<void> remove(String id, {String? deviceId});

  /// Recomputes the cached balance for [id].
  Future<int> recomputeBalance(String id);
}

/// Contract for persisting and querying categories.
abstract class CategoriesRepository {
  /// Upserts a category.
  Future<void> save(CategoryRow row);

  /// Returns the category with [id], or `null` when absent.
  Future<CategoryRow?> findById(String id);

  /// Lists categories available to [userId] (system + custom).
  Future<List<CategoryRow>> list(String userId, {String? typeCode});

  /// Watches the category list.
  Stream<List<CategoryRow>> watch(String userId, {String? typeCode});

  /// Soft-deletes a custom category.
  Future<void> remove(String id, {String? deviceId});
}

/// Contract for persisting and querying budgets.
abstract class BudgetsRepository {
  /// Upserts a budget.
  Future<void> save(BudgetRow row);

  /// Returns the budget with [id], or `null` when absent.
  Future<BudgetRow?> findById(String id);

  /// Lists budgets for [userId].
  Future<List<BudgetRow>> list(String userId, {bool activeOnly = true});

  /// Watches the budget list.
  Stream<List<BudgetRow>> watch(String userId, {bool activeOnly = true});

  /// Soft-deletes a budget.
  Future<void> remove(String id, {String? deviceId});
}

/// Contract for per-user settings.
abstract class SettingsRepository {
  /// Loads the settings row, or returns `null` when none has been written.
  Future<SettingRow?> get(String userId);

  /// Persists the settings row.
  Future<void> save(SettingRow row);

  /// Watches the settings row.
  Stream<SettingRow?> watch(String userId);
}
