/// Authenticated user profile returned by `/me`.
class UserDto {
  /// Default constructor.
  const UserDto({
    required this.id,
    this.phone,
    this.email,
    this.displayName,
    this.locale,
    this.timezone,
    this.currencyPrimary,
    this.plan,
    this.createdAt,
    this.updatedAt,
    this.flags = const <String, dynamic>{},
  });

  /// ULID.
  final String id;

  /// E.164 phone.
  final String? phone;

  /// Email.
  final String? email;

  /// Display name.
  final String? displayName;

  /// BCP-47 locale.
  final String? locale;

  /// IANA timezone.
  final String? timezone;

  /// Primary currency (ISO 4217).
  final String? currencyPrimary;

  /// Plan code (`free|pro|family`).
  final String? plan;

  /// Server creation timestamp.
  final DateTime? createdAt;

  /// Server last-update timestamp.
  final DateTime? updatedAt;

  /// Free-form feature flags.
  final Map<String, dynamic> flags;

  /// Parse from JSON.
  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        displayName: json['display_name'] as String?,
        locale: json['locale'] as String?,
        timezone: json['timezone'] as String?,
        currencyPrimary: json['currency_primary'] as String?,
        plan: json['plan'] as String?,
        createdAt: _parseDate(json['created_at']),
        updatedAt: _parseDate(json['updated_at']),
        flags: (json['flags'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (displayName != null) 'display_name': displayName,
        if (locale != null) 'locale': locale,
        if (timezone != null) 'timezone': timezone,
        if (currencyPrimary != null) 'currency_primary': currencyPrimary,
        if (plan != null) 'plan': plan,
        if (createdAt != null)
          'created_at': createdAt!.toUtc().toIso8601String(),
        if (updatedAt != null)
          'updated_at': updatedAt!.toUtc().toIso8601String(),
        'flags': flags,
      };
}

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.parse(value) : null;
