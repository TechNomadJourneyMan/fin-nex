// Widget test for swipe-to-delete on the HistoryPage transaction list.
//
// Swiping a row left (endToStart) must surface a Cupertino-style confirm
// dialog ("Удалить операцию?…") before the row is actually dismissed.

import 'package:flutter/cupertino.dart';
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
  late Ulid account;
  late Ulid txId;

  setUp(() {
    user = Ulid.now();
    account = Ulid.now();
    txId = Ulid.now();
    repo = FakeTransactionsRepository();
    accounts = FakeAccountsRepository(<Account>[
      makeAccount(id: account, userId: user),
    ]);
    categories = FakeCategoriesRepository(<Category>[]);
  });

  tearDown(() async {
    await repo.dispose();
  });

  Future<void> seedOneTransaction() async {
    await repo.upsert(
      makeTransaction(
        id: txId,
        userId: user,
        accountId: account,
        description: 'Coffee',
      ),
    );
  }

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
    'swiping a row left shows the delete confirm dialog',
    (WidgetTester tester) async {
      await seedOneTransaction();
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      // The seeded row renders inside a Dismissible.
      final Finder dismissible = find.byKey(Key('tx-${txId.value}'));
      expect(dismissible, findsOneWidget);

      // Drag left (endToStart) past the dismiss threshold.
      await tester.drag(dismissible, const Offset(-600, 0));
      await tester.pumpAndSettle();

      // confirmDismiss should have surfaced a Cupertino confirmation dialog.
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(
        find.text('Удалить операцию? Это нельзя отменить.'),
        findsOneWidget,
      );
      // Both actions are present.
      expect(
        find.widgetWithText(CupertinoDialogAction, 'Отмена'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CupertinoDialogAction, 'Удалить'),
        findsOneWidget,
      );
    },
  );
}
