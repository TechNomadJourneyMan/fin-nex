// Shared harness for PocketFlow golden tests.
//
// Provides:
//   * Offline Google Fonts + sqflite-ffi setup (call [setUpGoldenEnv] in main).
//   * An in-memory [AppDataModule] seeded with deterministic mock data so the
//     dashboard / history / analytics pages render populated layouts.
//   * [pumpGolden] which wires a single feature page into a MaterialApp with
//     the requested brightness + locale and the app's real provider overrides.
//
// Goldens use the built-in [matchesGoldenFile]; no extra package. Fonts are
// loaded from test/fonts/*.ttf so text shapes are stable across machines.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_theme/pf_core_theme.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:pocketflow/app_data.dart';
import 'package:pocketflow/providers.dart';

import '../a11y/_fonts.dart';

/// Seed anchor. Uses the real "now" so transactions fall inside the pages'
/// default current-period filter (month/week), then steps back by whole days.
/// Times are normalised to midday UTC so layout is stable run-to-run.
final DateTime kGoldenNow = () {
  final DateTime n = DateTime.now().toUtc();
  return DateTime.utc(n.year, n.month, n.day, 12);
}();

bool _fontsWarmed = false;

/// One-time test-environment setup. Call inside `main()` before the binding
/// is used (after [TestWidgetsFlutterBinding.ensureInitialized]).
void setUpGoldenEnv() {
  installOfflineGoogleFonts();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Warms the theme fonts exactly once, using real async so
/// `GoogleFonts.pendingFonts` resolves outside the fake-async clock.
Future<void> warmFonts(WidgetTester tester) async {
  if (_fontsWarmed) return;
  await tester.runAsync(() async {
    GoogleFonts.inter();
    GoogleFonts.jetBrainsMono();
    await GoogleFonts.pendingFonts(<dynamic>[]);
  });
  _fontsWarmed = true;
}

/// Opens a fresh in-memory module. Caller must `await module.dispose()`.
Future<AppDataModule> openModule() =>
    AppDataModule.open(demoUserId: kDemoUserId, inMemory: true);

/// Seeds [module] with [count] deterministic transactions spread across the
/// seeded categories so dashboard / history / analytics render populated.
///
/// Returns the seeded transactions (newest first), matching the order the UI
/// presents them.
Future<List<Transaction>> seedTransactions(
  AppDataModule module, {
  int count = 3,
}) async {
  final List<Account> accounts = await module.accounts.list(kDemoUserId);
  final List<Category> categories = await module.categories.list(kDemoUserId);
  if (accounts.isEmpty) return const <Transaction>[];

  final Account account = accounts.first;
  // Prefer expense categories for stable visuals; fall back to any.
  final List<Category> expenseCats = <Category>[
    for (final Category c in categories)
      if (c.type == CategoryType.expense) c,
  ];
  final List<Category> pool =
      expenseCats.isNotEmpty ? expenseCats : categories;

  // Deterministic amounts (minor units) and notes.
  const List<int> amounts = <int>[125000, 48050, 320075, 91000, 15500];
  const List<String> notes = <String>[
    'Groceries',
    'Coffee',
    'Rent',
    'Transport',
    'Snacks',
  ];

  final List<Transaction> seeded = <Transaction>[];
  for (int i = 0; i < count; i++) {
    final Category? cat = pool.isEmpty ? null : pool[i % pool.length];
    final DateTime when = kGoldenNow.subtract(Duration(days: i));
    final bool income = i == 1; // one income row for variety
    final Transaction tx = Transaction(
      // 26-char Crockford base-32 ULID, unique per index (all-numeric).
      id: Ulid((100 + i + 1).toString().padLeft(26, '0')),
      userId: kDemoUserId,
      accountId: account.id,
      type: income ? TransactionType.income : TransactionType.expense,
      amount: Money(BigInt.from(amounts[i % amounts.length]), Currency.kzt),
      categoryId: cat?.id,
      occurredAt: when,
      createdAt: when,
      updatedAt: when,
      source: 'manual',
      description: income ? 'Salary' : notes[i % notes.length],
      attachmentIds: const <Ulid>[],
      tagIds: const <Ulid>[],
    );
    await module.transactions.upsert(tx);
    seeded.add(tx);
  }
  return seeded;
}

/// Builds a deterministic edit-mode transaction for the form golden so the
/// rendered date / amount / note are byte-stable (the create form otherwise
/// defaults `occurredAt` to the live wall-clock).
Future<Transaction> goldenSampleTransaction(AppDataModule module) async {
  final List<Account> accounts = await module.accounts.list(kDemoUserId);
  final List<Category> categories = await module.categories.list(kDemoUserId);
  final Category? expense = <Category?>[
    for (final Category c in categories)
      if (c.type == CategoryType.expense) c,
    null,
  ].first;
  return Transaction(
    id: Ulid('00000000000000000000000999'),
    userId: kDemoUserId,
    accountId: accounts.first.id,
    type: TransactionType.expense,
    amount: Money(BigInt.from(125000), Currency.kzt),
    categoryId: expense?.id,
    occurredAt: DateTime.utc(2026, 1, 2, 9, 30),
    createdAt: DateTime.utc(2026, 1, 2, 9, 30),
    updatedAt: DateTime.utc(2026, 1, 2, 9, 30),
    source: 'manual',
    description: 'Groceries',
    attachmentIds: const <Ulid>[],
    tagIds: const <Ulid>[],
  );
}

/// Wraps [page] in a MaterialApp with [brightness] + [locale] and the app's
/// provider overrides bound to [module].
Widget _wrap({
  required Widget page,
  required AppDataModule module,
  required Brightness brightness,
  required Locale locale,
}) {
  return ProviderScope(
    overrides: buildAppProviderOverrides(module),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          brightness == Brightness.dark ? PfTheme.dark() : PfTheme.light(),
      locale: locale,
      supportedLocales: PfLocales.all,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: page,
    ),
  );
}

