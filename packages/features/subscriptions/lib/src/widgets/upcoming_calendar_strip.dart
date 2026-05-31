// Horizontal calendar strip highlighting upcoming charge days this month.
//
// Renders one cell per remaining day of the current month; days that have at
// least one upcoming charge get a brand dot indicator beneath the date.

import 'package:flutter/material.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:intl/intl.dart';

import '../domain/detected_subscription.dart';

/// A scrollable row of day cells with dot indicators on charge days.
class UpcomingCalendarStrip extends StatelessWidget {
  /// Creates the strip.
  const UpcomingCalendarStrip({
    required this.subscriptions,
    required this.locale,
    this.now,
    super.key,
  });

  /// Active subscriptions whose [DetectedSubscription.nextBillingDate] is
  /// inspected to mark charge days.
  final List<DetectedSubscription> subscriptions;

  /// BCP-47 locale string for weekday labels.
  final String locale;

  /// Injection seam for tests; defaults to wall clock.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final typography = context.fnxTypography;

    final today = (now ?? DateTime.now()).toLocal();
    final monthEnd = DateTime(today.year, today.month + 1, 0);
    final days = <DateTime>[
      for (var d = today.day; d <= monthEnd.day; d++)
        DateTime(today.year, today.month, d),
    ];

    // Set of day-of-month values that carry an upcoming charge this month.
    final chargeDays = <int>{
      for (final s in subscriptions)
        if (s.cancelledAt == null)
          if (_sameMonth(s.nextBillingDate.toLocal(), today) &&
              !s.nextBillingDate.toLocal().isBefore(_atMidnight(today)))
            s.nextBillingDate.toLocal().day,
    };

    final weekdayFmt = DateFormat.E(locale);

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: spacing.s5),
        itemCount: days.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing.s3),
        itemBuilder: (context, i) {
          final day = days[i];
          final isToday = day.day == today.day;
          final hasCharge = chargeDays.contains(day.day);
          return Container(
            width: 48,
            decoration: BoxDecoration(
              color: isToday ? colors.brandSubtle : colors.surface,
              borderRadius: BorderRadius.circular(context.fnxRadii.r3),
              border: Border.all(
                color: isToday ? colors.brand : colors.borderSubtle,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekdayFmt.format(day),
                  style: typography.caption.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                SizedBox(height: spacing.s1),
                Text(
                  '${day.day}',
                  style: typography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isToday ? colors.brand : colors.textPrimary,
                  ),
                ),
                SizedBox(height: spacing.s2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasCharge ? colors.brand : Colors.transparent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static DateTime _atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
