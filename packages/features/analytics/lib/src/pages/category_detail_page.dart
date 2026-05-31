import 'package:flutter/material.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers.dart';
import '../state/analytics_period.dart';

/// Drill-down: lists transactions for a single category within the active
/// analytics period. Shows the total at the top.
class CategoryDetailPage extends ConsumerWidget {
  /// Default constructor.
  const CategoryDetailPage({super.key, required this.categoryId});

  /// Category to drill into. `null` keeps an "uncategorised" view.
  final Ulid? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final AnalyticsPeriod period = ref.watch(analyticsPeriodProvider);
    final Currency currency = ref.watch(analyticsDisplayCurrencyProvider);
    final AsyncValue<List<Transaction>> txsAsync =
        ref.watch(analyticsTransactionsStreamProvider);
    final AsyncValue<List<Category>> catsAsync =
        ref.watch(analyticsCategoriesStreamProvider);
    final colors = context.fnxColors;

    final String categoryName = (() {
      final List<Category> cats = catsAsync.valueOrNull ?? const <Category>[];
      if (categoryId == null) return l10n.commonNone;
      for (final Category c in cats) {
        if (c.id == categoryId) return c.name;
      }
      return l10n.commonNone;
    })();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/analytics');
            }
          },
        ),
      ),
      body: SafeArea(
        child: txsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, StackTrace _) => Center(
            child: Text('${l10n.commonRetry}: $e'),
          ),
          data: (List<Transaction> all) {
            final List<Transaction> filtered =
                _filter(all, period, currency, categoryId);
            if (filtered.isEmpty) {
              return FnxEmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.anEmpty,
                body: l10n.calDayEmpty,
              );
            }
            Money total = Money.zero(currency);
            for (final Transaction tx in filtered) {
              total = total + tx.amount;
            }
            final NumberFormat fmt = NumberFormat.currency(
              locale: l10n.localeName,
              symbol: currency.code,
              decimalDigits: 0,
            );
            final DateFormat df = DateFormat.yMMMd(l10n.localeName);
            return ListView.separated(
              padding: EdgeInsets.all(context.fnxSpacing.s5),
              itemCount: filtered.length + 1,
              separatorBuilder: (_, __) =>
                  SizedBox(height: context.fnxSpacing.s3),
              itemBuilder: (BuildContext context, int idx) {
                if (idx == 0) {
                  return FnxCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          l10n.anSumExpense,
                          style: context.fnxTypography.bodyMd,
                        ),
                        Text(
                          fmt.format(total.major.toDouble()),
                          style: context.fnxTypography.amountMd
                              .copyWith(color: colors.error),
                        ),
                      ],
                    ),
                  );
                }
                final Transaction tx = filtered[idx - 1];
                return FnxListItem(
                  title: tx.description?.trim().isNotEmpty == true
                      ? tx.description!
                      : categoryName,
                  subtitle: df.format(tx.occurredAt.toLocal()),
                  trailing: Text(
                    fmt.format(tx.amount.major.toDouble()),
                    style: context.fnxTypography.amountSm.copyWith(
                      color: tx.type == TransactionType.income
                          ? colors.income
                          : colors.error,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static List<Transaction> _filter(
    List<Transaction> all,
    AnalyticsPeriod period,
    Currency currency,
    Ulid? categoryId,
  ) {
    final List<Transaction> out = <Transaction>[];
    for (final Transaction tx in all) {
      if (tx.deletedAt != null) continue;
      if (tx.type != TransactionType.expense &&
          tx.type != TransactionType.income) {
        continue;
      }
      if (tx.amount.currency != currency) continue;
      if (tx.categoryId != categoryId) continue;
      final DateTime when = tx.occurredAt.toLocal();
      if (when.isBefore(period.from)) continue;
      if (!when.isBefore(period.to)) continue;
      out.add(tx);
    }
    out.sort((Transaction a, Transaction b) =>
        b.occurredAt.compareTo(a.occurredAt));
    return out;
  }
}
