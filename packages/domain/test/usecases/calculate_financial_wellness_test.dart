import 'package:pf_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_fixtures.dart';

class _MockAnalytics extends Mock implements AnalyticsRepository {}

void main() {
  late _MockAnalytics analytics;
  late CalculateFinancialWellness uc;

  setUp(() {
    analytics = _MockAnalytics();
    uc = CalculateFinancialWellness(analytics);
  });

  Future<int> scoreFor(double rate) async {
    when(() => analytics.dashboardSummary(Fixtures.userId)).thenAnswer(
      (_) async => DashboardSummary(
        netWorth: Fixtures.kzt(0),
        incomeMonth: Fixtures.kzt(100),
        expenseMonth: Fixtures.kzt(0),
        savingsRate: rate,
      ),
    );
    return uc.call(Fixtures.userId);
  }

  test('1.0 savings rate -> 100', () async {
    expect(await scoreFor(1.0), 100);
  });

  test('0.0 savings rate -> 50', () async {
    expect(await scoreFor(0.0), 50);
  });

  test('-1.0 savings rate -> 0', () async {
    expect(await scoreFor(-1.0), 0);
  });

  test('out-of-range clamps', () async {
    expect(await scoreFor(2.0), 100);
    expect(await scoreFor(-5.0), 0);
  });
}
