/// REST representation of a notification.
class NotificationDto {
  /// Default constructor.
  const NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data = const <String, dynamic>{},
    required this.createdAt,
    this.readAt,
  });

  /// ULID.
  final String id;

  /// Notification type code.
  final String type;

  /// Title.
  final String title;

  /// Body text.
  final String body;

  /// Free-form payload (deep-link, ids, ...).
  final Map<String, dynamic> data;

  /// Creation timestamp (UTC).
  final DateTime createdAt;

  /// When the user read this notification, if at all.
  final DateTime? readAt;

  /// Parse from JSON.
  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      NotificationDto(
        id: json['id'] as String,
        type: json['type'] as String,
        title: (json['title'] ?? '') as String,
        body: (json['body'] ?? '') as String,
        data: (json['data'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
        createdAt: DateTime.parse(json['created_at'] as String),
        readAt: json['read_at'] is String
            ? DateTime.parse(json['read_at'] as String)
            : null,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'data': data,
        'created_at': createdAt.toUtc().toIso8601String(),
        if (readAt != null) 'read_at': readAt!.toUtc().toIso8601String(),
      };
}

/// User notification preferences.
class NotificationPreferencesDto {
  /// Default constructor.
  const NotificationPreferencesDto({
    this.channels = const <String, bool>{},
    this.categories = const <String, Map<String, bool>>{},
    this.quietHours,
  });

  /// Channel toggles (`push`, `email`, `in_app`).
  final Map<String, bool> channels;

  /// Per-category channel toggles.
  final Map<String, Map<String, bool>> categories;

  /// Quiet-hours configuration.
  final Map<String, dynamic>? quietHours;

  /// Parse from JSON.
  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) {
    final channels = <String, bool>{};
    final rawChannels = json['channels'];
    if (rawChannels is Map<String, dynamic>) {
      rawChannels.forEach((String k, dynamic v) {
        if (v is bool) channels[k] = v;
      });
    }
    final categories = <String, Map<String, bool>>{};
    final rawCategories = json['categories'];
    if (rawCategories is Map<String, dynamic>) {
      rawCategories.forEach((String k, dynamic v) {
        if (v is Map<String, dynamic>) {
          final inner = <String, bool>{};
          v.forEach((String ck, dynamic cv) {
            if (cv is bool) inner[ck] = cv;
          });
          categories[k] = inner;
        }
      });
    }
    return NotificationPreferencesDto(
      channels: channels,
      categories: categories,
      quietHours: json['quiet_hours'] is Map<String, dynamic>
          ? json['quiet_hours'] as Map<String, dynamic>
          : null,
    );
  }

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'channels': channels,
        'categories': categories,
        if (quietHours != null) 'quiet_hours': quietHours,
      };
}
