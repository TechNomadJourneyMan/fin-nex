import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/fnx_domain.dart';

import 'predictor/category_predictor.dart';

/// Provides the [TransactionsRepository] used by this feature.
///
/// Must be overridden in `main()` (typically with the sync-aware repository
/// from `fnx_data_sync`).
final transactionsRepositoryProvider = Provider<TransactionsRepository>((Ref ref) {
  throw UnimplementedError(
    'transactionsRepositoryProvider must be overridden with a concrete '
    'TransactionsRepository instance.',
  );
});

/// Provides the [AccountsRepository] used for account chips & defaults.
///
/// Must be overridden in `main()`.
final accountsRepositoryProvider = Provider<AccountsRepository>((Ref ref) {
  throw UnimplementedError(
    'accountsRepositoryProvider must be overridden with a concrete '
    'AccountsRepository instance.',
  );
});

/// Provides the [CategoriesRepository] used for category chips & defaults.
///
/// Must be overridden in `main()`.
final categoriesRepositoryProvider = Provider<CategoriesRepository>((Ref ref) {
  throw UnimplementedError(
    'categoriesRepositoryProvider must be overridden with a concrete '
    'CategoriesRepository instance.',
  );
});

/// Provides the active user identifier. Override in app bootstrap once the
/// session is hydrated.
final currentUserIdProvider = Provider<Ulid>((Ref ref) {
  throw UnimplementedError(
    'currentUserIdProvider must be overridden with the signed-in user ULID.',
  );
});

/// Provides the [Currency] used as a default for new transactions. Override
/// in app bootstrap from settings.
final defaultCurrencyProvider = Provider<Currency>((Ref ref) => Currency.kzt);

/// Provides the shared [CategoryPredictor] (stateless).
final categoryPredictorProvider = Provider<CategoryPredictor>(
  (Ref ref) => const CategoryPredictor(),
);

/// Streams the current user's accounts (live).
final accountsStreamProvider = StreamProvider<List<Account>>((Ref ref) {
  final AccountsRepository repo = ref.watch(accountsRepositoryProvider);
  final Ulid userId = ref.watch(currentUserIdProvider);
  return repo.watchAll(userId);
});

/// Streams the current user's categories (live).
final categoriesStreamProvider = StreamProvider<List<Category>>((Ref ref) {
  final CategoriesRepository repo = ref.watch(categoriesRepositoryProvider);
  final Ulid userId = ref.watch(currentUserIdProvider);
  return repo.watchAll(userId);
});

/// Streams all live transactions for the current user (no filter).
final transactionsStreamProvider = StreamProvider<List<Transaction>>((Ref ref) {
  final TransactionsRepository repo = ref.watch(transactionsRepositoryProvider);
  final Ulid userId = ref.watch(currentUserIdProvider);
  return repo.watchAll(userId);
});
