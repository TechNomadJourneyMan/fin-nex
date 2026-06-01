// Golden tests for HistoryPage with 3 mock transactions: light + dark = 2.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_transactions/transactions.dart';

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

  for (final Brightness brightness in Brightness.values) {
    final String mode = brightness == Brightness.dark ? 'dark' : 'light';
    testWidgets('HistoryPage golden $mode', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        page: const HistoryPage(),
        module: module,
        brightness: brightness,
        locale: const Locale('en'),
        goldenName: 'history_page_$mode',
      );
    });
  }
}
