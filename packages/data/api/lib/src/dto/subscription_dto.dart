/// REST representation of the current user's subscription state.
class SubscriptionDto {
  /// Default constructor.
  const SubscriptionDto({
    required this.plan,
    required this.status,
    this.store,
    this.productId,
    this.startedAt,
    this.currentPeriodEnd,
    this.autoRenew = false,
    this.cancelledAt,
    this.inGracePeriod = false,
  });

  /// Plan code (`free | pro | family`).
  final String plan;

  /// `active | trialing | past_due | cancelled | expired`.
  final String status;

  /// `appstore | playstore | promo`.
  final String? store;

  /// Store product id.
  final String? productId;

  /// Subscription start timestamp.
  final DateTime? startedAt;

  /// Current period end timestamp.
  final DateTime? currentPeriodEnd;

  /// Whether auto-renew is on.
  final bool autoRenew;

  /// When the user cancelled, if at all.
  final DateTime? cancelledAt;

  /// Whether the subscription is in a billing grace period.
  final bool inGracePeriod;

  /// Parse from JSON.
  factory SubscriptionDto.fromJson(Map<String, dynamic> json) =>
      SubscriptionDto(
        plan: (json['plan'] ?? 'free') as String,
        status: (json['status'] ?? 'expired') as String,
        store: json['store'] as String?,
        productId: json['product_id'] as String?,
        startedAt: json['started_at'] is String
            ? DateTime.parse(json['started_at'] as String)
            : null,
        currentPeriodEnd: json['current_period_end'] is String
            ? DateTime.parse(json['current_period_end'] as String)
            : null,
        autoRenew: (json['auto_renew'] as bool?) ?? false,
        cancelledAt: json['cancelled_at'] is String
            ? DateTime.parse(json['cancelled_at'] as String)
            : null,
        inGracePeriod: (json['in_grace_period'] as bool?) ?? false,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'plan': plan,
        'status': status,
        if (store != null) 'store': store,
        if (productId != null) 'product_id': productId,
        if (startedAt != null)
          'started_at': startedAt!.toUtc().toIso8601String(),
        if (currentPeriodEnd != null)
          'current_period_end': currentPeriodEnd!.toUtc().toIso8601String(),
        'auto_renew': autoRenew,
        if (cancelledAt != null)
          'cancelled_at': cancelledAt!.toUtc().toIso8601String(),
        'in_grace_period': inGracePeriod,
      };
}

/// `POST /subscriptions/validate-receipt` body.
class ValidateReceiptRequest {
  /// Default constructor.
  const ValidateReceiptRequest({
    required this.store,
    required this.receipt,
    this.transactionId,
    this.productId,
  });

  /// `appstore | playstore`.
  final String store;

  /// Receipt blob (base64 or JWT depending on store).
  final String receipt;

  /// Store transaction id.
  final String? transactionId;

  /// Store product id.
  final String? productId;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'store': store,
        'receipt': receipt,
        if (transactionId != null) 'transaction_id': transactionId,
        if (productId != null) 'product_id': productId,
      };
}
