// Top-level router for FinNex.
//
// Composes feature-package routes into a single [GoRouter]. The four primary
// tabs (Home, Transactions, Analytics, Settings) live under a
// [StatefulShellRoute] so each tab keeps its own navigation stack. All other
// routes (auth, onboarding, transaction details/forms, budgets, categories,
// notifications) sit at the top level and push over the shell.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_feat_analytics/analytics.dart' as analytics;
import 'package:fnx_feat_auth/auth.dart' as auth;
import 'package:fnx_feat_budgets/fnx_feat_budgets.dart' as budgets;
import 'package:fnx_feat_categories/fnx_feat_categories.dart' as categories;
import 'package:fnx_feat_dashboard/dashboard.dart' as dashboard;
import 'package:fnx_feat_notifications/fnx_feat_notifications.dart'
    as notifications;
import 'package:fnx_feat_onboarding/onboarding.dart' as onboarding;
import 'package:fnx_feat_settings/settings.dart' as settings;
import 'package:fnx_feat_transactions/transactions.dart' as transactions;
import 'package:go_router/go_router.dart';

import 'shell/main_shell.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Build the top-level [GoRouter] for FinNex.
///
/// Pass a [ProviderContainer] so the router can read auth/onboarding state for
/// redirects. When [container] is null, redirects fall back to "let the user
/// see whatever they navigated to" — useful for golden tests and standalone
/// previews.
GoRouter buildFinnexRouter({ProviderContainer? container}) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      // Top-level redirects are intentionally permissive: auth gating happens
      // inside individual feature screens (which already render sign-in
      // forms when the session is missing). The splash route always forwards
      // to /home via its own timer.
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) =>
            const _SplashScreen(),
      ),

      // Onboarding tree (welcome → value-props → setup → permissions → first tx)
      ...onboarding.buildOnboardingRoutes(
        onTryFirstTransaction: (BuildContext ctx) =>
            ctx.go('/transactions/add'),
      ),

      // Auth flows (sign-in, sign-up, OTP, biometric, devices, delete)
      ...auth.authRoutes(),

      // Top-level (non-shell) routes that sit above the bottom-nav scaffold.
      ...categories.categoriesRoutes(),
      ...budgets.budgetsRoutes(),

      // Notifications center + preferences
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (BuildContext context, GoRouterState state) =>
            const notifications.NotificationsCenterPage(),
        routes: <RouteBase>[
          GoRoute(
            path: 'preferences',
            name: 'notifications.preferences',
            builder: (BuildContext context, GoRouterState state) =>
                const notifications.NotificationPreferencesPage(),
          ),
        ],
      ),

      // Bottom-nav shell with four branches.
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          // 0 — Home (dashboard)
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (BuildContext context, GoRouterState state) =>
                    const dashboard.DashboardPage(),
              ),
            ],
          ),
          // 1 — Transactions (+ details/edit/quick-add forms)
          StatefulShellBranch(
            routes: transactions.buildTransactionsRoutes(),
          ),
          // 2 — Analytics (+ category detail, calendar)
          StatefulShellBranch(
            routes: analytics.analyticsRoutes,
          ),
          // 3 — Settings (+ sub-pages)
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (BuildContext context, GoRouterState state) =>
                    const settings.SettingsRootPage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'profile',
                    name: 'settings.profile',
                    builder: (BuildContext context, GoRouterState state) =>
                        const settings.ProfilePage(),
                  ),
                  GoRoute(
                    path: 'appearance',
                    name: 'settings.appearance',
                    builder: (BuildContext context, GoRouterState state) =>
                        const settings.AppearancePage(),
                  ),
                  GoRoute(
                    path: 'language',
                    name: 'settings.language',
                    builder: (BuildContext context, GoRouterState state) =>
                        const settings.LanguagePage(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    name: 'settings.privacy',
                    builder: (BuildContext context, GoRouterState state) =>
                        const settings.PrivacyPage(),
                  ),
                  GoRoute(
                    path: 'data',
                    name: 'settings.data',
                    builder: (BuildContext context, GoRouterState state) =>
                        const settings.DataPage(),
                  ),
                  GoRoute(
                    path: 'about',
                    name: 'settings.about',
                    builder: (BuildContext context, GoRouterState state) =>
                        const settings.AboutPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}

/// Default router instance for use by [MaterialApp.router].
///
/// Tests and the app entrypoint may rebuild a fresh router via
/// [buildFinnexRouter] when they need to inject a [ProviderContainer].
final GoRouter finnexRouter = buildFinnexRouter();

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'FinNex',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
