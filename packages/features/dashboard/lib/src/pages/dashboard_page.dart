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
import 'package:intl/intl.dart';

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
      // The MainShell already owns the AppBar (title + AI/Subs/Notifications
      // actions), so the dashboard is appbar-less.
      backgroundColor: const Color(0xFF0A0A0C),
      extendBody: true,
      floatingActionButton: null,
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
      router.push('/transactions/add');
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
    final NumberFormat money = NumberFormat.currency(
      locale: locale,
      symbol: snapshot.totalBalance.currency.symbol,
      decimalDigits: 0,
    );
    final Money delta = snapshot.periodIncome - snapshot.periodExpense;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 128),
      children: <Widget>[
        // 1. Hero balance — the canvas centerpiece.
        HeroBalance(
          amount: snapshot.totalBalance,
          delta: delta.isZero ? null : delta,
          period: l10n.dashPeriodMonth.toLowerCase(),
        ),
        const SizedBox(height: 28),

        // 2. Bento grid — 2×2 of GlassCards.
        LayoutBuilder(
          builder: (BuildContext _, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth > 600;
            final int cols = wide ? 4 : 2;
            final double gap = 12;
            final double tileW =
                (constraints.maxWidth - gap * (cols - 1)) / cols;
            final List<Widget> tiles = <Widget>[
              _BentoTile(
                width: tileW,
                title: 'Cashflow',
                value: money.format(snapshot.periodIncome.major.toDouble()),
                subtitle: 'Income · ${snapshot.period.name}',
                accent: const Color(0xFF24A148),
                icon: Icons.trending_up,
                onTap: () => GoRouter.maybeOf(context)?.push('/analytics'),
              ),
              _BentoTile(
                width: tileW,
                title: 'Expenses',
                value: money.format(snapshot.periodExpense.major.toDouble()),
                subtitle: '${snapshot.recent.length} ops',
                accent: const Color(0xFFFF453A),
                icon: Icons.trending_down,
                onTap: () =>
                    GoRouter.maybeOf(context)?.push('/transactions'),
              ),
              _BentoTile(
                width: tileW,
                title: 'Подписки',
                value: '4',
                subtitle: 'Netflix, Spotify…',
                accent: const Color(0xFFE5E5EA),
                icon: Icons.subscriptions_outlined,
                onTap: () =>
                    GoRouter.maybeOf(context)?.push('/subscriptions'),
              ),
              _BentoTile(
                width: tileW,
                title: 'AI Insights',
                value: 'Nova',
                subtitle: 'Готова к разговору',
                accent: const Color(0xFFE5E5EA),
                icon: Icons.auto_awesome_outlined,
                onTap: () => GoRouter.maybeOf(context)?.push('/ai-chat'),
                glow: true,
              ),
            ];
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: tiles,
            );
          },
        ),

        const SizedBox(height: 28),

        // 3. Recent transactions — inside a single GlassCard.
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Последние операции',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF2F2F3),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  GoRouter.maybeOf(context)?.push('/transactions'),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GlassCard(
          padding: EdgeInsets.zero,
          radius: 24,
          child: RecentTransactionsList(
            transactions: snapshot.recent,
            categoriesById: snapshot.categoriesById,
            locale: locale,
            emptyTitle: l10n.dashEmptyTitle,
            emptyCta: l10n.dashEmptyCta,
            onEmptyCta: () =>
                GoRouter.maybeOf(context)?.push('/transactions/add'),
            onTapTransaction: (Transaction t) => GoRouter.maybeOf(context)
                ?.push('/transactions/${t.id.value}'),
          ),
        ),
      ],
    );
  }
}

/// A single Bento tile built on top of [GlassCard].
class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.onTap,
    this.glow = false,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassCard(
        radius: 24,
        glow: glow,
        onTap: onTap,
        semanticsLabel: '$title: $value, $subtitle',
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: accent, size: 18),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    color: Color(0xFF8A8A93),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF2F2F3),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8A8A93),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
