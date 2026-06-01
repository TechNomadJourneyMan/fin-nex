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

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart' as feedback;
import 'package:pf_data_api/pf_data_api.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_ai_chat/pf_feat_ai_chat.dart' as ai_chat;
import 'package:pf_feat_analytics/analytics.dart' as analytics;
import 'package:pf_feat_dashboard/dashboard.dart' as dashboard;
import 'package:pf_feat_insights/pf_feat_insights.dart' as insights;
import 'package:pf_feat_notifications/pf_feat_notifications.dart'
    as notifications;
import 'package:pf_feat_auth/auth.dart' as auth;
import 'package:pf_feat_subscriptions/subscriptions.dart' as subs;
import 'package:pf_feat_transactions/transactions.dart' as transactions;
import 'package:pf_local_llm/pf_local_llm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_data.dart';
// demo_seed.dart and onboarding/demo_seed_service.dart imports removed —
// the app no longer ships any mock data. Only persisted user data.
import 'services/auth_session_store.dart';
import 'services/device_id_provider.dart';

/// The placeholder signed-in user ULID used until real auth is wired.
///
/// All feature `currentUserIdProvider` variants are overridden to this value
/// so streams resolve to the same persisted data set.
final Ulid kDemoUserId = Ulid('00000000000000000000000001');

// ---------------------------------------------------------------------------
// On-device LLM (pf_local_llm) — Gemma via flutter_gemma on mobile/desktop,
// no-op stub on Web. The local-LLM settings/playground page reads this.
// ---------------------------------------------------------------------------

/// Singleton [LocalLlmService] for the running platform.
///
/// Built once via [defaultLocalLlmService] (kIsWeb → no-op stub, otherwise the
/// Gemma-backed service). The service holds native model/session handles, so a
/// single instance is shared across the app and disposed with the container.
final Provider<LocalLlmService> localLlmServiceProvider =
    Provider<LocalLlmService>((Ref ref) {
  final LocalLlmService service = defaultLocalLlmService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// Auth wiring — HttpAuthRepository → backend /v1/auth/*
// ---------------------------------------------------------------------------

/// Holds the [SharedPreferences] instance used for token + device-id storage.
///
/// Overridden at bootstrap (see main.dart). Reading it before the override is
/// installed throws, which is intentional — the app must hydrate prefs first.
final sharedPreferencesProvider = Provider<SharedPreferences>((Ref ref) {
  throw StateError(
    'sharedPreferencesProvider must be overridden at app bootstrap.',
  );
});

/// Persistent auth-token store (access + refresh + expiry).
final authSessionStoreProvider =
    StateNotifierProvider<AuthSessionStore, AuthSessionTokens?>((Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthSessionStore(prefs)..hydrate();
});

/// Stable per-install device id (ULID) for the `X-Device-Id` header.
final deviceIdProvider = Provider<DeviceIdStore>((Ref ref) {
  return DeviceIdStore(ref.watch(sharedPreferencesProvider));
});

/// API base URL, overridable at build time:
///   --dart-define=POCKET_FLOW_API_BASE=https://api.example.com
const String kApiBaseUrl = String.fromEnvironment(
  'POCKET_FLOW_API_BASE',
  defaultValue: 'http://localhost:3000/v1',
);

/// Authenticated [Dio] wired to the backend with the PocketFlow interceptor stack
/// (auth header, device id, idempotency, retry, problem-details).
final authedDioProvider = Provider<Dio>((Ref ref) {
  final store = ref.watch(authSessionStoreProvider.notifier);
  final deviceIds = ref.watch(deviceIdProvider);
  return DioFactory.create(
    config: const ApiConfig(baseUrl: kApiBaseUrl),
    getAccessToken: store.getAccessToken,
    onRefresh: () async {
      // TODO(F-AUTH-REFRESH): exchange the refresh token for a new access
      // token via AuthService(refreshDio).refresh(...) and update the store.
      // Until that lands we return the current (possibly stale) access token,
      // forcing the user to re-authenticate when it expires.
      return store.getAccessToken();
    },
    getDeviceId: deviceIds.getDeviceId,
  );
});

/// Backend-backed [AuthRepository] persisting tokens into
/// [authSessionStoreProvider].
final httpAuthRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final dio = ref.watch(authedDioProvider);
  final store = ref.watch(authSessionStoreProvider.notifier);
  final repo = HttpAuthRepository(
    AuthService(dio),
    onPersist: (AuthSession session) => store.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
    ),
    onClear: store.clear,
  );
  ref.onDispose(repo.dispose);
  return repo;
});

