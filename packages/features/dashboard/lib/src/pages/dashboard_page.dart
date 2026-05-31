// Dashboard / home page.
//
// Top   — balance hero card with period selector + income/expense.
// Middle — quick stats + top-5 categories donut.
// Bottom — last 10 transactions.
// FAB   — quick-add expense (deep-links into the transactions feature).
//
// The page is built around a single `dashboardControllerProvider` which
// fans out into accounts / transactions / analytics repositories and
// returns a [DashboardSnapshot] for one render cycle.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:go_router/go_router.dart';

import '../controllers/dashboard_controller.dart';
import '../providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/top_categories_pie.dart';

/// FinNex dashboard / home page. Routed at `/home`.
class DashboardPage extends ConsumerWidget {
  /// Default constructor.
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final async = ref.watch(dashboardControllerProvider);
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.navHome, style: typo.heading2),
        elevation: 0,
        backgroundColor: colors.background,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onQuickAdd(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.dashFab),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
          child: async.when(
            data: (snap) =>
                _DashboardContent(snapshot: snap, locale: locale, l10n: l10n),
            loading: () => const _LoadingView(),
            error: (err, _) => _ErrorView(
              error: err,
              onRetry: () =>
                  ref.read(dashboardControllerProvider.notifier).refresh(),
              retryLabel: l10n.commonRetry,
            ),
          ),
        ),
      ),
    );
  }

  void _onQuickAdd(BuildContext context) {
    // The transactions feature owns the actual quick-add sheet — for now
    // we route to its known path. The router maps either to a modal sheet
    // or a full-screen form depending on width.
    // TODO(F-DASH-QA): replace string with named route once router is wired.
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push('/transactions/new');
    }
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.snapshot,
    required this.locale,
    required this.l10n,
  });

  final DashboardSnapshot snapshot;
  final String locale;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        BalanceCard(
          totalBalance: snapshot.totalBalance,
          income: snapshot.periodIncome,
          expense: snapshot.periodExpense,
          period: snapshot.period,
          locale: locale,
          todayLabel: l10n.dashPeriodDay,
          weekLabel: l10n.dashPeriodWeek,
          monthLabel: l10n.dashPeriodMonth,
          onPeriodChanged: (p) =>
              ref.read(dashboardControllerProvider.notifier).setPeriod(p),
        ),
        const SizedBox(height: 16),
        QuickStatsCard(
          primaryLabel: l10n.dashRecent,
          primaryValue: snapshot.recent.length.toString(),
          secondaryLabel: l10n.dashPeriodMonth,
          secondaryValue: formatFnxAmount(
            snapshot.periodExpense.minor.toInt(),
            locale: locale,
            fractionDigits: 0,
            currencySymbol: snapshot.periodExpense.currency.symbol,
          ),
        ),
        const SizedBox(height: 16),
        TopCategoriesPie(
          slices: snapshot.topCategories,
          categoriesById: snapshot.categoriesById,
          title: l10n.dashRecent,
          seeAllLabel: l10n.dashSeeAll,
          onSeeAll: () => GoRouter.maybeOf(context)?.push('/analytics'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Text(l10n.dashRecent, style: typo.heading3)),
            TextButton(
              onPressed: () => GoRouter.maybeOf(context)?.push('/transactions'),
              child: Text(l10n.dashSeeAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: RecentTransactionsList(
            transactions: snapshot.recent,
            categoriesById: snapshot.categoriesById,
            locale: locale,
            emptyTitle: l10n.dashEmptyTitle,
            emptyCta: l10n.dashEmptyCta,
            onEmptyCta: () => GoRouter.maybeOf(context)?.push(
              '/transactions/new',
            ),
            onTapTransaction: (Transaction t) =>
                GoRouter.maybeOf(context)?.push('/transactions/${t.id.value}'),
          ),
        ),
      ],
    );
  }

}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: const <Widget>[
        FnxSkeleton(height: 168, borderRadius: BorderRadius.all(Radius.circular(16))),
        SizedBox(height: 16),
        FnxSkeleton(height: 88, borderRadius: BorderRadius.all(Radius.circular(16))),
        SizedBox(height: 16),
        FnxSkeleton(height: 240, borderRadius: BorderRadius.all(Radius.circular(16))),
        SizedBox(height: 24),
        FnxSkeleton(height: 320, borderRadius: BorderRadius.all(Radius.circular(16))),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.retryLabel,
  });

  final Object error;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(error.toString(), style: typo.bodyMd, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FnxButton(label: retryLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
