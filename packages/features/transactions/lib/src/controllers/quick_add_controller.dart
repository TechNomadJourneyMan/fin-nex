import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/fnx_domain.dart';

import '../predictor/category_predictor.dart';
import '../providers.dart';

/// Smart-default suggestion returned by [QuickAddController.suggestFor].
class QuickAddDefaults extends Equatable {
  /// Default ctor.
  const QuickAddDefaults({this.accountId, this.categoryId});

  /// Suggested account id, or `null` if no signal available.
  final Ulid? accountId;

  /// Suggested category id, or `null` if no signal available.
  final Ulid? categoryId;

  @override
  List<Object?> get props => <Object?>[accountId, categoryId];
}

/// Reactive snapshot of the quick-add sheet's editable form state.
class QuickAddFormState extends Equatable {
  /// Default ctor.
  const QuickAddFormState({
    required this.type,
    this.amountMinor = 0,
    this.accountId,
    this.categoryId,
    this.note,
  });

  /// Transaction type (expense/income).
  final TransactionType type;

  /// Amount in minor units (e.g. tiyn) — always non-negative.
  final int amountMinor;

  /// Selected account ULID.
  final Ulid? accountId;

  /// Selected category ULID.
  final Ulid? categoryId;

  /// Optional one-line note.
  final String? note;

  /// True when the form can be persisted.
  bool get isValid =>
      amountMinor > 0 && accountId != null && categoryId != null;

  /// Returns a copy with the given fields replaced.
  QuickAddFormState copyWith({
    TransactionType? type,
    int? amountMinor,
    Ulid? accountId,
    Ulid? categoryId,
    String? note,
    bool clearNote = false,
  }) {
    return QuickAddFormState(
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[type, amountMinor, accountId, categoryId, note];
}

/// Owns the quick-add sheet state and the save pipeline.
///
/// The family argument is the [TransactionType] so we can host two
/// independent instances (expense + income) without state bleed.
class QuickAddController
    extends AutoDisposeFamilyNotifier<QuickAddFormState, TransactionType> {
  @override
  QuickAddFormState build(TransactionType arg) {
    // Seed with smart defaults pulled synchronously from the cached
    // streams — values arrive once those streams have any data.
    final QuickAddDefaults defaults = suggestFor(arg);
    return QuickAddFormState(
      type: arg,
      accountId: defaults.accountId,
      categoryId: defaults.categoryId,
    );
  }

  /// Updates the entered amount (in minor units).
  void setAmount(int minor) {
    state = state.copyWith(amountMinor: minor < 0 ? 0 : minor);
  }

  /// Selects an account.
  void setAccount(Ulid id) {
    state = state.copyWith(accountId: id);
  }

  /// Selects a category.
  void setCategory(Ulid id) {
    state = state.copyWith(categoryId: id);
  }

  /// Updates the note. Pass `null` (or empty) to clear.
  void setNote(String? note) {
    if (note == null || note.trim().isEmpty) {
      state = state.copyWith(clearNote: true);
    } else {
      state = state.copyWith(note: note);
    }
  }

  /// Computes smart defaults for [type] from currently-cached state.
  ///
  /// Best-effort: if the streams haven't yielded yet, returns nulls.
  QuickAddDefaults suggestFor(TransactionType type) {
    final CategoryPredictor predictor = ref.read(categoryPredictorProvider);
    final List<Transaction> recent =
        ref.read(transactionsStreamProvider).valueOrNull ?? <Transaction>[];

    Ulid? account =
        predictor.predictAccount(transactions: recent, type: type);
    if (account == null) {
      // Fall back to the first available account.
      final List<Account> accounts =
          ref.read(accountsStreamProvider).valueOrNull ?? <Account>[];
      if (accounts.isNotEmpty) {
        account = accounts.first.id;
      }
    }

    Ulid? category =
        predictor.predict(transactions: recent, type: type);
    if (category == null) {
      // Fall back to the first matching category for the type.
      final List<Category> categories =
          ref.read(categoriesStreamProvider).valueOrNull ?? <Category>[];
      final CategoryType ctype = _matchCategoryType(type);
      final Iterable<Category> matching = categories.where(
        (Category c) => c.type == ctype && !c.isArchived,
      );
      if (matching.isNotEmpty) {
        category = matching.first.id;
      }
    }
    return QuickAddDefaults(accountId: account, categoryId: category);
  }

  /// Persists the current form as a new [Transaction].
  ///
  /// Returns the saved transaction on success, or throws [StateError] if
  /// the form is not yet valid.
  Future<Transaction> save() async {
    final QuickAddFormState s = state;
    if (!s.isValid) {
      throw StateError('Quick-add form is incomplete.');
    }
    final TransactionsRepository repo =
        ref.read(transactionsRepositoryProvider);
    final Ulid userId = ref.read(currentUserIdProvider);
    final Currency currency = ref.read(defaultCurrencyProvider);

    final DateTime nowUtc = DateTime.now().toUtc();
    final Transaction tx = Transaction(
      id: Ulid.now(at: nowUtc),
      userId: userId,
      accountId: s.accountId!,
      type: s.type,
      amount: Money(BigInt.from(s.amountMinor), currency),
      categoryId: s.categoryId,
      occurredAt: nowUtc,
      description: s.note,
      createdAt: nowUtc,
      updatedAt: nowUtc,
      source: 'manual',
      attachmentIds: const <Ulid>[],
      tagIds: const <Ulid>[],
    );
    await repo.upsert(tx);
    // Reset for the next entry but keep account/category as sticky defaults.
    state = QuickAddFormState(
      type: s.type,
      accountId: s.accountId,
      categoryId: s.categoryId,
    );
    return tx;
  }

  static CategoryType _matchCategoryType(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return CategoryType.expense;
      case TransactionType.income:
        return CategoryType.income;
      case TransactionType.transfer:
        return CategoryType.transfer;
      case TransactionType.adjustment:
        return CategoryType.adjustment;
    }
  }
}

/// Family of [QuickAddController] keyed by [TransactionType].
final quickAddControllerProvider = NotifierProvider.autoDispose
    .family<QuickAddController, QuickAddFormState, TransactionType>(
  QuickAddController.new,
);
