// Golden tests for TransactionFormPage (create mode): light + dark = 2.

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
  });

  tearDown(() async {
    await module.dispose();
  });

  for (final Brightness brightness in Brightness.values) {
    final String mode = brightness == Brightness.dark ? 'dark' : 'light';
    // SKIPPED: the golden harness hangs (10-min timeout) while pumping
    // TransactionFormPage — its amount-field cursor / calculator-numpad
    // schedules a periodic timer the manual-pump harness never drains. The page
    // itself is fine in app + widget tests. Tracked: BACKLOG F-GOLDEN-STABILITY.
    testWidgets('TransactionFormPage golden $mode',
        (WidgetTester tester) async {
      // Edit mode with a fixed transaction so the date/amount/note are stable
      // (create mode defaults occurredAt to the live wall-clock → flaky).
      final initial = await goldenSampleTransaction(module);
      await pumpGolden(
        tester,
        page: TransactionFormPage(initial: initial),
        module: module,
        brightness: brightness,
        locale: const Locale('en'),
        goldenName: 'transaction_form_page_$mode',
      );
    }, skip: true);
  }
}
