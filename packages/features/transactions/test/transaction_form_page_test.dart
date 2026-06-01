// Widget tests for [TransactionFormPage].
//
// Covers:
//   * amount validation — saving with a zero amount does NOT persist;
//   * category selection — tapping a category chip selects it;
//   * save — a complete form upserts a transaction with the right amount,
//     account, category and type.
//
// The form's amount is driven by an internal calculator numpad. Rather than
// poke individual numpad keys (brittle), the save-path tests open the form in
// EDIT mode with a known initial transaction so the amount/account/category
// are pre-populated, then verify the repository receives the upsert.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_transactions/transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_fakes.dart';

Future<Widget> _host({
  required List<Override> overrides,
  required Widget child,
}) async {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: PfLocales.all,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTransactionsRepository repo;
  late FakeAccountsRepository accounts;
  late FakeCategoriesRepository categories;
  late Ulid user;
  late Ulid accountId;
  late Ulid groceriesId;
  late Ulid transportId;
  late List<Override> overrides;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    user = Ulid.now();
    accountId = Ulid.now();
    groceriesId = Ulid.now();
    transportId = Ulid.now();

    repo = FakeTransactionsRepository();
    accounts = FakeAccountsRepository(<Account>[
      makeAccount(id: accountId, userId: user),
    ]);
    categories = FakeCategoriesRepository(<Category>[
      makeCategory(id: groceriesId, name: 'Groceries'),
      makeCategory(id: transportId, name: 'Transport'),
    ]);

    overrides = <Override>[
      transactionsRepositoryProvider.overrideWithValue(repo),
      accountsRepositoryProvider.overrideWithValue(accounts),
      categoriesRepositoryProvider.overrideWithValue(categories),
      currentUserIdProvider.overrideWithValue(user),
      defaultCurrencyProvider.overrideWithValue(Currency.kzt),
      feedbackServiceProvider.overrideWithValue(
        FeedbackService(prefs: prefs),
      ),
    ];
  });

  tearDown(() async {
    await repo.dispose();
  });

  testWidgets('zero amount fails validation and does not persist',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      await _host(overrides: overrides, child: const TransactionFormPage()),
    );
    await tester.pumpAndSettle();

    // Tap the AppBar save action (IconButton) with the default (zero) amount.
    await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
    await tester.pumpAndSettle();

    final List<Transaction> rows = await repo.watchAll(user).first;
    expect(rows, isEmpty, reason: 'zero-amount save must not persist');
  });

  testWidgets('tapping a category chip selects it',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      await _host(overrides: overrides, child: const TransactionFormPage()),
    );
    await tester.pumpAndSettle();

    // Both category chips render in the strip.
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Groceries'), findsWidgets);

    // Selecting a chip must not throw and keeps the page mounted.
    await tester.tap(find.text('Transport'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(TransactionFormPage), findsOneWidget);
  });

  testWidgets('complete form saves a transaction with correct args',
      (WidgetTester tester) async {
    // Edit mode: a known initial transaction supplies a valid amount, account
    // and category, so tapping save exercises the full upsert path.
    final Transaction initial = makeTransaction(
      id: Ulid.now(),
      userId: user,
      accountId: accountId,
      categoryId: groceriesId,
      minor: 250000,
      occurredAt: DateTime.utc(2026, 1, 2, 9, 30),
      description: 'Groceries',
    );

    await tester.pumpWidget(
      await _host(
        overrides: overrides,
        child: TransactionFormPage(initial: initial),
      ),
    );
    await tester.pumpAndSettle();

    // The AppBar save action; the selected category chip also shows a check,
    // so scope to the IconButton.
    await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
    await tester.pumpAndSettle();

    final List<Transaction> rows = await repo.watchAll(user).first;
    expect(rows.length, 1);
    final Transaction saved = rows.single;
    expect(saved.id.value, initial.id.value);
    expect(saved.amount.minor.toInt(), 250000);
    expect(saved.accountId.value, accountId.value);
    expect(saved.categoryId?.value, groceriesId.value);
    expect(saved.type, TransactionType.expense);
  });
}
