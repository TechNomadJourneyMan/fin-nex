// Widget tests for the app-wired DashboardPage.
//
// Covers:
//   * smoke render — the page mounts against the in-memory module without
//     throwing;
//   * skeleton → data transition — PfSkeleton placeholders shown while the
//     controller loads, replaced by the data view once the DB streams resolve.
//
// Reuses the golden harness (offline fonts + sqflite-ffi setup, seeded
// in-memory module, bounded-pump settling) so the page renders its real
// data-state layout. Assertions run via the harness callbacks so they execute
// while the tree is still mounted (the harness tears it down afterward).
//
// NOTE: the original spec mentioned a "balance reveal on tap" affordance; the
// current dashboard has no such toggle (the balance is always shown), so this
// test verifies the skeleton→data transition instead.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_feat_dashboard/dashboard.dart';

import 'package:pocketflow/app_data.dart';

import '../goldens/_golden_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpGoldenEnv();

  late AppDataModule module;

  setUp(() async {
    module = await openModule();
    await seedTransactions(module, count: 3);
  });

  tearDown(() async {
    await module.dispose();
  });

  testWidgets('smoke render without errors', (WidgetTester tester) async {
    await pumpGolden(
      tester,
      page: const DashboardPage(),
      module: module,
      brightness: Brightness.light,
      locale: const Locale('en'),
      goldenName: 'dashboard_page_en_light',
      compareGolden: false,
      afterSettle: (WidgetTester t) {
        expect(t.takeException(), isNull);
        expect(find.byType(DashboardPage), findsOneWidget);
      },
    );
  });

  testWidgets('renders the loading skeleton first, then resolves to data',
      (WidgetTester tester) async {
    await pumpGolden(
      tester,
      page: const DashboardPage(),
      module: module,
      brightness: Brightness.light,
      locale: const Locale('en'),
      goldenName: 'dashboard_page_en_light',
      compareGolden: false,
      onFirstFrame: (WidgetTester t) {
        // First frame: the controller is still loading → skeleton placeholders.
        expect(
          find.byType(PfSkeleton),
          findsWidgets,
          reason: 'loading view should render skeleton placeholders first',
        );
      },
      afterSettle: (WidgetTester t) {
        // After settling: skeletons replaced by the data view.
        expect(
          find.byType(PfSkeleton),
          findsNothing,
          reason: 'skeletons should be replaced by data',
        );
        expect(find.byType(DashboardPage), findsOneWidget);
      },
    );
  });
}
