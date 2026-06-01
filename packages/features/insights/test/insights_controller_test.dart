import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/domain.dart';
import 'package:pf_feat_insights/pf_feat_insights.dart';

import '_fixtures.dart';

class _FixedDataSource implements InsightsDataSource {
  _FixedDataSource(this._tx, this._budgets);
  final List<Transaction> _tx;
  final List<Budget> _budgets;

  @override
  Future<List<Budget>> budgets() async => _budgets;

  @override
  Future<List<Category>> categories() async => const <Category>[];

  @override
  Future<List<Transaction>> transactions() async => _tx;

  @override
  Future<Streak?> streak() async => null;
}

void main() {
  test('controller regenerates and dismissals remove the insight', () async {
    final now = DateTime.utc(2026, 1, 14, 12);
    final budget = monthlyBudget(
      majorUnits: 1000,
      startsOn: DateTime.utc(2026, 1, 1),
    );
    final tx = <Transaction>[
      expense(majorUnits: 1200, occurredAt: DateTime.utc(2026, 1, 5)),
    ];
    final controller = InsightsController(
      engine: const InsightEngine(),
      dataSource: _FixedDataSource(tx, <Budget>[budget]),
      userId: kTestUser,
      clock: () => now,
      interval: const Duration(days: 365),
    );
    addTearDown(controller.dispose);

    await controller.regenerate();
    expect(controller.state.items, isNotEmpty);

    final firstKind = controller.state.items.first.kind;
    await controller.dismiss(controller.state.items.first);
    expect(
      controller.state.items.any((i) => i.kind == firstKind),
      isFalse,
    );

    // Regenerate again — the dismissed kind should remain suppressed.
    await controller.regenerate();
    expect(
      controller.state.items.any((i) => i.kind == firstKind),
      isFalse,
    );
  });
}
