// Local contract for the Subscriptions Manager (F-04).
//
// The canonical `DetectedSubscription` entity, the `BillingPeriod` enum and
// the `DetectedSubscriptionsRepository` interface are owned by the domain
// layer and the detection-algorithm agent. To keep this UI feature package
// compilable and testable in isolation — and to encode the exact contract
// this UI is written against — we declare structurally-identical shapes here.
//
// On integration the app composition layer overrides the providers in
// `providers.dart` with the real `pf_domain` implementations. These local
// types mirror the agreed contract:
//
//   abstract interface class DetectedSubscriptionsRepository {
//     Stream<List<DetectedSubscription>> watchAll(Ulid userId);
//     Future<DetectedSubscription?> getById(Ulid id);
//     Future<void> upsert(DetectedSubscription sub);
//     Future<void> softDelete(Ulid id);
//   }

import 'package:equatable/equatable.dart';
import 'package:pf_domain/domain.dart';

/// Cadence at which a detected subscription is billed.
enum BillingPeriod {
  /// Billed every week.
  weekly,

  /// Billed every month.
  monthly,

  /// Billed every quarter (3 months).
  quarterly,

  /// Billed once a year.
  yearly;

  /// Wire code (stable across persistence + sync).
  String get code => name;

  /// Parses a persisted code, throwing [ArgumentError] when unknown.
  static BillingPeriod parse(String code) {
    for (final p in BillingPeriod.values) {
      if (p.code == code) {
        return p;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown billing period');
  }

  /// Number of whole months in one billing cycle (weekly approximated to 0,
  /// callers special-case it).
  int get monthsPerCycle => switch (this) {
        BillingPeriod.weekly => 0,
        BillingPeriod.monthly => 1,
        BillingPeriod.quarterly => 3,
        BillingPeriod.yearly => 12,
      };
}

/// A recurring charge inferred from the user's transaction history.
final class DetectedSubscription extends Equatable {
  /// Default constructor.
  const DetectedSubscription({
    required this.id,
    required this.userId,
    required this.merchantName,
    required this.amount,
    required this.period,
    required this.nextBillingDate,
    required this.createdAt,
    required this.updatedAt,
    this.brandIconKey,
    this.unsubscribeUrl,
    this.sourceTransactionIds = const <Ulid>[],
    this.cancelledAt,
    this.deletedAt,
    this.calendarEventId,
  });

  /// Stable identifier.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// Human-readable merchant / brand name (e.g. "Netflix").
  final String merchantName;

  /// Recurring charge amount, in minor units + currency.
  final Money amount;

  /// Billing cadence.
  final BillingPeriod period;

  /// Projected date of the next charge.
  final DateTime nextBillingDate;

  /// Optional icon key understood by the UI brand-icon resolver.
  final String? brandIconKey;

  /// Optional deep link to the merchant's cancellation page.
  final String? unsubscribeUrl;

  /// Ids of the transactions the detector clustered into this subscription.
  final List<Ulid> sourceTransactionIds;

  /// When the user marked the subscription as cancelled; null while active.
  final DateTime? cancelledAt;

  /// Soft-delete tombstone.
  final DateTime? deletedAt;

  /// Id of the calendar event created for this subscription's next-due date,
  /// or null when no reminder has been added. Stored so toggling reminders off
  /// or deleting the subscription can remove exactly that event.
  final String? calendarEventId;

  /// Creation timestamp (UTC).
  final DateTime createdAt;

  /// Last-update timestamp (UTC).
  final DateTime updatedAt;

  /// True while the user has not cancelled and the row is not deleted.
  bool get isActive => cancelledAt == null && deletedAt == null;

  /// Normalizes [amount] to an equivalent *monthly* spend so totals across
  /// mixed billing periods can be summed.
  Money get monthlyEquivalent {
    final minor = amount.minor;
    final monthly = switch (period) {
      BillingPeriod.weekly => (minor * BigInt.from(52)) ~/ BigInt.from(12),
      BillingPeriod.monthly => minor,
      BillingPeriod.quarterly => minor ~/ BigInt.from(3),
      BillingPeriod.yearly => minor ~/ BigInt.from(12),
    };
    return Money(monthly, amount.currency);
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// [calendarEventId] uses a sentinel so it can be *cleared*: pass
  /// `clearCalendarEventId: true` to drop the stored event id (e.g. after the
  /// reminder is removed). Passing a non-null [calendarEventId] sets it.
  DetectedSubscription copyWith({
    Ulid? id,
    Ulid? userId,
    String? merchantName,
    Money? amount,
    BillingPeriod? period,
    DateTime? nextBillingDate,
    String? brandIconKey,
    String? unsubscribeUrl,
    List<Ulid>? sourceTransactionIds,
    DateTime? cancelledAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? calendarEventId,
    bool clearCalendarEventId = false,
  }) =>
      DetectedSubscription(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        merchantName: merchantName ?? this.merchantName,
        amount: amount ?? this.amount,
        period: period ?? this.period,
        nextBillingDate: nextBillingDate ?? this.nextBillingDate,
        brandIconKey: brandIconKey ?? this.brandIconKey,
        unsubscribeUrl: unsubscribeUrl ?? this.unsubscribeUrl,
        sourceTransactionIds: sourceTransactionIds ?? this.sourceTransactionIds,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        deletedAt: deletedAt ?? this.deletedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        calendarEventId: clearCalendarEventId
            ? null
            : (calendarEventId ?? this.calendarEventId),
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        merchantName,
        amount,
        period,
        nextBillingDate,
        brandIconKey,
        unsubscribeUrl,
        sourceTransactionIds,
        cancelledAt,
        deletedAt,
        calendarEventId,
        createdAt,
        updatedAt,
      ];
}
