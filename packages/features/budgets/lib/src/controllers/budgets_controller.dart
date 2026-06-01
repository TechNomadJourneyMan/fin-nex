// AsyncNotifier controller for the budgets list.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/domain.dart';

import '../providers.dart';

/// AsyncNotifier-backed list of active budgets for the current user.
class BudgetsController extends AsyncNotifier<List<Budget>> {
  late BudgetsRepository _repo;
  late Ulid _userId;

  @override
  Future<List<Budget>> build() async {
    _repo = ref.watch(budgetsRepositoryProvider);
    _userId = ref.watch(budgetsCurrentUserIdProvider);
    final sub = _repo.watchBudgets(_userId).listen((items) {
      state = AsyncData<List<Budget>>(items);
    });
    ref.onDispose(sub.cancel);
    return _repo.listBudgets(_userId);
  }

  /// Creates a new budget.
  Future<Budget> create({
    required String name,
    required BudgetPeriod period,
    required Money amount,
    required List<Ulid> categoryIds,
    required List<int> alertThresholds,
    DateTime? startsOn,
    DateTime? endsOn,
  }) async {
    final now = DateTime.now().toUtc();
    final budget = Budget(
      id: Ulid.now(),
      userId: _userId,
      name: name,
      period: period,
      amount: amount,
      categoryIds: categoryIds,
      alertThresholds: alertThresholds,
      rolloverUnspent: false,
      isActive: true,
      startsOn: startsOn ?? now,
      endsOn: endsOn,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.upsertBudget(budget);
    return budget;
  }

  /// Replaces an existing budget.
  Future<void> upsert(Budget budget) => _repo.upsertBudget(budget);

  /// Soft-deletes [id].
  Future<void> remove(Ulid id) => _repo.softDeleteBudget(id);
}

/// Provider exposing [BudgetsController].
final budgetsControllerProvider =
    AsyncNotifierProvider<BudgetsController, List<Budget>>(
  BudgetsController.new,
);

/// AsyncNotifier-backed list of active limits.
class LimitsController extends AsyncNotifier<List<Limit>> {
  late BudgetsRepository _repo;
  late Ulid _userId;

  @override
  Future<List<Limit>> build() async {
    _repo = ref.watch(budgetsRepositoryProvider);
    _userId = ref.watch(budgetsCurrentUserIdProvider);
    final sub = _repo.watchLimits(_userId).listen((items) {
      state = AsyncData<List<Limit>>(items);
    });
    ref.onDispose(sub.cancel);
    return _repo.listLimits(_userId);
  }

  /// Inserts or updates [limit].
  Future<void> upsert(Limit limit) => _repo.upsertLimit(limit);

  /// Soft-deletes [id].
  Future<void> remove(Ulid id) => _repo.softDeleteLimit(id);
}

/// Provider exposing [LimitsController].
final limitsControllerProvider =
    AsyncNotifierProvider<LimitsController, List<Limit>>(
  LimitsController.new,
);
