// Riverpod providers for the PocketFlow dashboard feature.
//
// The dashboard depends on three domain repositories — accounts,
// transactions, and analytics. Each is exposed as a `Provider` so the app
// layer can override them with the concrete `pf_data_local` / API
// implementations. The defaults below are in-memory stubs that satisfy
// the contracts and let the feature render in isolation (e.g. golden
// tests, storybook, web preview).
//
// TODO(F-DASH-WIRE): replace the stubs in `apps/finnex/lib/main.dart`
// with the real repos from `pf_data_local`.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/pf_domain.dart';

import 'controllers/dashboard_controller.dart';
import 'data/_stub_repositories.dart';

/// Provides the [AccountsRepository] used by the dashboard.
///
/// Override in the app composition root with the real implementation
/// from `pf_data_local`.
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

// ---------------------------------------------------------------------------
// First-run demo banner
//
// These three providers are intentionally abstract: the dashboard package has
// no access to SharedPreferences or the app's DemoSeedService. The app
// composition root (apps/finnex/lib/providers.dart) overrides them with the
// real implementation. The defaults keep the banner hidden so the feature
// renders cleanly in isolation (previews / golden tests).
// ---------------------------------------------------------------------------

/// Whether the dismissable demo banner should be shown. Resolves to
/// `hasSeeded && !dismissed`. Defaults to `false` (hidden).
final demoBannerVisibleProvider = FutureProvider<bool>((ref) async => false);

/// Soft-deletes the demo transactions and resets the demo flags. Overridden
/// by the app to call `DemoSeedService.clearDemo`. Default is a no-op.
final demoBannerClearProvider = Provider<Future<void> Function()>(
  (ref) => () async {},
);

/// Persists the banner-dismissed flag (the "×" action). Overridden by the app.
/// Default is a no-op.
final demoBannerDismissProvider = Provider<Future<void> Function()>(
  (ref) => () async {},
);
