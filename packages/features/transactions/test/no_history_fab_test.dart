// Widget test guarding against the duplicate in-page Add FAB.
//
// The Dynamic Island's "+" owns the "new transaction" action, so the
// HistoryPage Scaffold must NOT host its own FloatingActionButton.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:fnx_feat_transactions/transactions.dart';

import '_fakes.dart';

void main() {
  late FakeTransactionsRepository repo;
  late FakeAccountsRepository accounts;
  late FakeCategoriesRepository categories;
  late Ulid user;

  setUp(() {
    user = Ulid.now();
    final Ulid account = Ulid.now();
    final Ulid category = Ulid.now();
    repo = FakeTransactionsRepository();
    accounts = FakeAccountsRepository(<Account>[
      makeAccount(id: account, userId: user),
    ]);
    categories = FakeCategoriesRepository(<Category>[
      makeCategory(id: category),
    ]);
  });

  tearDown(() async {
    await repo.dispose();
  });

  Widget harness() {
    return ProviderScope(
      overrides: <Override>[
        transactionsRepositoryProvider.overrideWithValue(repo),
        accountsRepositoryProvider.overrideWithValue(accounts),
        categoriesRepositoryProvider.overrideWithValue(categories),
        currentUserIdProvider.overrideWithValue(user),
        defaultCurrencyProvider.overrideWithValue(Currency.kzt),
      ],
      child: const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: FnxLocales.all,
        home: HistoryPage(),
      ),
    );
  }

  testWidgets(
    'HistoryPage hosts no FloatingActionButton (Dynamic Island owns +)',
    (WidgetTester tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    },
  );
}
