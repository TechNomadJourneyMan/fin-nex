// Golden tests for AnalyticsPage with a mock dataset: light + dark = 2.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_analytics/analytics.dart';

import 'package:pocketflow/app_data.dart';

import '_golden_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpGoldenEnv();

  late AppDataModule module;

  setUp(() async {
    module = await openModule();
    // A wider dataset exercises the donut + bar + cashflow charts.
    await seedTransactions(module, count: 5);
  });

  tearDown(() async {
    await module.dispose();
  });

  for (final Brightness brightness in Brightness.values) {
    final String mode = brightness == Brightness.dark ? 'dark' : 'light';
    testWidgets('AnalyticsPage golden $mode', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        page: const AnalyticsPage(),
        module: module,
        brightness: brightness,
        locale: const Locale('en'),
        goldenName: 'analytics_page_$mode',
      );
    });
  }
}
