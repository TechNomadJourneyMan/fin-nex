import 'package:equatable/equatable.dart';

/// Selectable analytics window. `custom` lets the user pin a date range.
enum AnalyticsPeriodKind {
  /// Current calendar day.
  day,

  /// Current ISO week (Mon-Sun).
  week,

  /// Current calendar month.
  month,

  /// Current calendar year.
  year,

  /// User-defined `[from, to)` range.
  custom,
}

/// Immutable description of the period currently being analysed.
///
/// `from` is inclusive, `to` is exclusive — matching repository semantics.
class AnalyticsPeriod extends Equatable {
  /// Default constructor.
  const AnalyticsPeriod({
    required this.kind,
    required this.from,
    required this.to,
  });

  /// Builds the period for [kind] anchored on [now] (defaults to
  /// `DateTime.now()`). For [AnalyticsPeriodKind.custom] callers must use
  /// [AnalyticsPeriod.new] directly.
  factory AnalyticsPeriod.of(AnalyticsPeriodKind kind, {DateTime? now}) {
    final DateTime n = now ?? DateTime.now();
    switch (kind) {
      case AnalyticsPeriodKind.day:
        final DateTime start = DateTime(n.year, n.month, n.day);
        return AnalyticsPeriod(
          kind: kind,
          from: start,
          to: start.add(const Duration(days: 1)),
        );
      case AnalyticsPeriodKind.week:
        final DateTime today = DateTime(n.year, n.month, n.day);
        final DateTime start =
            today.subtract(Duration(days: today.weekday - 1));
        return AnalyticsPeriod(
          kind: kind,
          from: start,
          to: start.add(const Duration(days: 7)),
        );
      case AnalyticsPeriodKind.month:
        final DateTime start = DateTime(n.year, n.month, 1);
        final DateTime end = DateTime(n.year, n.month + 1, 1);
        return AnalyticsPeriod(kind: kind, from: start, to: end);
      case AnalyticsPeriodKind.year:
        final DateTime start = DateTime(n.year, 1, 1);
        final DateTime end = DateTime(n.year + 1, 1, 1);
        return AnalyticsPeriod(kind: kind, from: start, to: end);
      case AnalyticsPeriodKind.custom:
        final DateTime start = DateTime(n.year, n.month, 1);
        final DateTime end = DateTime(n.year, n.month + 1, 1);
        return AnalyticsPeriod(kind: kind, from: start, to: end);
    }
  }

  /// Kind of period.
  final AnalyticsPeriodKind kind;

  /// Inclusive start (local midnight).
  final DateTime from;

  /// Exclusive end (local midnight).
  final DateTime to;

  /// Length in whole days (≥ 1).
  int get spanDays {
    final int ms = to.difference(from).inMilliseconds;
    final int days = (ms / Duration.millisecondsPerDay).ceil();
    return days < 1 ? 1 : days;
  }

  /// Bucket width recommended for cashflow time series.
  ///
  /// Day/Week → 1d, Month → 1d, Year → 30d, Custom → adaptive.
  int get bucketDays {
    switch (kind) {
      case AnalyticsPeriodKind.day:
      case AnalyticsPeriodKind.week:
      case AnalyticsPeriodKind.month:
        return 1;
      case AnalyticsPeriodKind.year:
        return 30;
      case AnalyticsPeriodKind.custom:
        if (spanDays <= 31) return 1;
        if (spanDays <= 180) return 7;
        return 30;
    }
  }

  @override
  List<Object?> get props => <Object?>[kind, from, to];
}
