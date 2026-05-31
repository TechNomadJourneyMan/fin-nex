import 'package:equatable/equatable.dart';

import '../values/ulid.dart';
import 'enums.dart';

/// A server-generated suggestion or trend surfaced in the dashboard.
final class Insight extends Equatable {
  /// Default constructor.
  const Insight({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    required this.severity,
    required this.generatedAt,
    this.payload = const <String, dynamic>{},
    this.expiresAt,
    this.dismissedAt,
    this.actedAt,
    this.score,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// Kind string (e.g. `spending_spike`, `category_trend`, `saving_opportunity`).
  final String kind;

  /// Card title.
  final String title;

  /// Card body.
  final String body;

  /// Severity class.
  final InsightSeverity severity;

  /// Generated moment.
  final DateTime generatedAt;

  /// Expiration; null = no auto-hide.
  final DateTime? expiresAt;

  /// Dismissal moment.
  final DateTime? dismissedAt;

  /// When the user took the suggested action.
  final DateTime? actedAt;

  /// Free-form details (charts, numbers, deep-link).
  final Map<String, dynamic> payload;

  /// Optional ranking score (0–100).
  final double? score;

  /// True while not dismissed and not expired.
  bool get isActive {
    if (dismissedAt != null) {
      return false;
    }
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now().toUtc())) {
      return false;
    }
    return true;
  }

  /// Returns a copy with the given fields replaced.
  Insight copyWith({
    Ulid? id,
    Ulid? userId,
    String? kind,
    String? title,
    String? body,
    InsightSeverity? severity,
    DateTime? generatedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt,
    DateTime? actedAt,
    Map<String, dynamic>? payload,
    double? score,
  }) =>
      Insight(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        body: body ?? this.body,
        severity: severity ?? this.severity,
        generatedAt: generatedAt ?? this.generatedAt,
        expiresAt: expiresAt ?? this.expiresAt,
        dismissedAt: dismissedAt ?? this.dismissedAt,
        actedAt: actedAt ?? this.actedAt,
        payload: payload ?? this.payload,
        score: score ?? this.score,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'kind': kind,
        'title': title,
        'body': body,
        'severity': severity.code,
        'generated_at': generatedAt.toUtc().toIso8601String(),
        'expires_at': expiresAt?.toUtc().toIso8601String(),
        'dismissed_at': dismissedAt?.toUtc().toIso8601String(),
        'acted_at': actedAt?.toUtc().toIso8601String(),
        'payload': payload,
        'score': score,
      };

  /// Reconstructs from JSON.
  factory Insight.fromJson(Map<String, dynamic> json) => Insight(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        kind: json['kind'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        severity: InsightSeverity.parse(json['severity'] as String),
        generatedAt: DateTime.parse(json['generated_at'] as String),
        expiresAt: json['expires_at'] == null
            ? null
            : DateTime.parse(json['expires_at'] as String),
        dismissedAt: json['dismissed_at'] == null
            ? null
            : DateTime.parse(json['dismissed_at'] as String),
        actedAt: json['acted_at'] == null
            ? null
            : DateTime.parse(json['acted_at'] as String),
        payload: (json['payload'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
        score: (json['score'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        kind,
        title,
        body,
        severity,
        generatedAt,
        expiresAt,
        dismissedAt,
        actedAt,
        payload,
        score,
      ];
}
