// Top-level router for PocketFlow.
//
// Composes feature-package routes into a single [GoRouter]. The four primary
// tabs (Home, Transactions, Analytics, Settings) live under a
// [StatefulShellRoute] so each tab keeps its own navigation stack. All other
// routes (auth, onboarding, transaction details/forms, budgets, categories,
// notifications) sit at the top level and push over the shell.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_feat_ai_chat/pf_feat_ai_chat.dart' as ai_chat;
import 'package:pf_feat_analytics/analytics.dart' as analytics;
import 'package:pf_feat_auth/auth.dart' as auth;
import 'package:pf_feat_budgets/pf_feat_budgets.dart' as budgets;
import 'package:pf_feat_categories/pf_feat_categories.dart' as categories;
import 'package:pf_feat_dashboard/dashboard.dart' as dashboard;
import 'package:pf_feat_notifications/pf_feat_notifications.dart'
    as notifications;
import 'package:pf_feat_onboarding/onboarding.dart' as onboarding;
import 'package:pf_feat_settings/settings.dart' as settings;
import 'package:pf_feat_subscriptions/subscriptions.dart' as subs;
import 'package:pf_feat_transactions/transactions.dart' as transactions;
import 'package:pf_feat_workspaces/pf_feat_workspaces.dart' as workspaces;
import 'package:go_router/go_router.dart';

import 'pages/achievements_page.dart';
import 'pages/goals_page.dart';
import 'pages/local_llm_settings_page.dart';
import 'pages/sms_sandbox_page.dart';

import 'shell/main_shell.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Build the top-level [GoRouter] for PocketFlow.
///
/// Pass a [ProviderContainer] so the router can read auth/onboarding state for
/// redirects. When [container] is null, redirects fall back to "let the user
/// see whatever they navigated to" — useful for golden tests and standalone
/// previews.
GoRouter buildPocketFlowRouter({ProviderContainer? container}) {
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

      // Subscriptions manager (F-04) — top-level, pushed over the shell.
      GoRoute(
        path: '/subscriptions',
        name: 'subscriptions',
        builder: (BuildContext context, GoRouterState state) =>
            const subs.SubscriptionsManagerPage(),
      ),

      // AI-CFO chat (F-07) — top-level, pushed over the shell.
      GoRoute(
        path: '/ai-chat',
        name: 'ai-chat',
        builder: (BuildContext context, GoRouterState state) =>
            const ai_chat.AiChatPage(),
      ),

      // Workspaces feature (F-06).
      ...workspaces.workspacesRoutes(),

      // Financial goals (savings tracker).
      GoRoute(
        path: '/goals',
        name: 'goals',
        builder: (BuildContext context, GoRouterState state) =>
            const GoalsPage(),
      ),

      // Gamification (F-08) — achievements + streak.
      GoRoute(
        path: '/achievements',
        name: 'achievements',
        builder: (BuildContext context, GoRouterState state) =>
            const AchievementsPage(),
      ),

      // SMS parser sandbox (F-03 testing surface for Web).
      GoRoute(
        path: '/sms-sandbox',
        name: 'sms-sandbox',
        builder: (BuildContext context, GoRouterState state) =>
            const SmsSandboxPage(),
      ),

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
                  GoRoute(
                    path: 'local-llm',
                    name: 'settings.localLlm',
                    builder: (BuildContext context, GoRouterState state) =>
                        const LocalLlmSettingsPage(),
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
/// [buildPocketFlowRouter] when they need to inject a [ProviderContainer].
final GoRouter pocketFlowRouter = buildPocketFlowRouter();

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _navTimer;
  Timer? _slowTimer;
  Timer? _tick;
  String? _navError;
  bool _slow = false;
  final Stopwatch _sw = Stopwatch()..start();

  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void initState() {
    super.initState();
    // Auto-navigate to /home once the router is ready (short delay so the
    // splash isn't a flash).
    _navTimer = Timer(const Duration(milliseconds: 600), _tryGoHome);
    // If nav never succeeds within 8s, escalate to the "slow" hint.
    _slowTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _slow = true);
    });
    // Tick UI every 100ms so the elapsed counter updates.
    _tick = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  void _tryGoHome() {
    if (!mounted) return;
    try {
      context.go('/home');
    } catch (e) {
      // Router not ready / route missing / something else. Stay on splash
      // with a visible error instead of hanging forever.
      setState(() => _navError = e.toString());
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _slowTimer?.cancel();
    _tick?.cancel();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double seconds = _sw.elapsedMilliseconds / 1000.0;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Pocket Flow',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Color(0xFFF2F2F3),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'OMNIFI OS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 4,
                  color: Color(0xFF5C5C66),
                ),
              ),
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Column(
                  children: <Widget>[
                    _ShimmerBar(animation: _shimmer),
                    const SizedBox(height: 12),
                    Text(
                      _navError == null
                          ? (_slow ? 'Почти готово…' : 'Готовлю интерфейс…')
                          : 'Ошибка маршрутизации',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _navError == null
                            ? const Color(0xFF8A8A93)
                            : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${seconds.toStringAsFixed(1)} s',
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: Color(0x2EFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              if (_navError != null) ...<Widget>[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _navError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFFFF8A80),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _tryGoHome,
                  child: const Text('Повторить'),
                ),
              ] else if (_slow) ...<Widget>[
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Загрузка идёт дольше обычного.\nПопробуйте перезагрузить.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFB840),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _tryGoHome,
                  child: const Text('Перейти на главную'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Indeterminate shimmer progress bar — 3px tall pill with a sliding
/// highlight (OmniFi accent). Pure CustomPainter, no plugins.
class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? _) {
            return CustomPaint(
              painter: _ShimmerPainter(progress: animation.value),
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bg = Paint()..color = const Color(0x14FFFFFF);
    canvas.drawRect(Offset.zero & size, bg);

    final double bandW = size.width * 0.4;
    final double travel = size.width + bandW;
    final double x = -bandW + travel * progress;

    final Rect bandRect = Rect.fromLTWH(x, 0, bandW, size.height);
    final Paint band = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[
          Color(0x00E5E5EA),
          Color(0xFFE5E5EA),
          Color(0x00E5E5EA),
        ],
        stops: <double>[0.0, 0.5, 1.0],
      ).createShader(bandRect);
    canvas.drawRect(bandRect, band);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}
