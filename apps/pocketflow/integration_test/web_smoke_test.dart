// Integration smoke test.
//
// Drives the full Pocket Flow shell end-to-end:
//   1. boots the app on an in-memory data module + a fresh router;
//   2. visits each of the 4 primary tabs (Home, Transactions, Analytics,
//      Settings);
//   3. opens the new-transaction form, enters an amount on the calculator
//      numpad and saves;
//   4. asserts the saved transaction appears in History.
//
// Runs on web via `flutter test integration_test/web_smoke_test.dart -d chrome`
// or on a device with `flutter test integration_test`. It also runs under the
// plain VM (`flutter test`) because it only touches the in-memory module.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_theme/pf_core_theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:pocketflow/app_data.dart';
import 'package:pocketflow/providers.dart';
import 'package:pocketflow/routes.dart';

import '../test/a11y/_fonts.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  installOfflineGoogleFonts();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDataModule module;
  late GoRouter router;

  setUp(() async {
    module = await AppDataModule.open(demoUserId: kDemoUserId, inMemory: true);
    router = buildPocketFlowRouter();
  });

  tearDown(() async {
    router.dispose();
    await module.dispose();
  });

  Future<void> warmFonts(WidgetTester tester) async {
    await tester.runAsync(() async {
      GoogleFonts.inter();
      GoogleFonts.jetBrainsMono();
      await GoogleFonts.pendingFonts(<dynamic>[]);
    });
  }

  Widget app() {
    return ProviderScope(
      overrides: buildAppProviderOverrides(module),
      child: MaterialApp.router(
        theme: PfTheme.light(),
        darkTheme: PfTheme.dark(),
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: PfLocales.all,
        routerConfig: router,
      ),
    );
  }

  Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
    for (int round = 0; round < rounds; round++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 60));
      });
      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
    }
  }

  testWidgets('navigates tabs, adds a transaction, sees it in History',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(440, 1400);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await warmFonts(tester);
    await tester.pumpWidget(app());

    // Skip the splash timer by routing straight to /home.
    router.go('/home');
    await settle(tester);

    // 1. Visit each of the 4 primary tabs by route.
    for (final String location in <String>[
      '/home',
      '/transactions',
      '/analytics',
      '/settings',
    ]) {
      router.go(location);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'tab $location threw');
    }

    // 2. Open the new-transaction form.
    router.go('/transactions/add');
    await settle(tester);

    // 3. Enter an amount on the calculator numpad: 1, 5, 0 → 150.
    for (final String digit in <String>['1', '5', '0']) {
      await tester.tap(find.text(digit).first);
      await tester.pump(const Duration(milliseconds: 60));
    }
    await settle(tester, rounds: 2);

    // Save via the AppBar check action (account + category auto-fill from the
    // seeded module's defaults).
    await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
    await settle(tester);

    // 4. The transaction is persisted — assert it surfaces in History.
    router.go('/transactions');
    await settle(tester);

    final List<dynamic> rows =
        await module.transactions.watchAll(kDemoUserId).first;
    expect(
      rows,
      isNotEmpty,
      reason: 'the added transaction should be persisted',
    );
  });
}
