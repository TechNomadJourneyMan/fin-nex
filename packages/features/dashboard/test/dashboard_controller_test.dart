// Smoke tests for [DashboardController].

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_dashboard/dashboard.dart';

void main() {
  group('DashboardController', () {
    test('loads an initial snapshot using the stub repositories', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final snap = await container.read(dashboardControllerProvider.future);

      expect(snap.recent, isNotEmpty);
      expect(snap.topCategories, isNotEmpty);
      expect(snap.period, DashboardPeriod.month);
      expect(snap.totalBalance.minor > BigInt.zero, isTrue);
    });

    test('setPeriod swaps the active period and reloads', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(dashboardControllerProvider.future);
      await container
          .read(dashboardControllerProvider.notifier)
          .setPeriod(DashboardPeriod.today);

      final snap = await container.read(dashboardControllerProvider.future);
      expect(snap.period, DashboardPeriod.today);
    });

    test('setPeriod with same value is a no-op', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(dashboardControllerProvider.future);
      final before = container.read(dashboardControllerProvider);
      await container
          .read(dashboardControllerProvider.notifier)
          .setPeriod(DashboardPeriod.month);
      final after = container.read(dashboardControllerProvider);
      // Reference equality on the AsyncValue is acceptable for a no-op.
      expect(identical(before, after), isTrue);
    });
  });
}
