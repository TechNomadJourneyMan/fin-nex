// Compact list of recent transactions used at the bottom of the dashboard.
//
// Uses `PfListItem` from `pf_core_widgets`; the list is intentionally
// non-scrollable (relies on the parent `ListView`).

import 'package:flutter/material.dart' hide Category;
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:intl/intl.dart';

/// Renders up to N recent [Transaction] rows.
class RecentTransactionsList extends StatelessWidget {
  /// Default constructor.
  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.categoriesById,
    this.onTapTransaction,
    this.locale = 'en',
    this.emptyTitle = 'No transactions yet',
    this.emptyCta = 'Add your first expense',
    this.onEmptyCta,
  });

  /// Transactions to render (already sorted desc by `occurredAt`).
  final List<Transaction> transactions;

  /// Lookup for resolving category names.
  final Map<Ulid, Category> categoriesById;

  /// Tap handler.
  final ValueChanged<Transaction>? onTapTransaction;

  /// BCP-47 locale for date / amount formatting.
  final String locale;

  /// Title for the empty state.
  final String emptyTitle;

  /// CTA label for the empty state.
  final String emptyCta;

  /// CTA handler for the empty state.
  final VoidCallback? onEmptyCta;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final timeFmt = DateFormat.Hm(locale);

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: colors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(emptyTitle, style: typo.bodyMd),
            if (onEmptyCta != null) ...[
              const SizedBox(height: 12),
              PfButton(
                label: emptyCta,
                onPressed: onEmptyCta,
                variant: PfButtonVariant.primary,
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final t in transactions)
          PfListItem(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: colors.brandSubtle,
              child: Icon(
                t.type == TransactionType.income
                    ? Icons.south_west
                    : Icons.north_east,
                size: 18,
                color: t.type == TransactionType.income
                    ? colors.income
                    : colors.error,
              ),
            ),
            title: t.description ?? (categoriesById[t.categoryId]?.name ?? '—'),
            subtitle: timeFmt.format(t.occurredAt.toLocal()),
            trailing: Text(
              _formatSigned(t),
              style: typo.amountMd.copyWith(
                color: t.type == TransactionType.income
                    ? colors.income
                    : colors.error,
              ),
            ),
            onTap: onTapTransaction == null ? null : () => onTapTransaction!(t),
          ),
      ],
    );
  }

  String _formatSigned(Transaction t) {
    final formatted = formatPfAmount(
      t.amount.minor.toInt(),
      locale: locale,
      fractionDigits: 0,
      currencySymbol: t.amount.currency.symbol,
    );
    if (t.type == TransactionType.expense) {
      return '−$formatted';
    }
    if (t.type == TransactionType.income) {
      return '+$formatted';
    }
    return formatted;
  }
}
