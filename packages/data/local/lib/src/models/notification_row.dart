import 'package:meta/meta.dart';

import '_helpers.dart';

/// Persisted shape of a local/remote notification surfaced to the user.
@immutable
class NotificationRow {
  /// Creates an immutable notification row.
  const NotificationRow({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.payload,
    this.priority = 5,
    this.scheduledAt,
    this.sentAt,
    this.readAt,
    this.dismissedAt,
    this.channel = 'push',
  });

  /// Builds a [NotificationRow] from a sqflite result map.
  factory NotificationRow.fromMap(Map<String, Object?> m) => NotificationRow(
        id: m['id']! as String,
        userId: m['user_id']! as String,
        kind: m['kind']! as String,
        title: m['title']! as String,
        body: m['body']! as String,
        payload: m['payload'] as String?,
        priority: m['priority']! as int,
        scheduledAt: parseDate(m['scheduled_at']),
        sentAt: parseDate(m['sent_at']),
        readAt: parseDate(m['read_at']),
        dismissedAt: parseDate(m['dismissed_at']),
        channel: m['channel'] as String? ?? 'push',
        createdAt: parseDate(m['created_at'])!,
      );

  /// ULID primary key.
  final String id;

  /// Owner user ULID.
  final String userId;

  /// Notification kind (`limit_warning`, `recurring_due`, ...).
  final String kind;

  /// Short headline displayed in the notification tray.
  final String title;

  /// Body copy.
  final String body;

  /// JSON-encoded deep-link payload.
  final String? payload;

  /// Priority in `[1,10]`; higher = more prominent.
  final int priority;

  /// When the notification should be delivered (UTC); `null` for immediate.
  final DateTime? scheduledAt;

  /// When the notification was actually delivered (UTC).
  final DateTime? sentAt;

  /// When the user opened it (UTC).
  final DateTime? readAt;

  /// When the user dismissed it without acting (UTC).
  final DateTime? dismissedAt;

  /// Delivery channel: `push` | `in_app` | `email` | `sms`.
  final String channel;

  /// Row creation timestamp (UTC).
  final DateTime createdAt;

  /// Serialises to a sqflite-friendly map.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'kind': kind,
        'title': title,
        'body': body,
        'payload': payload,
        'priority': priority,
        'scheduled_at': formatDateOrNull(scheduledAt),
        'sent_at': formatDateOrNull(sentAt),
        'read_at': formatDateOrNull(readAt),
        'dismissed_at': formatDateOrNull(dismissedAt),
        'channel': channel,
        'created_at': formatDate(createdAt),
      };
}
