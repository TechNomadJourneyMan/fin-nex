// Hero balance card shown at the top of the dashboard.
//
// Renders the total balance, the period selector segments, and the
// sub-amounts (income / expense) for the active period.

import 'package:flutter/material.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';

import '../controllers/dashboard_controller.dart';

/// Hero balance card.
class BalanceCard extends StatelessWidget {
  /// Default constructor.
  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.income,
    required this.expense,
    required this.period,
    required this.onPeriodChanged,
    this.todayLabel = 'Today',
    this.weekLabel = 'Week',
    this.monthLabel = 'Month',
    this.balanceLabel = 'Total balance',
    this.incomeLabel = 'Income',
    this.expenseLabel = 'Expenses',
    this.locale = 'en',
  });

  /// Aggregate balance across all `includeInTotal` accounts.
  final Money totalBalance;

  /// Income within [period].
  final Money income;

  /// Expense within [period].
  final Money expense;

  /// Active period selector.
  final DashboardPeriod period;

  /// Called when the user picks a different period.
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  /// Localized label for the "Today" segment.
  final String todayLabel;

  /// Localized label for the "Week" segment.
  final String weekLabel;

  /// Localized label for the "Month" segment.
  final String monthLabel;

  /// Localized label for the balance heading.
  final String balanceLabel;

  /// Localized label for the income column.
  final String incomeLabel;

  /// Localized label for the expense column.
  final String expenseLabel;

  /// BCP-47 locale tag for number formatting.
  final String locale;

  String _formatMoney(Money m) {
    final symbol = m.currency.symbol;
    return formatFnxAmount(
      m.minor.toInt(),
      locale: locale,
      fractionDigits: 0,
      currencySymbol: symbol,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    return Semantics(
      label: '$balanceLabel ${_formatMoney(totalBalance)}',
      child: FnxCard(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              balanceLabel,
              style: typo.bodySm.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMoney(totalBalance),
              style: typo.displayMd,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            FnxSegmentedControl<DashboardPeriod>(
              segments: <DashboardPeriod, String>{
                DashboardPeriod.today: todayLabel,
                DashboardPeriod.week: weekLabel,
                DashboardPeriod.month: monthLabel,
              },
              value: period,
              onChanged: onPeriodChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: incomeLabel,
                    formattedAmount: _formatMoney(income),
                    color: colors.income,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: expenseLabel,
                    formattedAmount: _formatMoney(expense),
                    color: colors.error,
                    negative: !expense.isZero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.formattedAmount,
    required this.color,
    this.negative = false,
  });

  final String label;
  final String formattedAmount;
  final Color color;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final prefix = negative ? '−' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: typo.bodySm.copyWith(color: colors.textMuted)),
        const SizedBox(height: 2),
        Text(
          '$prefix$formattedAmount',
          style: typo.amountMd.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
