// App-level Riverpod provider overrides.
//
// Wires the sqflite-backed [AppDataModule] into the feature packages so the
// app runs on real persisted data instead of the in-memory stubs that
// shipped with v0.1.
//
// Bootstrap order (see main.dart):
//   1. WidgetsFlutterBinding.ensureInitialized()
//   2. AppDataModule.open(...)
//   3. runApp(ProviderScope(overrides: buildAppProviderOverrides(module), ...))

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:fnx_feat_ai_chat/fnx_feat_ai_chat.dart' as ai_chat;
import 'package:fnx_feat_analytics/analytics.dart' as analytics;
import 'package:fnx_feat_dashboard/dashboard.dart' as dashboard;
import 'package:fnx_feat_insights/fnx_feat_insights.dart' as insights;
import 'package:fnx_feat_notifications/fnx_feat_notifications.dart'
    as notifications;
import 'package:fnx_feat_subscriptions/subscriptions.dart' as subs;
import 'package:fnx_feat_transactions/transactions.dart' as transactions;

import 'app_data.dart';
import 'demo_seed.dart';

/// The placeholder signed-in user ULID used until real auth is wired.
///
/// All feature `currentUserIdProvider` variants are overridden to this value
/// so streams resolve to the same persisted data set.
final Ulid kDemoUserId = Ulid('00000000000000000000000001');

/// Cross-feature provider overrides applied at app bootstrap.
///
/// Pass these to [ProviderScope.overrides] so all features share a single
/// sqflite-backed data set via [AppDataModule].
List<Override> buildAppProviderOverrides(AppDataModule module) {
  final TransactionsRepository txRepo = module.transactions;
  final AccountsRepository accountsRepo = module.accounts;
  final CategoriesRepository categoriesRepo = module.categories;

  return <Override>[
    // Transactions feature
    transactions.currentUserIdProvider.overrideWithValue(kDemoUserId),
    transactions.transactionsRepositoryProvider.overrideWithValue(txRepo),
    transactions.accountsRepositoryProvider.overrideWithValue(accountsRepo),
    transactions.categoriesRepositoryProvider
        .overrideWithValue(categoriesRepo),

    // Analytics feature
    analytics.analyticsCurrentUserIdProvider.overrideWithValue(kDemoUserId),
    analytics.analyticsTransactionsRepositoryProvider.overrideWithValue(txRepo),
    analytics.analyticsCategoriesRepositoryProvider
        .overrideWithValue(categoriesRepo),

    // Dashboard feature — the home screen has its OWN provider set that is
    // not derived from the transactions/analytics providers, so wire each
    // explicitly to the same persisted module.
    dashboard.dashboardUserIdProvider.overrideWithValue(kDemoUserId),
    dashboard.dashboardAccountsRepositoryProvider.overrideWithValue(accountsRepo),
    dashboard.dashboardTransactionsRepositoryProvider.overrideWithValue(txRepo),
    dashboard.dashboardCategoriesRepositoryProvider
        .overrideWithValue(categoriesRepo),
    dashboard.dashboardAnalyticsRepositoryProvider
        .overrideWithValue(module.analytics),

    // Notifications feature
    notifications.notificationsUserIdProvider.overrideWithValue(kDemoUserId),

    // Insights feature
    insights.insightsUserIdProvider.overrideWithValue(kDemoUserId),

    // Subscriptions (F-04) — seeded in-memory repository so the manager page
    // has something to show until a real backend feed lands.
    subs.subscriptionsUserIdProvider.overrideWithValue(kDemoUserId),
    subs.detectedSubscriptionsRepositoryProvider.overrideWithValue(
      subs.InMemoryDetectedSubscriptionsRepository(
        buildDemoSubscriptions(kDemoUserId),
      ),
    ),

    // AI-CFO chat (F-07) — fake stream service for preview, no backend.
    ai_chat.aiChatServiceProvider.overrideWithValue(
      const ai_chat.FakeAiChatService(),
    ),
  ];
}
