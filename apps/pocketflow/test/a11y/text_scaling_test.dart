// Text-scaling accessibility test.
//
// Mounts DashboardPage, HistoryPage and TransactionFormPage at textScaler
// factors 1.0, 1.5 and 2.0 and asserts no exception (notably no RenderFlex
// overflow) after pumpAndSettle. The pages are wired to an in-memory sqflite
// module via the app's real provider overrides so they render their genuine
// (empty-data) layouts rather than throwing UnimplementedError.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_theme/pf_core_theme.dart';
import 'package:pf_feat_dashboard/dashboard.dart';
import 'package:pf_feat_transactions/transactions.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pocketflow/app_data.dart';
import 'package:pocketflow/providers.dart';

import '_fonts.dart';

Future<Widget> _wrap(Widget page, List<Override> overrides) async {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: PfTheme.light(),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: PfLocales.all,
      home: page,
    ),
  );
}

/// Guards the one-time Google Fonts warmup (see [_pumpAtScale]).
bool _fontsWarmed = false;

Future<void> _pumpAtScale(
  WidgetTester tester,
  Widget page,
  List<Override> overrides,
  double scale,
) async {
  final List<Object> realErrors = <Object>[];

  // `takeException()` surfaces at most one exception per call, so drain it in
  // a loop, discarding Google-Fonts network noise (irrelevant in tests) and
  // keeping anything else — notably a RenderFlex overflow.
  void drain() {
    while (true) {
      final Object? e = tester.takeException();
      if (e == null) break;
      if (!_isIgnorableTestException(e)) realErrors.add(e);
    }
  }

  // Pre-load the Google Fonts the theme uses ONCE, using REAL async (the only
  // zone where the offline font client resolves under flutter_test). Doing
  // this per-test would re-enter pendingFonts under each test's fake-async
  // clock and deadlock, so a module-level guard ensures it runs a single time;
  // thereafter the fonts are cached in-process and reused by every test.
  if (!_fontsWarmed) {
    await tester.runAsync(() async {
      GoogleFonts.inter();
      GoogleFonts.jetBrainsMono();
      await GoogleFonts.pendingFonts(<dynamic>[]);
    });
    _fontsWarmed = true;
  }

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: await _wrap(page, overrides),
    ),
  );
  // Bounded pumps instead of pumpAndSettle: these pages host a
  // RefreshIndicator and DB-backed streams that never quiesce, so
  // pumpAndSettle would time out. A handful of frames is enough for the
  // async data to resolve and the final layout (where any RenderFlex
  // overflow would surface) to be performed.
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
    drain();
  }

  // Tear the tree down and drain real sqflite-ffi/DB timers so the binding's
  // teardown invariants are satisfied.
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  drain();

  expect(
    realErrors,
    isEmpty,
    reason: 'Layout exception at textScaler $scale for ${page.runtimeType}',
  );
}

/// True for exceptions that are test-environment noise rather than real
/// layout/a11y defects: Google Fonts cannot reach the network in `flutter
/// test`, which is irrelevant to whether the page overflows.
bool _isIgnorableTestException(Object e) {
  final String s = e.toString();
  return s.contains('Failed to load font') ||
      s.contains('GoogleFonts.config.allowRuntimeFetching');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Serve Google Fonts from bundled test/fonts/*.ttf so no network is needed.
  installOfflineGoogleFonts();

  // Use the FFI sqflite factory so the in-memory module opens under the VM.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDataModule module;
  late List<Override> overrides;

  setUp(() async {
    module = await AppDataModule.open(
      demoUserId: kDemoUserId,
      inMemory: true,
    );
    overrides = buildAppProviderOverrides(module);
  });

  tearDown(() async {
    await module.dispose();
  });

  // 600x800 logical surface so the pages lay out on a phone-width viewport.
  void sizeView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(600, 1000);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  for (final double scale in <double>[1.0, 1.5, 2.0]) {
    testWidgets('DashboardPage at textScaler $scale has no overflow',
        (WidgetTester tester) async {
      sizeView(tester);
      await _pumpAtScale(tester, const DashboardPage(), overrides, scale);
    });

    testWidgets('HistoryPage at textScaler $scale has no overflow',
        (WidgetTester tester) async {
      sizeView(tester);
      await _pumpAtScale(tester, const HistoryPage(), overrides, scale);
    });

    testWidgets('TransactionFormPage at textScaler $scale has no overflow',
        (WidgetTester tester) async {
      sizeView(tester);
      await _pumpAtScale(
        tester,
        const TransactionFormPage(),
        overrides,
        scale,
      );
    });
  }
}
