// Volatile, in-memory implementation of [BudgetsRepository].
//
// Web-safe; used as the default until the data layer wires real persistence.

import 'dart:async';

import 'package:fnx_domain/domain.dart';

/// Simple in-process [BudgetsRepository].
class InMemoryBudgetsRepository implements BudgetsRepository {
  /// Creates an empty repository.
  InMemoryBudgetsRepository();

  final List<Budget> _budgets = <Budget>[];
  final List<Limit> _limits = <Limit>[];
  final StreamController<List<Budget>> _budgetCtrl =
      StreamController<List<Budget>>.broadcast();
  final StreamController<List<Limit>> _limitCtrl =
      StreamController<List<Limit>>.broadcast();

  void _emitBudgets() =>
      _budgetCtrl.add(List<Budget>.unmodifiable(_active(_budgets)));

  void _emitLimits() =>
      _limitCtrl.add(List<Limit>.unmodifiable(_activeLimits(_limits)));

  List<Budget> _active(List<Budget> src) =>
      src.where((b) => b.deletedAt == null).toList();

  List<Limit> _activeLimits(List<Limit> src) =>
      src.where((l) => l.deletedAt == null).toList();

  @override
  Stream<List<Budget>> watchBudgets(Ulid userId) async* {
    yield List<Budget>.unmodifiable(_active(_budgets));
    yield* _budgetCtrl.stream;
  }

  @override
  Future<List<Budget>> listBudgets(Ulid userId) async =>
      List<Budget>.unmodifiable(_active(_budgets));

  @override
  Future<void> upsertBudget(Budget budget) async {
    final i = _budgets.indexWhere((b) => b.id == budget.id);
    if (i >= 0) {
      _budgets[i] = budget;
    } else {
      _budgets.add(budget);
    }
    _emitBudgets();
  }

  @override
  Future<void> softDeleteBudget(Ulid id) async {
    final i = _budgets.indexWhere((b) => b.id == id);
    if (i < 0) {
      return;
    }
    _budgets[i] = _budgets[i].copyWith(deletedAt: DateTime.now().toUtc());
    _emitBudgets();
  }

  @override
  Stream<List<Limit>> watchLimits(Ulid userId) async* {
    yield List<Limit>.unmodifiable(_activeLimits(_limits));
    yield* _limitCtrl.stream;
  }

  @override
  Future<List<Limit>> listLimits(Ulid userId) async =>
      List<Limit>.unmodifiable(_activeLimits(_limits));

  @override
  Future<void> upsertLimit(Limit limit) async {
    final i = _limits.indexWhere((l) => l.id == limit.id);
    if (i >= 0) {
      _limits[i] = limit;
    } else {
      _limits.add(limit);
    }
    _emitLimits();
  }

  @override
  Future<void> softDeleteLimit(Ulid id) async {
    final i = _limits.indexWhere((l) => l.id == id);
    if (i < 0) {
      return;
    }
    _limits[i] = _limits[i].copyWith(deletedAt: DateTime.now().toUtc());
    _emitLimits();
  }

  /// Releases broadcast controllers.
  Future<void> dispose() async {
    await _budgetCtrl.close();
    await _limitCtrl.close();
  }
}
