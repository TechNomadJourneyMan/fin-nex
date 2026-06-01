import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_transactions/transactions.dart';

import '_fakes.dart';

void main() {
  group('QuickAddController.save', () {
    late FakeTransactionsRepository repo;
    late FakeAccountsRepository accounts;
    late FakeCategoriesRepository categories;
    late Ulid user;
    late Ulid account;
    late Ulid category;
    late ProviderContainer container;

    setUp(() {
      user = Ulid.now();
      account = Ulid.now();
      category = Ulid.now();
      repo = FakeTransactionsRepository();
      accounts = FakeAccountsRepository(<Account>[
        makeAccount(id: account, userId: user),
      ]);
      categories = FakeCategoriesRepository(<Category>[
        makeCategory(id: category),
      ]);
      container = ProviderContainer(
        overrides: <Override>[
          transactionsRepositoryProvider.overrideWithValue(repo),
          accountsRepositoryProvider.overrideWithValue(accounts),
          categoriesRepositoryProvider.overrideWithValue(categories),
          currentUserIdProvider.overrideWithValue(user),
          defaultCurrencyProvider.overrideWithValue(Currency.kzt),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await repo.dispose();
    });

    test('saves a transaction and surfaces it in the stream', () async {
      // Warm-up streams so the form sees its defaults.
      await container.read(accountsStreamProvider.future);
      await container.read(categoriesStreamProvider.future);

      final QuickAddController ctrl = container.read(
        quickAddControllerProvider(TransactionType.expense).notifier,
      );
      ctrl.setAccount(account);
      ctrl.setCategory(category);
      ctrl.setAmount(1500);

      final Transaction saved = await ctrl.save();
      expect(saved.amount.minor.toInt(), 1500);
      expect(saved.accountId.value, account.value);
      expect(saved.categoryId?.value, category.value);
      expect(saved.type, TransactionType.expense);

      final List<Transaction> rows = await repo.watchAll(user).first;
      expect(rows.length, 1);
      expect(rows.first.id.value, saved.id.value);
    });

    test('throws StateError when form is incomplete', () async {
      final QuickAddController ctrl = container.read(
        quickAddControllerProvider(TransactionType.expense).notifier,
      );
      // Only amount set — no account/category yet (streams empty in this test).
      ctrl.setAmount(500);
      expect(() => ctrl.save(), throwsA(isA<StateError>()));
    });

    test('resets amount but keeps account/category as sticky defaults',
        () async {
      await container.read(accountsStreamProvider.future);
      await container.read(categoriesStreamProvider.future);

      final QuickAddController ctrl = container.read(
        quickAddControllerProvider(TransactionType.expense).notifier,
      );
      ctrl.setAccount(account);
      ctrl.setCategory(category);
      ctrl.setAmount(2500);
      await ctrl.save();

      final QuickAddFormState after =
          container.read(quickAddControllerProvider(TransactionType.expense));
      expect(after.amountMinor, 0);
      expect(after.accountId?.value, account.value);
      expect(after.categoryId?.value, category.value);
    });
  });
}
