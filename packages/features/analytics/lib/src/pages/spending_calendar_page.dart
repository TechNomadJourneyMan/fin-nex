import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';

import '../providers.dart';

/// Number of months a user can page in either direction from "today". A wide
/// fixed window keeps the [PageView] simple while still covering ~8 years.
const int _kMonthRadius = 48;

/// Full-screen month-grid spending heatmap.
///
/// Each day cell is tinted by total expense that day (0 spend → surface,
/// max-spend day → brand). Header shows the month name with ← / → arrows that
/// page between months via a [PageView] (reduced-motion aware). Tapping a
/// populated day opens a bottom sheet listing that day's transactions with the
/// day total. A legend (low → high) sits at the bottom with an a11y label.
class SpendingCalendarPage extends ConsumerStatefulWidget {
  /// Default constructor.
  const SpendingCalendarPage({super.key});

  @override
  ConsumerState<SpendingCalendarPage> createState() =>
      _SpendingCalendarPageState();
}

class _SpendingCalendarPageState extends ConsumerState<SpendingCalendarPage> {
  late final DateTime _baseMonth;
  late final PageController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    final DateTime anchor = ref.read(calendarMonthProvider);
    _baseMonth = DateTime(anchor.year, anchor.month, 1);
    _page = _kMonthRadius;
    _controller = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) =>
      DateTime(_baseMonth.year, _baseMonth.month + (page - _kMonthRadius), 1);

  void _goToPage(int target) {
    if (target < 0 || target > _kMonthRadius * 2) return;
    final Duration d = PfMotion.effective(context, PfMotion.base);
    if (d == Duration.zero) {
      _controller.jumpToPage(target);
    } else {
      // ignore: discarded_futures
      _controller.animateToPage(
        target,
        duration: d,
        curve: PfEasing.standard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final DateTime visibleMonth = _monthForPage(_page);
    // Keep the shared anchor in sync so deep-links / the analytics shortcut
    // resume on the last-viewed month.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final DateTime current = ref.read(calendarMonthProvider);
      if (current != visibleMonth) {
        ref.read(calendarMonthProvider.notifier).state = visibleMonth;
      }
    });

    final DateFormat monthFmt = DateFormat.yMMMM(l10n.localeName);

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
        child: Column(
          children: <Widget>[
            _MonthHeader(
              label: monthFmt.format(visibleMonth),
              onPrev: _page > 0 ? () => _goToPage(_page - 1) : null,
              onNext:
                  _page < _kMonthRadius * 2 ? () => _goToPage(_page + 1) : null,
            ),
            const _WeekdayHeader(),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _kMonthRadius * 2 + 1,
                onPageChanged: (int p) => setState(() => _page = p),
                physics:
                    PfMotion.effective(context, PfMotion.base) == Duration.zero
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                itemBuilder: (BuildContext ctx, int p) =>
                    _MonthGrid(month: _monthForPage(p)),
              ),
            ),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.fnxSpacing.s4,
        vertical: context.fnxSpacing.s3,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: l10n.calPrevMonth,
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: context.fnxTypography.heading3,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.calNextMonth,
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final DateFormat fmt = DateFormat.E(l10n.localeName);
    // Monday-first column order (matches PfHeatmapCalendar / ISO weeks).
    final DateTime monday = DateTime(2024, 1, 1); // a Monday.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.fnxSpacing.s3),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    fmt.format(monday.add(Duration(days: i))),
                    style: context.fnxTypography.caption.copyWith(
                      color: context.fnxColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final Currency currency = ref.watch(analyticsDisplayCurrencyProvider);
    final Map<DateTime, int> totals = ref.watch(dailyTotalsProvider(month));

    final NumberFormat fmt = NumberFormat.currency(
      locale: l10n.localeName,
      symbol: currency.symbol,
      decimalDigits: 0,
    );

    final DateTime monthStart = DateTime(month.year, month.month, 1);
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    int maxV = 0;
    int totalSpend = 0;
    for (final int v in totals.values) {
      if (v > maxV) maxV = v;
      totalSpend += v;
    }

    final DateFormat monthFmt = DateFormat.yMMMM(l10n.localeName);
    final String semantic = l10n.calHeatmapSemantic(
      monthFmt.format(month),
      fmt.format(Money(BigInt.from(totalSpend), currency).major.toDouble()),
    );

    // Build leading blanks so the 1st lands under its Monday-first weekday.
    final int leadingBlanks = (monthStart.weekday - DateTime.monday) % 7;
    final int cellCount = leadingBlanks + daysInMonth;
    final int rows = (cellCount / 7).ceil();

    return Semantics(
      label: l10n.calTitle,
      value: semantic,
      child: Padding(
        padding: EdgeInsets.all(context.fnxSpacing.s3),
        child: LayoutBuilder(
          builder: (BuildContext ctx, BoxConstraints c) {
            const double gap = 6;
            final double cellW = (c.maxWidth - gap * 6) / 7;
            final double cellH =
                ((c.maxHeight - gap * (rows - 1)) / rows).clamp(28.0, cellW);
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                childAspectRatio: cellW / cellH,
              ),
              itemCount: rows * 7,
              itemBuilder: (BuildContext ctx, int index) {
                final int dayNum = index - leadingBlanks + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const SizedBox.shrink();
                }
                final DateTime day = DateTime(month.year, month.month, dayNum);
                final int spend = totals[day] ?? 0;
                return _DayCell(
                  day: day,
                  dayNum: dayNum,
                  spend: spend,
                  maxSpend: maxV,
                  currency: currency,
                  fmt: fmt,
                  onTap: spend > 0
                      ? () => _openDaySheet(context, ref, day, currency)
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Tint helper — blends from surface (0 spend) toward brand (max spend),
/// switching to [error] tones for the heaviest-spend days.
Color _intensityColor(BuildContext context, int spend, int maxSpend) {
  final PfSemanticColors colors = context.fnxColors;
  if (spend <= 0 || maxSpend <= 0) {
    return colors.surfaceSunken;
  }
  final double ratio = (spend / maxSpend).clamp(0.0, 1.0);
  // Five buckets: subtle brand → brand → error for the top bucket.
  if (ratio >= 0.85) {
    return Color.alphaBlend(colors.error.withValues(alpha: 0.85), colors.brand);
  }
  final Color base = colors.brand;
  // Map ratio into [0.22, 0.95] alpha over the sunken surface.
  final double alpha = 0.22 + ratio * 0.73;
  return Color.alphaBlend(base.withValues(alpha: alpha), colors.surfaceSunken);
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.dayNum,
    required this.spend,
    required this.maxSpend,
    required this.currency,
    required this.fmt,
    required this.onTap,
  });

  final DateTime day;
  final int dayNum;
  final int spend;
  final int maxSpend;
  final Currency currency;
  final NumberFormat fmt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final Color bg = _intensityColor(context, spend, maxSpend);
    final bool filled = spend > 0;
    final Color fg =
        filled ? context.fnxColors.onBrand : context.fnxColors.textSecondary;

    final String semantic = filled
        ? '$dayNum, '
            '${fmt.format(Money(BigInt.from(spend), currency).major.toDouble())}'
        : '$dayNum, ${l10n.calDayEmpty}';

    final Widget cell = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PfTokens.radiusSm),
      ),
      child: Center(
        child: Text(
          '$dayNum',
          style: context.fnxTypography.bodySm.copyWith(
            color: fg,
            fontWeight: filled ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      label: semantic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(PfTokens.radiusSm),
          child: cell,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final PfSemanticColors colors = context.fnxColors;
    final List<Color> swatches = <Color>[
      colors.surfaceSunken,
      Color.alphaBlend(
          colors.brand.withValues(alpha: 0.35), colors.surfaceSunken),
      Color.alphaBlend(
          colors.brand.withValues(alpha: 0.6), colors.surfaceSunken),
      Color.alphaBlend(
          colors.brand.withValues(alpha: 0.9), colors.surfaceSunken),
      Color.alphaBlend(colors.error.withValues(alpha: 0.85), colors.brand),
    ];
    return Semantics(
      label: l10n.calLegendSemantic,
      container: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.fnxSpacing.s4,
          vertical: context.fnxSpacing.s3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ExcludeSemantics(
              child: Text(
                l10n.calLegendLow,
                style: context.fnxTypography.caption
                    .copyWith(color: colors.textMuted),
              ),
            ),
            SizedBox(width: context.fnxSpacing.s2),
            for (final Color c in swatches)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(PfTokens.radiusSm / 2),
                  ),
                ),
              ),
            SizedBox(width: context.fnxSpacing.s2),
            ExcludeSemantics(
              child: Text(
                l10n.calLegendHigh,
                style: context.fnxTypography.caption
                    .copyWith(color: colors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens a bottom sheet listing the transactions for [day] with the day total.
Future<void> _openDaySheet(
  BuildContext context,
  WidgetRef ref,
  DateTime day,
  Currency currency,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext ctx) =>
        _DayDetailSheet(day: day, currency: currency),
  );
}

class _DayDetailSheet extends ConsumerWidget {
  const _DayDetailSheet({required this.day, required this.currency});

  final DateTime day;
  final Currency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final AsyncValue<List<Transaction>> txsAsync =
        ref.watch(analyticsTransactionsStreamProvider);
    final List<Transaction> all = txsAsync.valueOrNull ?? const <Transaction>[];

    final DateTime dayStart = DateTime(day.year, day.month, day.day);
    final DateTime dayEnd = dayStart.add(const Duration(days: 1));
    final List<Transaction> rows = <Transaction>[
      for (final Transaction t in all)
        if (t.deletedAt == null &&
            t.type == TransactionType.expense &&
            t.amount.currency == currency &&
            !t.occurredAt.toLocal().isBefore(dayStart) &&
            t.occurredAt.toLocal().isBefore(dayEnd))
          t,
    ]..sort(
        (Transaction a, Transaction b) => b.occurredAt.compareTo(a.occurredAt),
      );

    final int totalMinor = rows.fold<int>(
      0,
      (int acc, Transaction t) => acc + t.amount.minor.toInt(),
    );
    final NumberFormat fmt = NumberFormat.currency(
      locale: l10n.localeName,
      symbol: currency.symbol,
      decimalDigits: 0,
    );
    final DateFormat dayFmt = DateFormat.yMMMMEEEEd(l10n.localeName);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.fnxSpacing.s5,
                context.fnxSpacing.s2,
                context.fnxSpacing.s5,
                context.fnxSpacing.s3,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      dayFmt.format(day),
                      style: context.fnxTypography.heading3,
                    ),
                  ),
                  Text(
                    fmt.format(
                      Money(BigInt.from(totalMinor), currency).major.toDouble(),
                    ),
                    style: context.fnxTypography.amountMd.copyWith(
                      color: context.fnxColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (rows.isEmpty)
              Padding(
                padding: EdgeInsets.all(context.fnxSpacing.s6),
                child: Center(child: Text(l10n.calDayEmpty)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  itemBuilder: (BuildContext ctx, int i) {
                    final Transaction t = rows[i];
                    return PfTransactionItem(
                      category: t.categoryId?.value ?? '—',
                      amountMinor: -t.amount.minor.toInt(),
                      date: t.occurredAt.toLocal(),
                      description: t.description,
                      currencySymbol: t.amount.currency.symbol,
                      locale: l10n.localeName,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
