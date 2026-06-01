// Widget test for [MainShell] adaptive layout.
//
// Verifies that the shell switches navigation widgets across breakpoints:
//   • < 600 px   → NavigationBar (bottom)
//   • 600-1199   → collapsed NavigationRail (left)
//   • ≥ 1200 px  → extended NavigationRail (left)
//
// We build a minimal StatefulShellRoute so the shell receives a real
// StatefulNavigationShell. No app-level providers are required.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pocketflow/shell/main_shell.dart';

Future<void> _pumpAt(
  WidgetTester tester, {
  required Size size,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('home'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/transactions',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('tx'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/analytics',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('an'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('set'))),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        supportedLocales: PfLocales.all,
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ),
  );
  // Let the router and the LayoutBuilder/AnimatedSwitcher settle.
  // We can't pumpAndSettle because DynamicIslandActions runs an infinite
  // pulse animation; pump a few discrete frames instead.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('phone width (<600) shows bottom NavigationBar', (tester) async {
    await _pumpAt(tester, size: const Size(399, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('tablet width (600-1199) shows collapsed NavigationRail',
      (tester) async {
    await _pumpAt(tester, size: const Size(800, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    final NavigationRail rail = tester.widget<NavigationRail>(
      find.byType(NavigationRail),
    );
    expect(
      rail.extended,
      isFalse,
      reason: 'rail should NOT be extended at 800 px',
    );
    expect(rail.labelType, NavigationRailLabelType.selected);
  });

  testWidgets('desktop width (>=1200) shows extended NavigationRail',
      (tester) async {
    await _pumpAt(tester, size: const Size(1280, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    final NavigationRail rail = tester.widget<NavigationRail>(
      find.byType(NavigationRail),
    );
    expect(
      rail.extended,
      isTrue,
      reason: 'rail should be extended at 1280 px',
    );
  });
}
