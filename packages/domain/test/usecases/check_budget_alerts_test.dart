import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_fixtures.dart';

class _MockBudgets extends Mock implements BudgetsRepository {}

class _MockAnalytics extends Mock implements AnalyticsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime.utc(2026, 1, 1));
  });

  test('fires when spent crosses the lowest threshold', () async {
    final budgetsRepo = _MockBudgets();
    final analyticsRepo = _MockAnalytics();
    final budget = Fixtures.budget(
      id: Ulid.now(),
      amount: Fixtures.kzt(10000),
      alertThresholds: const <int>[80, 100],
    );

    when(() => budgetsRepo.listBudgets(Fixtures.userId))
        .thenAnswer((_) async => <Budget>[budget]);
    when(
      () => analyticsRepo.categoryBreakdown(
        Fixtures.userId,
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer(
      (_) async => <CategoryBreakdownSlice>[
        CategoryBreakdownSlice(
          categoryId: Fixtures.categoryId,
          amount: Fixtures.kzt(8500),
          percent: 0.85,
        ),
      ],
    );

    final alerts = await CheckBudgetAlerts(budgetsRepo, analyticsRepo).call(
      Fixtures.userId,
      now: DateTime.utc(2026, 5, 31),
    );

    expect(alerts, hasLength(1));
    expect(alerts.single.threshold, 80);
    expect(alerts.single.percent, closeTo(0.85, 0.001));
  });

  test('does not fire below the lowest threshold', () async {
    final budgetsRepo = _MockBudgets();
    final analyticsRepo = _MockAnalytics();
    final budget = Fixtures.budget(
      id: Ulid.now(),
      amount: Fixtures.kzt(10000),
    );

    when(() => budgetsRepo.listBudgets(Fixtures.userId))
        .thenAnswer((_) async => <Budget>[budget]);
    when(
      () => analyticsRepo.categoryBreakdown(
        Fixtures.userId,
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer(
      (_) async => <CategoryBreakdownSlice>[
        CategoryBreakdownSlice(
          categoryId: Fixtures.categoryId,
          amount: Fixtures.kzt(1000),
          percent: 0.1,
        ),
      ],
    );

    final alerts = await CheckBudgetAlerts(budgetsRepo, analyticsRepo).call(
      Fixtures.userId,
      now: DateTime.utc(2026, 5, 31),
    );

    expect(alerts, isEmpty);
  });
}
