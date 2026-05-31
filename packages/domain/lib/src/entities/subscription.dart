import 'package:equatable/equatable.dart';

import '../values/ulid.dart';
import 'enums.dart';

/// User's current paid tier.
final class Subscription extends Equatable {
  /// Default constructor.
  const Subscription({
    required this.userId,
    required this.tier,
    required this.startedAt,
    this.expiresAt,
    this.platform,
    this.externalRef,
    this.autoRenew = false,
  });

  /// Owning user.
  final Ulid userId;

  /// Active tier.
  final SubscriptionTier tier;

  /// When the current tier became active.
  final DateTime startedAt;

  /// Expiry; null for permanent or non-expiring tiers.
  final DateTime? expiresAt;

  /// Source platform (`ios_appstore`, `android_play`, `stripe`).
  final String? platform;

  /// Store-supplied receipt / subscription id.
  final String? externalRef;

  /// Whether platform will auto-renew.
  final bool autoRenew;

  /// True when the subscription window includes "now".
  bool get isActive {
    if (tier == SubscriptionTier.free) {
      return true;
    }
    if (expiresAt == null) {
      return true;
    }
    return expiresAt!.isAfter(DateTime.now().toUtc());
  }

  /// Returns a copy with the given fields replaced.
  Subscription copyWith({
    Ulid? userId,
    SubscriptionTier? tier,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? platform,
    String? externalRef,
    bool? autoRenew,
  }) =>
      Subscription(
        userId: userId ?? this.userId,
        tier: tier ?? this.tier,
        startedAt: startedAt ?? this.startedAt,
        expiresAt: expiresAt ?? this.expiresAt,
        platform: platform ?? this.platform,
        externalRef: externalRef ?? this.externalRef,
        autoRenew: autoRenew ?? this.autoRenew,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'user_id': userId.value,
        'tier': tier.code,
        'started_at': startedAt.toUtc().toIso8601String(),
        'expires_at': expiresAt?.toUtc().toIso8601String(),
        'platform': platform,
        'external_ref': externalRef,
        'auto_renew': autoRenew,
      };

  /// Reconstructs from JSON.
  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        userId: Ulid(json['user_id'] as String),
        tier: SubscriptionTier.parse(json['tier'] as String),
        startedAt: DateTime.parse(json['started_at'] as String),
        expiresAt: json['expires_at'] == null
            ? null
            : DateTime.parse(json['expires_at'] as String),
        platform: json['platform'] as String?,
        externalRef: json['external_ref'] as String?,
        autoRenew: (json['auto_renew'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => <Object?>[
        userId,
        tier,
        startedAt,
        expiresAt,
        platform,
        externalRef,
        autoRenew,
      ];
}
