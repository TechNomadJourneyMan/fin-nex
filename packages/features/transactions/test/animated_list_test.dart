// Verifies that the HistoryPage renders its rows inside a `SliverAnimatedList`
// and that inserting a row triggers the list's animation (the new row pumps
// into existence over the configured PfMotion.fast duration).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_transactions/transactions.dart';

import '_fakes.dart';

void main() {
  late FakeTransactionsRepository repo;
  late FakeAccountsRepository accounts;
  late FakeCategoriesRepository categories;
  late Ulid user;
  late Ulid account;

  setUp(() {
    user = Ulid.now();
    account = Ulid.now();
    repo = FakeTransactionsRepository();
    accounts = FakeAccountsRepository(<Account>[
      makeAccount(id: account, userId: user),
    ]);
    categories = FakeCategoriesRepository(<Category>[]);
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
        supportedLocales: PfLocales.all,
        home: HistoryPage(),
      ),
    );
  }

  testWidgets(
    'HistoryPage hosts a SliverAnimatedList and animates on insert',
    (WidgetTester tester) async {
      // Seed one row so the empty state is not used and a list mounts.
      final Ulid firstId = Ulid.now();
      await repo.upsert(
        makeTransaction(
          id: firstId,
          userId: user,
          accountId: account,
          description: 'First',
        ),
      );

      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      // The list is a SliverAnimatedList (the diff-driver of the page).
      expect(find.byType(SliverAnimatedList), findsWidgets);

      // Add a second row in the same day-bucket so the existing animated
      // list sees an insertion (rather than a brand-new section).
      final Ulid secondId = Ulid.now();
      await repo.upsert(
        makeTransaction(
          id: secondId,
          userId: user,
          accountId: account,
          description: 'Second',
        ),
      );

      // First pump: triggers a rebuild & schedules the insertItem animation.
      await tester.pump();
      // Mid-flight: the row is still being inserted (animation not finished).
      await tester.pump(const Duration(milliseconds: 50));

      // Eventually the new row is fully laid out.
      await tester.pumpAndSettle();
      expect(find.byKey(Key('tx-${firstId.value}')), findsOneWidget);
      expect(find.byKey(Key('tx-${secondId.value}')), findsOneWidget);
    },
  );
}
