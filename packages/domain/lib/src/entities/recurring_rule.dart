import 'package:equatable/equatable.dart';

import '../values/money.dart';
import '../values/ulid.dart';
import 'enums.dart';
import 'transaction.dart';

/// A schedule that materialises [Transaction]s on a repeating cadence.
///
/// Carries the *template* fields of the transaction it produces (account,
/// type, amount, category, description, …) plus the recurrence schedule. Pure
/// Dart, no codegen — hand-rolled (de)serialisation and [copyWith], matching
/// the rest of `pf_domain`.
final class RecurringRule extends Equatable {
  /// Default constructor.
  const RecurringRule({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.cadence,
    required this.interval,
    required this.nextRunAt,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.description,
    this.source = 'recurring',
    this.endAt,
    this.paused = false,
    this.calendarEventId,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// Account each generated transaction lands in.
  final Ulid accountId;

  /// Kind of generated transaction.
  final TransactionType type;

  /// Positive money amount applied to each occurrence.
  final Money amount;

  /// Category applied to each occurrence (required for expense/income).
  final Ulid? categoryId;

  /// Optional note copied onto each occurrence.
  final String? description;

  /// `source` stamped on generated transactions (defaults to `recurring`).
  final String source;

  /// Repetition unit.
  final RecurrenceCadence cadence;

  /// Multiplier on the cadence (e.g. cadence=monthly, interval=2 → every 2
  /// months). Always >= 1.
  final int interval;

  /// When the next occurrence is due (UTC). Occurrences with
  /// `nextRunAt <= now` are materialised by the engine.
  final DateTime nextRunAt;

  /// Optional end bound (UTC). When set, no occurrence is produced on or after
  /// this instant and the rule is considered finished.
  final DateTime? endAt;

  /// Whether the rule is paused (skipped by the engine without deleting it).
  final bool paused;

  /// Calendar event id linking this rule to its next-occurrence reminder, when
  /// calendar sync is enabled. `null` when sync is off.
  final String? calendarEventId;

  /// Creation timestamp (UTC).
  final DateTime createdAt;

  /// Last edit timestamp (UTC).
  final DateTime updatedAt;

  /// Whether the rule has run past its [endAt] bound.
  bool get isFinished => endAt != null && !nextRunAt.isBefore(endAt!);

  /// Whether the engine should consider this rule for materialisation at
  /// [now]: not paused, not finished, and due.
  bool isDueAt(DateTime now) =>
      !paused && !isFinished && !nextRunAt.isAfter(now);

  /// Computes the occurrence instant that follows [from] for this rule's
  /// [cadence] and [interval]. Calendar-correct for month/year boundaries
  /// (clamps the day-of-month, e.g. Jan 31 + 1 month → Feb 28/29).
  DateTime advanceFrom(DateTime from) {
    switch (cadence) {
      case RecurrenceCadence.daily:
        return from.add(Duration(days: interval));
      case RecurrenceCadence.weekly:
        return from.add(Duration(days: 7 * interval));
      case RecurrenceCadence.biweekly:
        return from.add(Duration(days: 14 * interval));
      case RecurrenceCadence.monthly:
        return _addMonths(from, interval);
      case RecurrenceCadence.yearly:
        return _addMonths(from, 12 * interval);
    }
  }

  static DateTime _addMonths(DateTime d, int months) {
    final int total = d.month - 1 + months;
    final int year = d.year + total ~/ 12;
    final int month = total % 12 + 1;
    final int lastDay = DateTime.utc(year, month + 1, 0).day;
    final int day = d.day < lastDay ? d.day : lastDay;
    return DateTime.utc(
      year,
      month,
      day,
      d.hour,
      d.minute,
      d.second,
      d.millisecond,
      d.microsecond,
    );
  }

  /// Returns a copy with the given fields replaced. Set [clearEndAt] /
  /// [clearCalendarEventId] / [clearCategoryId] to null those fields out.
  RecurringRule copyWith({
    Ulid? id,
    Ulid? userId,
    Ulid? accountId,
    TransactionType? type,
    Money? amount,
    Ulid? categoryId,
    bool clearCategoryId = false,
    String? description,
    String? source,
    RecurrenceCadence? cadence,
    int? interval,
    DateTime? nextRunAt,
    DateTime? endAt,
    bool clearEndAt = false,
    bool? paused,
    String? calendarEventId,
    bool clearCalendarEventId = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      RecurringRule(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        accountId: accountId ?? this.accountId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
        description: description ?? this.description,
        source: source ?? this.source,
        cadence: cadence ?? this.cadence,
        interval: interval ?? this.interval,
        nextRunAt: nextRunAt ?? this.nextRunAt,
        endAt: clearEndAt ? null : (endAt ?? this.endAt),
        paused: paused ?? this.paused,
        calendarEventId: clearCalendarEventId
            ? null
            : (calendarEventId ?? this.calendarEventId),
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'account_id': accountId.value,
        'type_code': type.code,
        'amount': amount.toJson(),
        'category_id': categoryId?.value,
        'description': description,
        'source': source,
        'cadence': cadence.code,
        'interval': interval,
        'next_run_at': nextRunAt.toUtc().toIso8601String(),
        'end_at': endAt?.toUtc().toIso8601String(),
        'paused': paused,
        'calendar_event_id': calendarEventId,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory RecurringRule.fromJson(Map<String, dynamic> json) => RecurringRule(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        accountId: Ulid(json['account_id'] as String),
        type: TransactionType.parse(json['type_code'] as String),
        amount: Money.fromJson(json['amount'] as Map<String, dynamic>),
        categoryId: json['category_id'] == null
            ? null
            : Ulid(json['category_id'] as String),
        description: json['description'] as String?,
        source: (json['source'] as String?) ?? 'recurring',
        cadence: RecurrenceCadence.parse(json['cadence'] as String),
        interval: json['interval'] as int,
        nextRunAt: DateTime.parse(json['next_run_at'] as String),
        endAt: json['end_at'] == null
            ? null
            : DateTime.parse(json['end_at'] as String),
        paused: (json['paused'] as bool?) ?? false,
        calendarEventId: json['calendar_event_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        accountId,
        type,
        amount,
        categoryId,
        description,
        source,
        cadence,
        interval,
        nextRunAt,
        endAt,
        paused,
        calendarEventId,
        createdAt,
        updatedAt,
      ];
}