// ---------------------------------------------------------------------------
// Feedback (haptics + sound)
// ---------------------------------------------------------------------------

/// Singleton [FeedbackService] backed by [sharedPreferencesProvider].
///
/// Holds platform audio players keyed by asset, so it must outlive any
/// single page. Disposed with the container.
final Provider<feedback.FeedbackService> feedbackServiceProvider =
    Provider<feedback.FeedbackService>((Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final feedback.FeedbackService svc = feedback.FeedbackService(prefs: prefs);
  ref.onDispose(svc.dispose);
  return svc;
});

/// Bootstrap override wiring the package-level
/// `feedback.feedbackServiceProvider` (the one feature modules import) to the
/// app singleton.
final Override feedbackServiceOverride =
    feedback.feedbackServiceProvider.overrideWith(
  (Ref ref) => ref.watch(feedbackServiceProvider),
);

/// Override that swaps the auth feature's in-memory stub repository for the
/// backend-backed [httpAuthRepositoryProvider].
///
/// Only safe to install once [sharedPreferencesProvider] is overridden, since
/// the repository's token store depends on it. The bootstrap sequence guards
/// this (see main.dart).
final Override authRepositoryOverride =
    auth.authRepositoryProvider.overrideWith(
  (Ref ref) => ref.watch(httpAuthRepositoryProvider),
);

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
    transactions.categoriesRepositoryProvider.overrideWithValue(categoriesRepo),

    // Analytics feature
    analytics.analyticsCurrentUserIdProvider.overrideWithValue(kDemoUserId),
    analytics.analyticsTransactionsRepositoryProvider.overrideWithValue(txRepo),
    analytics.analyticsCategoriesRepositoryProvider
        .overrideWithValue(categoriesRepo),

    // Dashboard feature — the home screen has its OWN provider set that is
    // not derived from the transactions/analytics providers, so wire each
    // explicitly to the same persisted module.
    dashboard.dashboardUserIdProvider.overrideWithValue(kDemoUserId),
    dashboard.dashboardAccountsRepositoryProvider
        .overrideWithValue(accountsRepo),
    dashboard.dashboardTransactionsRepositoryProvider.overrideWithValue(txRepo),
    dashboard.dashboardCategoriesRepositoryProvider
        .overrideWithValue(categoriesRepo),
    dashboard.dashboardAnalyticsRepositoryProvider
        .overrideWithValue(module.analytics),

    // Demo banner is force-hidden — demo mode has been removed app-wide.
    dashboard.demoBannerVisibleProvider.overrideWith((ref) async => false),

    // Notifications feature
    notifications.notificationsUserIdProvider.overrideWithValue(kDemoUserId),

    // Insights feature
    insights.insightsUserIdProvider.overrideWithValue(kDemoUserId),

    // Subscriptions (F-04) — empty repository. Real entries will appear
    // once the subscription detector runs against the user's persisted
    // transactions. No demo data.
    subs.subscriptionsUserIdProvider.overrideWithValue(kDemoUserId),
    subs.detectedSubscriptionsRepositoryProvider.overrideWithValue(
      subs.InMemoryDetectedSubscriptionsRepository(),
    ),

    // AI-CFO chat (F-07) — fake stream service for preview, no backend.
    ai_chat.aiChatServiceProvider.overrideWithValue(
      const ai_chat.FakeAiChatService(),
    ),
  ];
}
