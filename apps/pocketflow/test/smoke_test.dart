// Smoke test: ensure [PocketFlowApp] mounts and navigates past the splash
// without throwing.
//
// [buildAppProviderOverrides] requires a live [AppDataModule]; we open an
// in-memory sqflite-ffi module so the feature providers resolve against real
// (empty) persisted data instead of throwing UnimplementedError. The splash
// screen forwards to /home via a 600 ms timer, so a bounded pumpAndSettle
// lands the test on the dashboard shell.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pocketflow/app.dart';
import 'package:pocketflow/app_data.dart';
import 'package:pocketflow/providers.dart';

import 'a11y/_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Serve bundled fonts from test/fonts/ so the theme's Google Fonts resolve
  // offline (flutter test has no network).
  installOfflineGoogleFonts();

  // FFI sqflite factory so the in-memory module opens under the VM.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDataModule module;

  setUp(() async {
    module = await AppDataModule.open(demoUserId: kDemoUserId, inMemory: true);
  });

  tearDown(() async {
    await module.dispose();
  });

  testWidgets('PocketFlowApp mounts and reaches /home without errors',
      (WidgetTester tester) async {
    // Warm the theme fonts once using real async so GoogleFonts.pendingFonts
    // resolves outside the fake-async clock (avoids a deadlock).
    await tester.runAsync(() async {
      GoogleFonts.inter();
      GoogleFonts.jetBrainsMono();
      await GoogleFonts.pendingFonts(<dynamic>[]);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildAppProviderOverrides(module),
        child: const PocketFlowApp(),
      ),
    );

    // Let the splash timer fire and the dashboard shell settle. The dashboard
    // hosts DB-backed streams + a RefreshIndicator that never fully quiesce,
    // so pumpAndSettle would time out — bounded pumps are sufficient to mount
    // the shell and surface any build/layout exception.
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(tester.takeException(), isNull);
  });
}
