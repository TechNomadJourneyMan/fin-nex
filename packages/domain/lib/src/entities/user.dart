import 'package:equatable/equatable.dart';

import '../values/currency.dart';
import '../values/ulid.dart';

/// PocketFlow application user.
final class User extends Equatable {
  /// Default constructor.
  const User({
    required this.id,
    required this.locale,
    required this.timezone,
    required this.primaryCurrency,
    required this.countryCode,
    required this.createdAt,
    this.email,
    this.phoneE164,
    this.displayName,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.lastSeenAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Verified or pending email address.
  final String? email;

  /// E.164 phone (`+77011234567`).
  final String? phoneE164;

  /// Display name shown in UI; may be `null` until set.
  final String? displayName;

  /// BCP-47 locale (`ru-KZ`, `kk-KZ`, `en-US`, `ru-RU`).
  final String locale;

  /// IANA timezone (`Asia/Almaty`).
  final String timezone;

  /// Default currency for the dashboard and budgets.
  final Currency primaryCurrency;

  /// ISO-3166 alpha-2 country code.
  final String countryCode;

  /// Account creation timestamp (UTC).
  final DateTime createdAt;

  /// Email verification moment.
  final DateTime? emailVerifiedAt;

  /// Phone verification moment.
  final DateTime? phoneVerifiedAt;

  /// Most-recent session activity.
  final DateTime? lastSeenAt;

  /// Returns a copy with the given fields replaced.
  User copyWith({
    Ulid? id,
    String? email,
    String? phoneE164,
    String? displayName,
    String? locale,
    String? timezone,
    Currency? primaryCurrency,
    String? countryCode,
    DateTime? createdAt,
    DateTime? emailVerifiedAt,
    DateTime? phoneVerifiedAt,
    DateTime? lastSeenAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        phoneE164: phoneE164 ?? this.phoneE164,
        displayName: displayName ?? this.displayName,
        locale: locale ?? this.locale,
        timezone: timezone ?? this.timezone,
        primaryCurrency: primaryCurrency ?? this.primaryCurrency,
        countryCode: countryCode ?? this.countryCode,
        createdAt: createdAt ?? this.createdAt,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'email': email,
        'phone_e164': phoneE164,
        'display_name': displayName,
        'locale': locale,
        'timezone': timezone,
        'primary_currency': primaryCurrency.code,
        'country_code': countryCode,
        'created_at': createdAt.toUtc().toIso8601String(),
        'email_verified_at': emailVerifiedAt?.toUtc().toIso8601String(),
        'phone_verified_at': phoneVerifiedAt?.toUtc().toIso8601String(),
        'last_seen_at': lastSeenAt?.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON map.
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: Ulid(json['id'] as String),
        email: json['email'] as String?,
        phoneE164: json['phone_e164'] as String?,
        displayName: json['display_name'] as String?,
        locale: json['locale'] as String,
        timezone: json['timezone'] as String,
        primaryCurrency: Currency.parse(json['primary_currency'] as String),
        countryCode: json['country_code'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        emailVerifiedAt: json['email_verified_at'] == null
            ? null
            : DateTime.parse(json['email_verified_at'] as String),
        phoneVerifiedAt: json['phone_verified_at'] == null
            ? null
            : DateTime.parse(json['phone_verified_at'] as String),
        lastSeenAt: json['last_seen_at'] == null
            ? null
            : DateTime.parse(json['last_seen_at'] as String),
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        email,
        phoneE164,
        displayName,
        locale,
        timezone,
        primaryCurrency,
        countryCode,
        createdAt,
        emailVerifiedAt,
        phoneVerifiedAt,
        lastSeenAt,
      ];
}
