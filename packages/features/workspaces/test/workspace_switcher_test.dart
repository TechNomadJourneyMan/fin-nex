// Widget tests for the workspace-switcher pill and its picker bottom sheet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/domain.dart';
import 'package:go_router/go_router.dart';

import 'package:fnx_feat_workspaces/fnx_feat_workspaces.dart';

Workspace _ws({
  required String id,
  required String name,
  WorkspaceType type = WorkspaceType.personal,
  bool isDefault = false,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return Workspace(
    id: Ulid(id),
    userId: Ulid('00000000000000000000000001'),
    name: name,
    type: type,
    baseCurrency: Currency.kzt,
    colorHex: type == WorkspaceType.business ? '#00A87D' : '#3D5AFE',
    iconKey: 'wallet',
    createdAt: now,
    updatedAt: now,
    isDefault: isDefault,
  );
}

/// Pumps [child] inside a Riverpod scope + MaterialApp.router so go_router
/// `context.push` calls in the switcher resolve.
Future<void> _pump(
  WidgetTester tester, {
  required WorkspacesRepository repo,
  required Widget child,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, __) => Scaffold(body: child)),
      ...workspacesRoutes(),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        workspacesRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('WorkspaceSwitcher', () {
    testWidgets('pill shows the default workspace name', (tester) async {
      final repo = InMemoryWorkspacesRepository(
        seed: <Workspace>[
          _ws(
            id: '00000000000000000000000WS1',
            name: 'Personal',
            isDefault: true,
          ),
          _ws(
            id: '00000000000000000000000WS2',
            name: 'Acme LLC',
            type: WorkspaceType.business,
          ),
        ],
      );

      await _pump(tester, repo: repo, child: const WorkspaceSwitcher());

      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('tapping the pill opens a sheet listing all workspaces',
        (tester) async {
      final repo = InMemoryWorkspacesRepository(
        seed: <Workspace>[
          _ws(
            id: '00000000000000000000000WS1',
            name: 'Personal',
            isDefault: true,
          ),
          _ws(
            id: '00000000000000000000000WS2',
            name: 'Acme LLC',
            type: WorkspaceType.business,
          ),
        ],
      );

      await _pump(tester, repo: repo, child: const WorkspaceSwitcher());

      await tester.tap(find.byType(WorkspaceSwitcher));
      await tester.pumpAndSettle();

      // Sheet header + both rows render, plus the create CTA.
      final createCta = find.widgetWithText(FnxButton, 'Create workspace');
      expect(createCta, findsOneWidget);
      expect(find.text('Acme LLC'), findsOneWidget);
      // 'Personal' appears in both the pill (behind the sheet) and the row.
      expect(find.text('Personal'), findsWidgets);
      // Active workspace gets a checkmark.
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping a different workspace switches the active selection',
        (tester) async {
      final repo = InMemoryWorkspacesRepository(
        seed: <Workspace>[
          _ws(
            id: '00000000000000000000000WS1',
            name: 'Personal',
            isDefault: true,
          ),
          _ws(
            id: '00000000000000000000000WS2',
            name: 'Acme LLC',
            type: WorkspaceType.business,
          ),
        ],
      );

      await _pump(tester, repo: repo, child: const WorkspaceSwitcher());

      await tester.tap(find.byType(WorkspaceSwitcher));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acme LLC'));
      await tester.pumpAndSettle();

      // Sheet dismissed; pill now reflects the newly-selected workspace.
      expect(find.widgetWithText(FnxButton, 'Create workspace'), findsNothing);
      expect(find.text('Acme LLC'), findsOneWidget);
    });

    testWidgets('sheet shows empty message when there are no workspaces',
        (tester) async {
      final repo = InMemoryWorkspacesRepository();

      await _pump(tester, repo: repo, child: const WorkspaceSwitcher());

      await tester.tap(find.byType(WorkspaceSwitcher));
      await tester.pumpAndSettle();

      expect(find.text('No workspaces yet.'), findsOneWidget);
      final createCta = find.widgetWithText(FnxButton, 'Create workspace');
      expect(createCta, findsOneWidget);
    });
  });

  group('WorkspaceThemeScope', () {
    testWidgets('overrides the primary color with the workspace accent',
        (tester) async {
      const accent = Color(0xFF00A87D);
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          home: WorkspaceThemeScope(
            accent: accent,
            child: Builder(
              builder: (ctx) {
                captured = ctx;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(Theme.of(captured).colorScheme.primary, accent);
      expect(Theme.of(captured).primaryColor, accent);
    });
  });
}
