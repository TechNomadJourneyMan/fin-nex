// Command palette widget test.
//
// Verifies the palette opens on Cmd+K, that typing "anal" narrows the list to
// the single "Open Analytics" command, and that pressing Enter runs it
// (navigating to /analytics).
//
// The palette is normally gated to web/desktop via kIsWeb in app.dart; this
// harness wires the same Shortcuts/Actions but always opens the dialog so the
// behavior is exercisable under the test runner.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pocketflow/intents.dart';
import 'package:pocketflow/widgets/command_palette.dart';

void main() {
  GoRouter buildRouter(GlobalKey<NavigatorState> navKey) {
    return GoRouter(
      navigatorKey: navKey,
      initialLocation: '/host',
      routes: <RouteBase>[
        GoRoute(
          path: '/host',
          builder: (BuildContext context, GoRouterState state) =>
              const _HostPage(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('ANALYTICS_PAGE'))),
        ),
      ],
    );
  }

  Widget harness(GoRouter router, GlobalKey<NavigatorState> navKey) {
    return ProviderScope(
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.keyK, meta: true):
              OpenCommandPaletteIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            OpenCommandPaletteIntent: OpenCommandPaletteAction(() {
              final BuildContext? ctx = navKey.currentContext;
              if (ctx != null) {
                // ignore: discarded_futures
                showCommandPalette(ctx);
              }
            }),
          },
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            supportedLocales: PfLocales.all,
            localizationsDelegates: AppL10n.localizationsDelegates,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Cmd+K opens palette; "anal" filters to Open Analytics; Enter navigates',
    (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(harness(buildRouter(navKey), navKey));
      await tester.pumpAndSettle();

      // Focus the host so the shortcut has a target, then fire Cmd+K.
      await tester.tap(find.byType(_HostPage));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // The palette is open: every command is visible initially.
      expect(
        find.byKey(const ValueKey<String>('cmd-open-analytics')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('cmd-open-dashboard')),
        findsOneWidget,
      );

      // Type "anal" — only "Open Analytics" should remain.
      await tester.enterText(find.byType(TextField), 'anal');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('cmd-open-analytics')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('cmd-open-dashboard')),
        findsNothing,
      );

      // Press Enter — runs the highlighted command and navigates.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('ANALYTICS_PAGE'), findsOneWidget);
    },
  );
}

class _HostPage extends StatelessWidget {
  const _HostPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('HOST')));
  }
}
