import 'package:equatable/equatable.dart';

import '../values/ulid.dart';
import 'enums.dart';

/// A push or in-app notification record.
final class AppNotification extends Equatable {
  /// Default constructor.
  const AppNotification({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    required this.priority,
    required this.createdAt,
    this.payload = const <String, dynamic>{},
    this.scheduledAt,
    this.sentAt,
    this.readAt,
    this.dismissedAt,
    this.channel = 'push',
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// Kind / category.
  final NotificationKind kind;

  /// Visible title.
  final String title;

  /// Visible body.
  final String body;

  /// Free-form payload (deep-link target, ids).
  final Map<String, dynamic> payload;

  /// 1 (lowest) – 10 (highest).
  final int priority;

  /// Optional future scheduling moment.
  final DateTime? scheduledAt;

  /// When delivered.
  final DateTime? sentAt;

  /// When the user opened/read.
  final DateTime? readAt;

  /// When dismissed without read.
  final DateTime? dismissedAt;

  /// Channel: `push` | `in_app` | `email` | `sms`.
  final String channel;

  /// Creation timestamp.
  final DateTime createdAt;

  /// True until [readAt] or [dismissedAt] is set.
  bool get isUnread => readAt == null && dismissedAt == null;

  /// Returns a copy with the given fields replaced.
  AppNotification copyWith({
    Ulid? id,
    Ulid? userId,
    NotificationKind? kind,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    int? priority,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? readAt,
    DateTime? dismissedAt,
    String? channel,
    DateTime? createdAt,
  }) =>
      AppNotification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        body: body ?? this.body,
        payload: payload ?? this.payload,
        priority: priority ?? this.priority,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        sentAt: sentAt ?? this.sentAt,
        readAt: readAt ?? this.readAt,
        dismissedAt: dismissedAt ?? this.dismissedAt,
        channel: channel ?? this.channel,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'kind': kind.code,
        'title': title,
        'body': body,
        'payload': payload,
        'priority': priority,
        'scheduled_at': scheduledAt?.toUtc().toIso8601String(),
        'sent_at': sentAt?.toUtc().toIso8601String(),
        'read_at': readAt?.toUtc().toIso8601String(),
        'dismissed_at': dismissedAt?.toUtc().toIso8601String(),
        'channel': channel,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        kind: NotificationKind.parse(json['kind'] as String),
        title: json['title'] as String,
        body: json['body'] as String,
        payload: (json['payload'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
        priority: (json['priority'] as num).toInt(),
        scheduledAt: json['scheduled_at'] == null
            ? null
            : DateTime.parse(json['scheduled_at'] as String),
        sentAt: json['sent_at'] == null
            ? null
            : DateTime.parse(json['sent_at'] as String),
        readAt: json['read_at'] == null
            ? null
            : DateTime.parse(json['read_at'] as String),
        dismissedAt: json['dismissed_at'] == null
            ? null
            : DateTime.parse(json['dismissed_at'] as String),
        channel: (json['channel'] as String?) ?? 'push',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        kind,
        title,
        body,
        payload,
        priority,
        scheduledAt,
        sentAt,
        readAt,
        dismissedAt,
        channel,
        createdAt,
      ];
}
