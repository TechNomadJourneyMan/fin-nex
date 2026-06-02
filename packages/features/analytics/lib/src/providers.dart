import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/pf_domain.dart';

import 'state/analytics_period.dart';

/// Provides the [TransactionsRepository] used by analytics.
///
/// Must be overridden in `main()` with a concrete implementation (the
/// sync-aware one from `pf_data_sync`, or the local-only one from
/// `pf_data_local`).
final analyticsTransactionsRepositoryProvider =
    Provider<TransactionsRepository>((Ref ref) {
  throw UnimplementedError(
    'analyticsTransactionsRepositoryProvider must be overridden with a '
    'concrete TransactionsRepository instance.',
  );
});

/// Provides the [CategoriesRepository] used by analytics for labels.
///
/// Must be overridden in `main()`.
final analyticsCategoriesRepositoryProvider =
    Provider<CategoriesRepository>((Ref ref) {
  throw UnimplementedError(
    'analyticsCategoriesRepositoryProvider must be overridden with a '
    'concrete CategoriesRepository instance.',
  );
});

/// Provides the active user ULID. Override in app bootstrap once the session
/// is hydrated.
final analyticsCurrentUserIdProvider = Provider<Ulid>((Ref ref) {
  throw UnimplementedError(
    'analyticsCurrentUserIdProvider must be overridden with the signed-in '
    'user ULID.',
  );
});

/// Display currency for analytics aggregates. Defaults to KZT until the
/// settings repository is wired up in the app shell.
final analyticsDisplayCurrencyProvider =
    Provider<Currency>((Ref ref) => Currency.kzt);

/// Mutable holder for the currently selected analytics period.
final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
  (Ref ref) => AnalyticsPeriod.of(AnalyticsPeriodKind.month),
);

/// Live stream of categories for the active user — used for chart legends
/// and the drill-down screen.
final analyticsCategoriesStreamProvider =
    StreamProvider<List<Category>>((Ref ref) {
  final CategoriesRepository repo =
      ref.watch(analyticsCategoriesRepositoryProvider);
  final Ulid userId = ref.watch(analyticsCurrentUserIdProvider);
  return repo.watchAll(userId);
});

/// Live stream of all transactions for the active user. The controller
/// re-aggregates whenever this stream or the active period changes.
final analyticsTransactionsStreamProvider =
    StreamProvider<List<Transaction>>((Ref ref) {
  final TransactionsRepository repo =
      ref.watch(analyticsTransactionsRepositoryProvider);
  final Ulid userId = ref.watch(analyticsCurrentUserIdProvider);
  return repo.watchAll(userId);
});

/// First-of-month anchor for the spending-calendar page. Normalised to the
/// first day of the visible month (local midnight). Paging ← / → on the
/// calendar updates this.
final calendarMonthProvider = StateProvider<DateTime>((Ref ref) {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Daily expense totals (in **minor units**) for the month containing [month].
///
/// Keyed by local-midnight `DateTime`. Only non-deleted *expense* transactions
/// whose currency matches [analyticsDisplayCurrencyProvider] and whose
/// `occurredAt` falls inside the calendar month are summed. Days with no
/// spend are simply absent from the map (callers treat missing as `0`).
final dailyTotalsProvider =
    Provider.family<Map<DateTime, int>, DateTime>((Ref ref, DateTime month) {
  final AsyncValue<List<Transaction>> txsAsync =
      ref.watch(analyticsTransactionsStreamProvider);
  final Currency currency = ref.watch(analyticsDisplayCurrencyProvider);
  final List<Transaction> all = txsAsync.valueOrNull ?? const <Transaction>[];

  final DateTime monthStart = DateTime(month.year, month.month, 1);
  final DateTime monthEnd = DateTime(month.year, month.month + 1, 1);

  final Map<DateTime, int> totals = <DateTime, int>{};
  for (final Transaction tx in all) {
    if (tx.deletedAt != null) continue;
    if (tx.type != TransactionType.expense) continue;
    if (tx.amount.currency != currency) continue;
    final DateTime when = tx.occurredAt.toLocal();
    if (when.isBefore(monthStart)) continue;
    if (!when.isBefore(monthEnd)) continue;
    final DateTime day = DateTime(when.year, when.month, when.day);
    totals[day] = (totals[day] ?? 0) + tx.amount.minor.toInt();
  }
  return totals;
});
