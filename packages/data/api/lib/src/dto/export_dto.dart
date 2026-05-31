/// `POST /export/request` body.
class ExportRequestRequest {
  /// Default constructor.
  const ExportRequestRequest({
    required this.format,
    required this.from,
    required this.to,
    this.entities = const <String>['transactions'],
    this.language,
  });

  /// `csv | xlsx | json | pdf`.
  final String format;

  /// Range start (YYYY-MM-DD).
  final String from;

  /// Range end (YYYY-MM-DD).
  final String to;

  /// Entities to include.
  final List<String> entities;

  /// BCP-47 language.
  final String? language;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'format': format,
        'from': from,
        'to': to,
        'entities': entities,
        if (language != null) 'language': language,
      };
}

/// `POST /export/request` response.
class ExportJobDto {
  /// Default constructor.
  const ExportJobDto({
    required this.jobId,
    required this.status,
    this.progress,
    this.createdAt,
    this.completedAt,
    this.downloadUrl,
    this.expiresAt,
    this.error,
    this.estimatedSeconds,
  });

  /// Job id (`job_...`).
  final String jobId;

  /// `queued | processing | completed | failed`.
  final String status;

  /// 0..1 progress fraction.
  final double? progress;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Completion timestamp.
  final DateTime? completedAt;

  /// Signed URL when ready.
  final String? downloadUrl;

  /// URL expiry.
  final DateTime? expiresAt;

  /// Error message when failed.
  final String? error;

  /// Estimated time to completion in seconds.
  final int? estimatedSeconds;

  /// Parse from JSON.
  factory ExportJobDto.fromJson(Map<String, dynamic> json) => ExportJobDto(
        jobId: json['job_id'] as String,
        status: json['status'] as String,
        progress: (json['progress'] as num?)?.toDouble(),
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'] as String)
            : null,
        completedAt: json['completed_at'] is String
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        downloadUrl: json['download_url'] as String?,
        expiresAt: json['expires_at'] is String
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        error: json['error'] as String?,
        estimatedSeconds: (json['estimated_seconds'] as num?)?.toInt(),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'job_id': jobId,
        'status': status,
        if (progress != null) 'progress': progress,
        if (createdAt != null)
          'created_at': createdAt!.toUtc().toIso8601String(),
        if (completedAt != null)
          'completed_at': completedAt!.toUtc().toIso8601String(),
        if (downloadUrl != null) 'download_url': downloadUrl,
        if (expiresAt != null)
          'expires_at': expiresAt!.toUtc().toIso8601String(),
        if (error != null) 'error': error,
        if (estimatedSeconds != null) 'estimated_seconds': estimatedSeconds,
      };
}
