import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_charts/pf_core_charts.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers.dart';
import '../state/analytics_period.dart';

/// Calendar / heatmap view of spending intensity.
///
/// Shows the active analytics period as a GitHub-style heatmap. Tapping a
/// day reveals the day total in a snackbar — full drill-down is left to a
/// future iteration (see TODO below).
class CalendarViewPage extends ConsumerWidget {
  /// Default constructor.
  const CalendarViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final AnalyticsPeriod period = ref.watch(analyticsPeriodProvider);
    final Currency currency = ref.watch(analyticsDisplayCurrencyProvider);
    final AsyncValue<List<Transaction>> txsAsync =
        ref.watch(analyticsTransactionsStreamProvider);
    final NumberFormat fmt = NumberFormat.currency(
      locale: l10n.localeName,
      symbol: currency.code,
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calTitle),
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
            final Map<DateTime, double> byDay =
                _dailyExpenseTotals(all, period, currency);
            if (byDay.values.every((double v) => v == 0)) {
              return PfEmptyState(
                icon: Icons.calendar_today_outlined,
                title: l10n.anEmpty,
                body: l10n.calDayEmpty,
              );
            }
            final DateFormat df = DateFormat.yMMMd(l10n.localeName);
            return ListView(
              padding: EdgeInsets.all(context.fnxSpacing.s5),
              children: <Widget>[
                PfCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${df.format(period.from)} – '
                        '${df.format(period.to.subtract(
                          const Duration(milliseconds: 1),
                        ))}',
                        style: context.fnxTypography.bodySm,
                      ),
                      SizedBox(height: context.fnxSpacing.s4),
                      PfHeatmapCalendar(
                        semanticDescription: 'Daily expenses '
                            '${df.format(period.from)} – '
                            '${df.format(period.to.subtract(
                          const Duration(milliseconds: 1),
                        ))}. '
                            'Total ${fmt.format(byDay.values.fold<double>(
                          0,
                          (double a, double v) => a + v,
                        ))}.',
                        from: period.from,
                        to: period.to.subtract(const Duration(days: 1)),
                        valueByDay: byDay,
                        tileSize: 28,
                        onDayTap: (DateTime day) {
                          // TODO(F-203): navigate to day-detail bottom sheet.
                          final double v = byDay[day] ?? 0;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                '${df.format(day)} · ${fmt.format(v)}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Map<DateTime, double> _dailyExpenseTotals(
    List<Transaction> all,
    AnalyticsPeriod period,
    Currency currency,
  ) {
    final Map<DateTime, double> map = <DateTime, double>{};
    for (final Transaction tx in all) {
      if (tx.deletedAt != null) continue;
      if (tx.type != TransactionType.expense) continue;
      if (tx.amount.currency != currency) continue;
      final DateTime when = tx.occurredAt.toLocal();
      if (when.isBefore(period.from)) continue;
      if (!when.isBefore(period.to)) continue;
      final DateTime day = DateTime(when.year, when.month, when.day);
      map[day] = (map[day] ?? 0) + tx.amount.major.toDouble();
    }
    return map;
  }
}