/// Pumps [page] and (when [compareGolden] is true) compares it against the
/// golden at [goldenName].
///
/// The pages host DB-backed streams + RefreshIndicators that never quiesce, so
/// bounded pumps (not pumpAndSettle) are used to let async data resolve and the
/// final frame paint.
///
/// [onFirstFrame] (if given) runs once, right after the first frame is pumped
/// and before the data settles — use it to assert the loading/skeleton state.
/// Set [compareGolden] false to reuse this pump/settle/teardown machinery for a
/// plain widget test that does its own assertions.
Future<void> pumpGolden(
  WidgetTester tester, {
  required Widget page,
  required AppDataModule module,
  required Brightness brightness,
  required Locale locale,
  required String goldenName,
  Size surface = const Size(420, 920),
  bool compareGolden = true,
  void Function(WidgetTester tester)? onFirstFrame,
  void Function(WidgetTester tester)? afterSettle,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = surface;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await warmFonts(tester);

  await tester.pumpWidget(
    _wrap(
      page: page,
      module: module,
      brightness: brightness,
      locale: locale,
    ),
  );

  if (onFirstFrame != null) {
    await tester.pump();
    onFirstFrame(tester);
  }

  // The pages read sqflite-ffi-backed streams that only emit under REAL async
  // (not the fake-async clock of pump). Let those microtasks/timers drain, then
  // pump frames so the controller's data state paints. Repeat so the donut /
  // chart layout passes settle before the snapshot is taken.
  for (int round = 0; round < 4; round++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }
  // Settle any in-flight implicit animations (shimmer → content cross-fade).
  await tester.pump(const Duration(seconds: 1));

  if (compareGolden) {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('$goldenName.png'),
    );
  }

  // Run caller assertions on the fully-settled tree, BEFORE it is torn down.
  if (afterSettle != null) {
    afterSettle(tester);
  }

  // Tear the tree down and drain in-flight sqflite/animation timers so the
  // binding's teardown invariants are satisfied (otherwise a disposing
  // AnimationController's TickerMode ancestor lookup throws after teardown).
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pump();
}
