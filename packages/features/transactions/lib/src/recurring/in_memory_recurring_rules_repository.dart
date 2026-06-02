// Volatile, in-memory implementation of [RecurringRulesRepository].
//
// Consistent with the app's current in-memory pattern (see
// InMemoryDetectedSubscriptionsRepository). Persistence is tracked under
// F-DATA-WIRE and is out of scope for this phase.

import 'dart:async';

import 'package:pf_domain/pf_domain.dart';

/// Simple in-process [RecurringRulesRepository].
class InMemoryRecurringRulesRepository implements RecurringRulesRepository {
  /// Creates a repository optionally seeded with [seed].
  InMemoryRecurringRulesRepository([
    List<RecurringRule> seed = const <RecurringRule>[],
  ]) : _rules = List<RecurringRule>.of(seed);

  final List<RecurringRule> _rules;
  final StreamController<List<RecurringRule>> _ctrl =
      StreamController<List<RecurringRule>>.broadcast();

  void _emit() => _ctrl.add(List<RecurringRule>.unmodifiable(_rules));

  @override
  Stream<List<RecurringRule>> watchAll(Ulid userId) async* {
    yield List<RecurringRule>.unmodifiable(
      _rules.where((RecurringRule r) => r.userId == userId).toList(),
    );
    yield* _ctrl.stream.map(
      (List<RecurringRule> list) =>
          list.where((RecurringRule r) => r.userId == userId).toList(),
    );
  }

  @override
  Future<List<RecurringRule>> list(Ulid userId) async => _rules
      .where((RecurringRule r) => r.userId == userId)
      .toList(growable: false);

  @override
  Future<RecurringRule?> getById(Ulid id) async {
    for (final RecurringRule r in _rules) {
      if (r.id == id) {
        return r;
      }
    }
    return null;
  }

  @override
  Future<void> upsert(RecurringRule rule) async {
    final int i = _rules.indexWhere((RecurringRule r) => r.id == rule.id);
    if (i >= 0) {
      _rules[i] = rule;
    } else {
      _rules.add(rule);
    }
    _emit();
  }

  @override
  Future<void> delete(Ulid id) async {
    _rules.removeWhere((RecurringRule r) => r.id == id);
    _emit();
  }

  /// Releases the broadcast controller.
  Future<void> dispose() async {
    await _ctrl.close();
  }
}
