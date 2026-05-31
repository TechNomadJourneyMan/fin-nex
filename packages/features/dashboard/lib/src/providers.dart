// Riverpod providers for the FinNex dashboard feature.
//
// The dashboard depends on three domain repositories — accounts,
// transactions, and analytics. Each is exposed as a `Provider` so the app
// layer can override them with the concrete `fnx_data_local` / API
// implementations. The defaults below are in-memory stubs that satisfy
// the contracts and let the feature render in isolation (e.g. golden
// tests, storybook, web preview).
//
// TODO(F-DASH-WIRE): replace the stubs in `apps/finnex/lib/main.dart`
// with the real repos from `fnx_data_local`.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/fnx_domain.dart';

import 'controllers/dashboard_controller.dart';
import 'data/_stub_repositories.dart';

/// Provides the [AccountsRepository] used by the dashboard.
///
/// Override in the app composition root with the real implementation
/// from `fnx_data_local`.
final dashboardAccountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return StubAccountsRepository();
});

/// Provides the [TransactionsRepository] used by the dashboard.
final dashboardTransactionsRepositoryProvider =
    Provider<TransactionsRepository>((ref) {
  return StubTransactionsRepository();
});

/// Provides the [AnalyticsRepository] used by the dashboard.
final dashboardAnalyticsRepositoryProvider = Provider<AnalyticsRepository>((
  ref,
) {
  return StubAnalyticsRepository();
});

/// Provides the [CategoriesRepository] used by the dashboard.
final dashboardCategoriesRepositoryProvider =
    Provider<CategoriesRepository>((ref) {
  return StubCategoriesRepository();
});

/// The currently active user-id for the dashboard.
///
/// Defaults to a deterministic placeholder so the page can render before
/// auth is wired. The auth feature should override this provider.
final dashboardUserIdProvider = Provider<Ulid>((ref) {
  return Ulid('00000000000000000000000000');
});

/// AsyncNotifierProvider that aggregates everything the dashboard needs.
final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardSnapshot>(
  DashboardController.new,
);
