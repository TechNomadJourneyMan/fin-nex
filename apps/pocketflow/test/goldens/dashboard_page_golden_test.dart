// Golden tests for DashboardPage: light + dark × en/ru/kk = 6 images.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_dashboard/dashboard.dart';

import 'package:pocketflow/app_data.dart';

import '_golden_harness.dart';

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

  const Map<String, Locale> locales = <String, Locale>{
    'en': Locale('en'),
    'ru': Locale('ru'),
    'kk': Locale('kk'),
  };

  for (final MapEntry<String, Locale> entry in locales.entries) {
    for (final Brightness brightness in Brightness.values) {
      final String mode = brightness == Brightness.dark ? 'dark' : 'light';
      testWidgets('DashboardPage golden ${entry.key} $mode',
          (WidgetTester tester) async {
        await pumpGolden(
          tester,
          page: const DashboardPage(),
          module: module,
          brightness: brightness,
          locale: entry.value,
          goldenName: 'dashboard_page_${entry.key}_$mode',
        );
      });
    }
  }
}
