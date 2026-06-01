import 'package:flutter/material.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_charts/pf_core_charts.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../analytics_summary.dart';
import '../controllers/analytics_controller.dart';
import '../providers.dart';
import '../routes/analytics_routes.dart';
import '../state/analytics_period.dart';

/// Top-level Analytics screen.
///
/// Composition (top → bottom):
///  * Period segmented control (Day | Week | Month | Year | Custom)
///  * Totals card (income / expense / net)
///  * Donut by category with tap-to-drill-down
///  * Bar chart by weekday
///  * Line cashflow chart
///  * Calendar shortcut
///
/// Honours `MediaQuery.disableAnimations` everywhere because charts inherit
/// that flag from the design-system primitives.
class AnalyticsPage extends ConsumerWidget {
  /// Default constructor.
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final AnalyticsPeriod period = ref.watch(analyticsPeriodProvider);
    final AsyncValue<AnalyticsSummary> async =
        ref.watch(analyticsControllerProvider);
    final AsyncValue<List<Category>> catsAsync =
        ref.watch(analyticsCategoriesStreamProvider);
    final Map<Ulid, Category> categoriesById = <Ulid, Category>{
      for (final Category c in catsAsync.valueOrNull ?? const <Category>[])
        c.id: c,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.anTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.calTitle,
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () =>
                context.goNamed(AnalyticsRouteNames.analyticsCalendar),
          ),
        ],
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, StackTrace _) => Center(
            child: Padding(
              padding: EdgeInsets.all(context.fnxSpacing.s6),
              child: Text(
                '${l10n.commonRetry}: $e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (AnalyticsSummary s) => _AnalyticsBody(
            summary: s,
            period: period,
            categoriesById: categoriesById,
          ),
        ),
      ),
    );
  }
}

class _AnalyticsBody extends ConsumerWidget {
  const _AnalyticsBody({
    required this.summary,
    required this.period,
    required this.categoriesById,
  });

  final AnalyticsSummary summary;
  final AnalyticsPeriod period;
  final Map<Ulid, Category> categoriesById;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final double gap = context.fnxSpacing.s5;

    return ListView(
      padding: EdgeInsets.all(gap),
      children: <Widget>[
        _PeriodSelector(period: period),
        SizedBox(height: gap),
        _TotalsCard(summary: summary),
        SizedBox(height: gap),
        if (summary.isEmpty)
          PfEmptyState(
            icon: Icons.insights_outlined,
            title: l10n.anEmpty,
            body: l10n.onbP2Body,
            ctaLabel: l10n.dashEmptyCta,
            onCta: () {
              // Push the user toward Quick Add via the dashboard.
              context.go('/');
            },
          )
        else if (summary.hasSparseData)
          _SparseDataHint(summary: summary)
        else ...<Widget>[
          _CategoryDonutSection(
            summary: summary,
            categoriesById: categoriesById,
          ),
          SizedBox(height: gap),
          _ByWeekdaySection(summary: summary),
          SizedBox(height: gap),
          _CashflowSection(summary: summary),
        ],
      ],
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.period});

  final AnalyticsPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    return PfSegmentedControl<AnalyticsPeriodKind>(
      segments: <AnalyticsPeriodKind, String>{
        AnalyticsPeriodKind.day: l10n.anPeriodDay,
        AnalyticsPeriodKind.week: l10n.anPeriodWeek,
        AnalyticsPeriodKind.month: l10n.anPeriodMonth,
        AnalyticsPeriodKind.year: l10n.anPeriodYear,
        AnalyticsPeriodKind.custom: l10n.anPeriodCustom,
      },
      value: period.kind,
      onChanged: (AnalyticsPeriodKind k) {
        ref.read(analyticsPeriodProvider.notifier).state =
            AnalyticsPeriod.of(k);
      },
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final typo = context.fnxTypography;
    final colors = context.fnxColors;
    final NumberFormat fmt = _amountFormat(context, summary.currency);

    return PfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_periodLabel(context, summary.period), style: typo.bodySm),
          SizedBox(height: context.fnxSpacing.s3),
          Row(
            children: <Widget>[
              Expanded(
                child: _TotalCell(
                  label: l10n.anSumIncome,
                  value: fmt.format(summary.totalIncome.major.toDouble()),
                  color: colors.income,
                ),
              ),
              Expanded(
                child: _TotalCell(
                  label: l10n.anSumExpense,
                  value: fmt.format(summary.totalExpense.major.toDouble()),
                  color: colors.error,
                ),
              ),
              Expanded(
                child: _TotalCell(
                  label: l10n.anSumBalance,
                  value: fmt.format(summary.netFlow.major.toDouble()),
                  color: summary.netFlow.isNegative
                      ? colors.error
                      : colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  const _TotalCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final typo = context.fnxTypography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: typo.bodySm),
        SizedBox(height: context.fnxSpacing.s2),
        Text(
          value,
          style: typo.amountMd.copyWith(color: color),
        ),
      ],
    );
  }
}

class _CategoryDonutSection extends ConsumerWidget {
  const _CategoryDonutSection({
    required this.summary,
    required this.categoriesById,
  });

  final AnalyticsSummary summary;
  final Map<Ulid, Category> categoriesById;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final typo = context.fnxTypography;
    final NumberFormat fmt = _amountFormat(context, summary.currency);

