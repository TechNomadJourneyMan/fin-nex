import 'package:meta/meta.dart';

import '_helpers.dart';

/// Persisted shape of a server-generated insight surfaced to the user.
@immutable
class InsightRow {
  /// Creates an immutable insight row.
  const InsightRow({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    required this.generatedAt,
    this.severity = 'info',
    this.payload,
    this.expiresAt,
    this.dismissedAt,
    this.actedAt,
    this.score,
  });

  /// Builds an [InsightRow] from a sqflite result map.
  factory InsightRow.fromMap(Map<String, Object?> m) => InsightRow(
        id: m['id']! as String,
        userId: m['user_id']! as String,
        kind: m['kind']! as String,
        title: m['title']! as String,
        body: m['body']! as String,
        severity: m['severity'] as String? ?? 'info',
        payload: m['payload'] as String?,
        generatedAt: parseDate(m['generated_at'])!,
        expiresAt: parseDate(m['expires_at']),
        dismissedAt: parseDate(m['dismissed_at']),
        actedAt: parseDate(m['acted_at']),
        score: (m['score'] as num?)?.toDouble(),
      );

  /// ULID primary key.
  final String id;

  /// Owner user ULID.
  final String userId;

  /// Insight kind (e.g. `spending_spike`).
  final String kind;

  /// Short headline.
  final String title;

  /// Body copy.
  final String body;

  /// `info` | `tip` | `warning` | `celebration`.
  final String severity;

  /// Optional JSON-encoded payload.
  final String? payload;

  /// Generation timestamp (UTC).
  final DateTime generatedAt;

  /// Soft TTL (UTC); after this the insight is hidden.
  final DateTime? expiresAt;

  /// When the user dismissed the insight (UTC).
  final DateTime? dismissedAt;

  /// When the user acted on the insight's CTA (UTC).
  final DateTime? actedAt;

  /// Server-computed relevance score in `[0,100]`.
  final double? score;

  /// Serialises to a sqflite-friendly map.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'kind': kind,
        'title': title,
        'body': body,
        'severity': severity,
        'payload': payload,
        'generated_at': formatDate(generatedAt),
        'expires_at': formatDateOrNull(expiresAt),
        'dismissed_at': formatDateOrNull(dismissedAt),
        'acted_at': formatDateOrNull(actedAt),
        'score': score,
      };
}
