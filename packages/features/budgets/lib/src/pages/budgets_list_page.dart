// Budgets list page — each row shows an [PfBudgetProgress] with the
// computed spend for the current period.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/domain.dart';
import 'package:go_router/go_router.dart';

import '../controllers/budgets_controller.dart';
import '../providers.dart';

/// List of active budgets with progress bars and a "create" FAB.
class BudgetsListPage extends ConsumerStatefulWidget {
  /// Creates the page.
  const BudgetsListPage({super.key});

  @override
  ConsumerState<BudgetsListPage> createState() => _BudgetsListPageState();
}

class _BudgetsListPageState extends ConsumerState<BudgetsListPage> {
  /// Budget IDs we've already fired a "limit reached" haptic for this session,
  /// so re-renders don't re-buzz the device.
  final Set<String> _warnedExceeded = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final state = ref.watch(budgetsControllerProvider);
    final txs = ref.watch(budgetsTransactionsStreamProvider);
    final calc = ref.watch(budgetCalculatorProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.budgetsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/budgets/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.budgetsCreate),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: TextStyle(color: colors.error)),
        ),
        data: (budgets) {
          if (budgets.isEmpty) {
            return PfEmptyState(
              icon: Icons.pie_chart_outline,
              title: l10n.budgetsEmpty,
              body: l10n.budgetsCreate,
              ctaLabel: l10n.budgetsCreate,
              onCta: () => context.push('/budgets/new'),
            );
          }
          final txList = txs.maybeWhen(
            data: (l) => l,
            orElse: () => const <Transaction>[],
          );
          return ListView.separated(
            padding: EdgeInsets.all(spacing.s5),
            itemCount: budgets.length,
            separatorBuilder: (_, __) => SizedBox(height: spacing.s4),
            itemBuilder: (context, i) {
              final b = budgets[i];
              final spent = calc.spent(b, txList);
              final int spentMinor = spent.minor.toInt();
              final int limitMinor = b.amount.minor.toInt();
              // Fire a "warn" haptic the first time we observe a budget at or
              // over its limit during this session. The Set guards against
              // re-buzzing on every rebuild while the budget stays exceeded.
              if (limitMinor > 0 && spentMinor >= limitMinor) {
                final String key = b.id.value;
                if (!_warnedExceeded.contains(key)) {
                  _warnedExceeded.add(key);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    ref.read(feedbackServiceProvider).warn();
                  });
                }
              }
              return _BudgetRow(
                budget: b,
                spentMinor: spentMinor,
                onTap: () => context.push('/budgets/${b.id.value}/edit'),
              );
            },
          );
        },
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.budget,
    required this.spentMinor,
    required this.onTap,
  });

  final Budget budget;
  final int spentMinor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.fnxColors.surface,
      borderRadius: BorderRadius.circular(context.fnxRadii.r4),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.fnxRadii.r4),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(context.fnxSpacing.s5),
          child: PfBudgetProgress(
            label: budget.name,
            spentMinor: spentMinor,
            limitMinor: budget.amount.minor.toInt(),
          ),
        ),
      ),
    );
  }
}
