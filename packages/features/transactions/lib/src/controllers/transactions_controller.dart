import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/fnx_domain.dart';

import '../providers.dart';
import '../state/transaction_filter_state.dart';

/// Holds the live, filter-aware list of transactions for the current user.
class TransactionsController
    extends AutoDisposeFamilyAsyncNotifier<List<Transaction>, TransactionFilterState> {
  StreamSubscription<List<Transaction>>? _sub;

  @override
  FutureOr<List<Transaction>> build(TransactionFilterState arg) {
    final TransactionsRepository repo = ref.watch(transactionsRepositoryProvider);
    final Ulid userId = ref.watch(currentUserIdProvider);

    // Cancel any previous live subscription when the family argument changes
    // or the controller is disposed.
    _sub?.cancel();
    _sub = repo.watchAll(userId).listen(
      (List<Transaction> all) {
        final List<Transaction> filtered = applyFilter(all, arg);
        state = AsyncData<List<Transaction>>(filtered);
      },
      onError: (Object e, StackTrace st) {
        state = AsyncError<List<Transaction>>(e, st);
      },
    );
    ref.onDispose(() {
      _sub?.cancel();
      _sub = null;
    });

    // First snapshot via list() so we don't block on the stream.
    return repo
        .list(userId, arg.toRepositoryFilter())
        .then((List<Transaction> snap) => applyFilter(snap, arg));
  }

  /// Soft-deletes a transaction. Caller is responsible for offering undo via
  /// [restore] within the snackbar window.
  Future<void> softDelete(Ulid id) async {
    final TransactionsRepository repo = ref.read(transactionsRepositoryProvider);
    await repo.softDelete(id);
  }

  /// Restores a previously soft-deleted [tx] by clearing `deletedAt`.
  Future<void> restore(Transaction tx) async {
    final TransactionsRepository repo = ref.read(transactionsRepositoryProvider);
    final Transaction restored = tx.copyWith(
      updatedAt: DateTime.now().toUtc(),
    );
    // copyWith doesn't support `null` for deletedAt — manually reconstruct.
    final Transaction cleared = Transaction(
      id: restored.id,
      userId: restored.userId,
      accountId: restored.accountId,
      type: restored.type,
      amount: restored.amount,
      occurredAt: restored.occurredAt,
      createdAt: restored.createdAt,
      updatedAt: restored.updatedAt,
      source: restored.source,
      attachmentIds: restored.attachmentIds,
      tagIds: restored.tagIds,
      categoryId: restored.categoryId,
      description: restored.description,
      transferAccountId: restored.transferAccountId,
      transferGroupId: restored.transferGroupId,
      recurringRuleId: restored.recurringRuleId,
      externalRef: restored.externalRef,
      lat: restored.lat,
      lng: restored.lng,
      // deletedAt deliberately omitted == null
    );
    await repo.upsert(cleared);
  }

  /// Persists [tx]. Used by both quick-add and the full form.
  Future<void> save(Transaction tx) async {
    final TransactionsRepository repo = ref.read(transactionsRepositoryProvider);
    await repo.upsert(tx);
  }

  /// Pure helper that applies a [TransactionFilterState] to [all].
  ///
  /// Exposed as a static so tests can exercise the matching rules without
  /// spinning up a [ProviderContainer].
  static List<Transaction> applyFilter(
    List<Transaction> all,
    TransactionFilterState f,
  ) {
    Iterable<Transaction> out = all.where(
      (Transaction t) => t.deletedAt == null,
    );

    if (f.from != null) {
      out = out.where((Transaction t) => !t.occurredAt.isBefore(f.from!));
    }
    if (f.to != null) {
      out = out.where((Transaction t) => t.occurredAt.isBefore(f.to!));
    }
    if (f.accountIds.isNotEmpty) {
      final Set<String> ids =
          f.accountIds.map((Ulid u) => u.value).toSet();
      out = out.where((Transaction t) => ids.contains(t.accountId.value));
    }
    if (f.categoryIds.isNotEmpty) {
      final Set<String> ids =
          f.categoryIds.map((Ulid u) => u.value).toSet();
      out = out.where(
        (Transaction t) =>
            t.categoryId != null && ids.contains(t.categoryId!.value),
      );
    }
    if (f.types.isNotEmpty) {
      final Set<TransactionType> set = f.types.toSet();
      out = out.where((Transaction t) => set.contains(t.type));
    }
    final String? q = f.searchText?.trim();
    if (q != null && q.isNotEmpty) {
      final String needle = q.toLowerCase();
      out = out.where((Transaction t) {
        final String? d = t.description;
        if (d == null) {
          return false;
        }
        return d.toLowerCase().contains(needle);
      });
    }

    final List<Transaction> sorted = out.toList(growable: false)
      ..sort((Transaction a, Transaction b) =>
          b.occurredAt.compareTo(a.occurredAt));
    return sorted;
  }
}

/// Family of [TransactionsController] keyed by the active filter snapshot.
final transactionsControllerProvider = AsyncNotifierProvider.autoDispose
    .family<TransactionsController, List<Transaction>, TransactionFilterState>(
  TransactionsController.new,
);
