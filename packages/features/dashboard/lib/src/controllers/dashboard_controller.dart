// Dashboard controller — aggregates the data shown on the home page.
//
// The controller is an [AsyncNotifier] so the page can react to loading,
// error, and refreshed states uniformly. It fans out into the four
// repositories registered via providers and folds the results into a
// single immutable [DashboardSnapshot].

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/pf_domain.dart';

import '../providers.dart';

/// Coarse-grained period selector used by the dashboard header.
enum DashboardPeriod {
  /// Today only.
  today,

  /// Current ISO week.
  week,

  /// Current calendar month (default).
  month,
}

/// Immutable snapshot of everything the dashboard renders.
class DashboardSnapshot {
  /// Default constructor.
  const DashboardSnapshot({
    required this.period,
    required this.totalBalance,
    required this.periodIncome,
    required this.periodExpense,
    required this.topCategories,
    required this.recent,
    required this.categoriesById,
    required this.accountsById,
  });

  /// Active period selector.
  final DashboardPeriod period;

  /// Sum of all `includeInTotal` accounts.
  final Money totalBalance;

  /// Income within [period].
  final Money periodIncome;

  /// Expense within [period].
  final Money periodExpense;

  /// Top-5 category slices for [period].
  final List<CategoryBreakdownSlice> topCategories;

  /// Most-recent 10 transactions for [period].
  final List<Transaction> recent;

  /// Lookup of [Category] by id (for rendering names/colors).
  final Map<Ulid, Category> categoriesById;

  /// Lookup of [Account] by id (for rendering account names).
  final Map<Ulid, Account> accountsById;

  /// Returns a copy with the given fields replaced.
  DashboardSnapshot copyWith({
    DashboardPeriod? period,
    Money? totalBalance,
    Money? periodIncome,
    Money? periodExpense,
    List<CategoryBreakdownSlice>? topCategories,
    List<Transaction>? recent,
    Map<Ulid, Category>? categoriesById,
    Map<Ulid, Account>? accountsById,
  }) =>
      DashboardSnapshot(
        period: period ?? this.period,
        totalBalance: totalBalance ?? this.totalBalance,
        periodIncome: periodIncome ?? this.periodIncome,
        periodExpense: periodExpense ?? this.periodExpense,
        topCategories: topCategories ?? this.topCategories,
        recent: recent ?? this.recent,
        categoriesById: categoriesById ?? this.categoriesById,
        accountsById: accountsById ?? this.accountsById,
      );
}

/// AsyncNotifier that loads [DashboardSnapshot] data on demand.
class DashboardController extends AsyncNotifier<DashboardSnapshot> {
  DashboardPeriod _period = DashboardPeriod.month;

  @override
  Future<DashboardSnapshot> build() => _load(_period);

  /// Switches the active [DashboardPeriod] and reloads.
  Future<void> setPeriod(DashboardPeriod next) async {
    if (next == _period) return;
    _period = next;
    state = const AsyncValue<DashboardSnapshot>.loading();
    state = await AsyncValue.guard(() => _load(next));
  }

  /// Forces a refresh of the current period.
  Future<void> refresh() async {
    state = const AsyncValue<DashboardSnapshot>.loading();
    state = await AsyncValue.guard(() => _load(_period));
  }

  Future<DashboardSnapshot> _load(DashboardPeriod period) async {
    final userId = ref.read(dashboardUserIdProvider);
    final accountsRepo = ref.read(dashboardAccountsRepositoryProvider);
    final txRepo = ref.read(dashboardTransactionsRepositoryProvider);
    final analyticsRepo = ref.read(dashboardAnalyticsRepositoryProvider);
    final categoriesRepo = ref.read(dashboardCategoriesRepositoryProvider);

    final accounts = await accountsRepo.list(userId);
    final range = _rangeFor(period);

    final results = await Future.wait<Object>(<Future<Object>>[
      txRepo.list(
        userId,
        TransactionFilter(from: range.from, to: range.to),
      ),
      analyticsRepo.categoryBreakdown(
        userId,
        from: range.from,
        to: range.to,
      ),
      categoriesRepo.list(userId),
    ]);

    final periodTx = results[0] as List<Transaction>;
    final breakdown = results[1] as List<CategoryBreakdownSlice>;
    final categories = results[2] as List<Category>;

    final currency =
        accounts.isNotEmpty ? accounts.first.currency : Currency.kzt;

    var income = Money.zero(currency);
    var expense = Money.zero(currency);
    for (final t in periodTx) {
      if (t.amount.currency != currency) continue;
      if (t.type == TransactionType.income) {
        income = income + t.amount;
      } else if (t.type == TransactionType.expense) {
        expense = expense + t.amount;
      }
    }

    var balance = Money.zero(currency);
    for (final a in accounts) {
      if (!a.includeInTotal) continue;
      if (a.currency != currency) continue;
      balance = balance + a.balance;
    }

    final recent = List<Transaction>.from(periodTx)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return DashboardSnapshot(
      period: period,
      totalBalance: balance,
      periodIncome: income,
      periodExpense: expense,
      topCategories: breakdown.take(5).toList(growable: false),
      recent: recent.take(10).toList(growable: false),
      categoriesById: <Ulid, Category>{
        for (final c in categories) c.id: c,
      },
      accountsById: <Ulid, Account>{
        for (final a in accounts) a.id: a,
      },
    );
  }

  _DateRange _rangeFor(DashboardPeriod p) {
    final now = DateTime.now();
    switch (p) {
      case DashboardPeriod.today:
        final start = DateTime(now.year, now.month, now.day);
        return _DateRange(start, start.add(const Duration(days: 1)));
      case DashboardPeriod.week:
        final daysSinceMonday = (now.weekday - DateTime.monday) % 7;
        final start = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: daysSinceMonday));
        return _DateRange(start, start.add(const Duration(days: 7)));
      case DashboardPeriod.month:
        final start = DateTime(now.year, now.month);
        final next = DateTime(now.year, now.month + 1);
        return _DateRange(start, next);
    }
  }
}

class _DateRange {
  const _DateRange(this.from, this.to);
  final DateTime from;
  final DateTime to;
}
