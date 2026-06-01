import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/pf_domain.dart';

import '../controllers/transactions_controller.dart';
import '../providers.dart';
import 'transaction_filter_state.dart';

/// Owns the live [TransactionFilterState] for the History page.
///
/// The free-text query is debounced (250ms) inside this notifier with a plain
/// [Timer] — no third-party debounce package — so that typing doesn't thrash
/// the derived [filteredTransactionsProvider] on every keystroke. Chip-style
/// filters (kind, categories, date range) apply immediately because they are
/// discrete, low-frequency interactions.
class TransactionFiltersNotifier extends StateNotifier<TransactionFilterState> {
  /// Creates the notifier seeded with an empty filter.
  TransactionFiltersNotifier()
      : super(const TransactionFilterState());

  Timer? _debounce;

  /// Debounce window for the search query.
  static const Duration debounceWindow = Duration(milliseconds: 250);

  /// Updates the free-text query after a [debounceWindow] of inactivity.
  ///
  /// Passing an empty/blank string clears the query immediately (no debounce)
  /// so the list snaps back as soon as the field is emptied.
  void setQuery(String raw) {
    _debounce?.cancel();
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(clearSearch: true);
      return;
    }
    _debounce = Timer(debounceWindow, () {
      if (!mounted) {
        return;
      }
      state = state.copyWith(searchText: trimmed);
    });
  }

  /// Sets the mutually-exclusive income/expense filter.
  ///
  /// Passing `null` clears it ("All"). Mirrors the conceptual `TxKind` filter
  /// onto the underlying `types` list (a singleton or empty).
  void setKind(TransactionType? kind) {
    state = state.copyWith(
      types: kind == null ? const <TransactionType>[] : <TransactionType>[kind],
    );
  }

  /// Replaces the selected category set.
  void setCategoryIds(Set<Ulid> ids) {
    state = state.copyWith(categoryIds: ids.toList(growable: false));
  }

  /// Sets the inclusive date range (or clears it when [from]/[to] are null).
  void setDateRange({DateTime? from, DateTime? to}) {
    state = state.copyWith(
      from: from,
      to: to,
      clearFrom: from == null,
      clearTo: to == null,
    );
  }

  /// Resets every filter back to the empty default.
  void clear() {
    _debounce?.cancel();
    state = const TransactionFilterState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// Monotonic counter bumped to request that the History search field grab
/// focus (e.g. from the command palette's "Search transactions" command).
///
/// The History page watches this and calls `requestFocus()` on its search
/// node whenever the value increases. A counter (rather than a bool) lets
/// repeated requests re-fire even when the page is already mounted.
final searchFocusRequestProvider = StateProvider<int>((Ref ref) => 0);

/// The active History filters. Watch this to react to filter changes; read its
/// `.notifier` to mutate them.
final transactionFiltersProvider =
    StateNotifierProvider<TransactionFiltersNotifier, TransactionFilterState>(
  (Ref ref) => TransactionFiltersNotifier(),
);

/// Derived list of transactions for the current user with the active
/// [transactionFiltersProvider] applied.
///
/// Streams the full transaction set and re-applies
/// [TransactionsController.applyFilter] whenever either the data or the filter
/// changes. The pure matching logic lives in the controller so it stays
/// unit-testable without a widget tree.
final filteredTransactionsProvider =
    Provider<AsyncValue<List<Transaction>>>((Ref ref) {
  final TransactionFilterState filter = ref.watch(transactionFiltersProvider);
  final AsyncValue<List<Transaction>> all =
      ref.watch(transactionsStreamProvider);
  return all.whenData(
    (List<Transaction> txs) =>
        TransactionsController.applyFilter(txs, filter),
  );
});