    final List<AnalyticsCategoryBucket> buckets = summary.byCategory;
    final List<PfDonutSlice> slices = <PfDonutSlice>[
      for (int i = 0; i < buckets.length; i++)
        PfDonutSlice(
          label: _categoryLabel(buckets[i].categoryId, l10n),
          value: buckets[i].amount.major.toDouble(),
          color: PfChartPalette.at(i),
        ),
    ];
    final List<PfLegendEntry> legend = <PfLegendEntry>[
      for (int i = 0; i < buckets.length; i++)
        PfLegendEntry(
          label: _categoryLabel(buckets[i].categoryId, l10n),
          color: PfChartPalette.at(i),
          value: fmt.format(buckets[i].amount.major.toDouble()),
        ),
    ];

    return PfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.anByCategory, style: typo.heading3),
          SizedBox(height: context.fnxSpacing.s4),
          Center(
            child: PfDonutChart(
              data: slices,
              centerLabel: l10n.anSumExpense,
              numberFormat: fmt,
              onSliceTap: (int? idx) {
                if (idx == null || idx < 0 || idx >= buckets.length) return;
                final Ulid? cat = buckets[idx].categoryId;
                if (cat == null) return;
                context.goNamed(
                  AnalyticsRouteNames.analyticsCategory,
                  pathParameters: <String, String>{'id': cat.value},
                );
              },
            ),
          ),
          SizedBox(height: context.fnxSpacing.s5),
          PfChartLegend(
            entries: legend,
            onTap: (PfLegendEntry e) {
              final int idx = legend.indexOf(e);
              if (idx < 0 || idx >= buckets.length) return;
              final Ulid? cat = buckets[idx].categoryId;
              if (cat == null) return;
              context.goNamed(
                AnalyticsRouteNames.analyticsCategory,
                pathParameters: <String, String>{'id': cat.value},
              );
            },
          ),
        ],
      ),
    );
  }

  String _categoryLabel(Ulid? id, AppL10n l10n) {
    if (id == null) return l10n.commonNone;
    final Category? c = categoriesById[id];
    return c?.name ?? l10n.commonNone;
  }
}

class _ByWeekdaySection extends StatelessWidget {
  const _ByWeekdaySection({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final typo = context.fnxTypography;
    final String locale =
        Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'en';
    final DateFormat weekdayFmt = DateFormat.E(locale);
    final List<PfBarPoint> points = <PfBarPoint>[
      for (final AnalyticsTimeBucket b in summary.byWeekday)
        PfBarPoint(
          label: weekdayFmt.format(b.bucketStart),
          income: b.income.major.toDouble(),
          expense: b.expense.major.toDouble(),
        ),
    ];
    return PfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.anByWeek, style: typo.heading3),
          SizedBox(height: context.fnxSpacing.s4),
          PfBarChart(data: points),
        ],
      ),
    );
  }
}

class _CashflowSection extends StatelessWidget {
  const _CashflowSection({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final typo = context.fnxTypography;
    final colors = context.fnxColors;
    final String locale =
        Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'en';
    final DateFormat fmt = DateFormat.MMMd(locale);

    final List<AnalyticsTimeBucket> buckets = summary.cashflow;
    final List<PfLinePoint> income = <PfLinePoint>[
      for (int i = 0; i < buckets.length; i++)
        PfLinePoint(
          x: i.toDouble(),
          y: buckets[i].income.major.toDouble(),
          label: fmt.format(buckets[i].bucketStart),
        ),
    ];
    final List<PfLinePoint> expense = <PfLinePoint>[
      for (int i = 0; i < buckets.length; i++)
        PfLinePoint(
          x: i.toDouble(),
          y: buckets[i].expense.major.toDouble(),
          label: fmt.format(buckets[i].bucketStart),
        ),
    ];

    return PfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.anCashFlow, style: typo.heading3),
          SizedBox(height: context.fnxSpacing.s4),
          PfLineChart(
            series: <PfLineSeries>[
              PfLineSeries(
                name: l10n.anSumIncome,
                points: income,
                color: colors.income,
              ),
              PfLineSeries(
                name: l10n.anSumExpense,
                points: expense,
                color: colors.error,
                dashed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparseDataHint extends StatelessWidget {
  const _SparseDataHint({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final typo = context.fnxTypography;
    return PfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.anEmpty, style: typo.heading3),
          SizedBox(height: context.fnxSpacing.s3),
          Text(
            l10n.onbP2Body,
            style: typo.bodyMd
                .copyWith(color: context.fnxColors.textSecondary),
          ),
          SizedBox(height: context.fnxSpacing.s4),
          Text(
            '${l10n.anSumIncome}: ${summary.totalIncome.major}',
            style: typo.bodyMd,
          ),
          Text(
            '${l10n.anSumExpense}: ${summary.totalExpense.major}',
            style: typo.bodyMd,
          ),
        ],
      ),
    );
  }
}

String _periodLabel(BuildContext context, AnalyticsPeriod period) {
  final String locale =
      Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'en';
  final DateFormat df = DateFormat.yMMMd(locale);
  final DateTime endInclusive =
      period.to.subtract(const Duration(milliseconds: 1));
  return '${df.format(period.from)} – ${df.format(endInclusive)}';
}

NumberFormat _amountFormat(BuildContext context, Currency currency) {
  final String locale =
      Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'en';
  return NumberFormat.currency(
    locale: locale,
    symbol: currency.code,
    decimalDigits: 0,
  );
}
