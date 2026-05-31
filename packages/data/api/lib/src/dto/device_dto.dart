/// REST representation of a registered device.
class DeviceDto {
  /// Default constructor.
  const DeviceDto({
    required this.id,
    required this.platform,
    this.pushProvider,
    this.pushToken,
    this.appVersion,
    this.osVersion,
    this.model,
    this.locale,
    this.timezone,
    this.lastSeenAt,
    this.createdAt,
  });

  /// ULID.
  final String id;

  /// `ios | android | web`.
  final String platform;

  /// `apns | fcm | webpush`.
  final String? pushProvider;

  /// Push token blob.
  final String? pushToken;

  /// App version.
  final String? appVersion;

  /// OS version.
  final String? osVersion;

  /// Device model.
  final String? model;

  /// BCP-47 locale.
  final String? locale;

  /// IANA timezone.
  final String? timezone;

  /// Last activity timestamp.
  final DateTime? lastSeenAt;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Parse from JSON.
  factory DeviceDto.fromJson(Map<String, dynamic> json) => DeviceDto(
        id: (json['id'] ?? json['device_id']) as String,
        platform: json['platform'] as String,
        pushProvider: json['push_provider'] as String?,
        pushToken: json['push_token'] as String?,
        appVersion: json['app_version'] as String?,
        osVersion: json['os_version'] as String?,
        model: json['model'] as String?,
        locale: json['locale'] as String?,
        timezone: json['timezone'] as String?,
        lastSeenAt: json['last_seen_at'] is String
            ? DateTime.parse(json['last_seen_at'] as String)
            : null,
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'device_id': id,
        'platform': platform,
        if (pushProvider != null) 'push_provider': pushProvider,
        if (pushToken != null) 'push_token': pushToken,
        if (appVersion != null) 'app_version': appVersion,
        if (osVersion != null) 'os_version': osVersion,
        if (model != null) 'model': model,
        if (locale != null) 'locale': locale,
        if (timezone != null) 'timezone': timezone,
        if (lastSeenAt != null)
          'last_seen_at': lastSeenAt!.toUtc().toIso8601String(),
        if (createdAt != null)
          'created_at': createdAt!.toUtc().toIso8601String(),
      };
}

/// `POST /devices` request body.
class RegisterDeviceRequest {
  /// Default constructor.
  const RegisterDeviceRequest({
    required this.deviceId,
    required this.platform,
    this.pushProvider,
    this.pushToken,
    this.appVersion,
    this.osVersion,
    this.model,
    this.locale,
    this.timezone,
  });

  /// Client-generated device id.
  final String deviceId;

  /// Platform.
  final String platform;

  /// Push provider.
  final String? pushProvider;

  /// Push token.
  final String? pushToken;

  /// App version.
  final String? appVersion;

  /// OS version.
  final String? osVersion;

  /// Model.
  final String? model;

  /// Locale.
  final String? locale;

  /// Timezone.
  final String? timezone;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'device_id': deviceId,
        'platform': platform,
        if (pushProvider != null) 'push_provider': pushProvider,
        if (pushToken != null) 'push_token': pushToken,
        if (appVersion != null) 'app_version': appVersion,
        if (osVersion != null) 'os_version': osVersion,
        if (model != null) 'model': model,
        if (locale != null) 'locale': locale,
        if (timezone != null) 'timezone': timezone,
      };
}
