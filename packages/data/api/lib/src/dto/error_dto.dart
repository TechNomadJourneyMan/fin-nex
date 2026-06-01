/// Field-level error item nested inside a [ProblemDetailsDto].
class FieldErrorDto {
  /// Default constructor.
  const FieldErrorDto({
    required this.field,
    required this.code,
    required this.message,
  });

  /// Field path (e.g. `amount_minor`).
  final String field;

  /// Machine-readable error code.
  final String code;

  /// Human-readable message.
  final String message;

  /// Parse from JSON.
  factory FieldErrorDto.fromJson(Map<String, dynamic> json) => FieldErrorDto(
        field: (json['field'] ?? '') as String,
        code: (json['code'] ?? '') as String,
        message: (json['message'] ?? '') as String,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'field': field,
        'code': code,
        'message': message,
      };
}

/// RFC 9457 Problem Details document returned by the PocketFlow backend.
class ProblemDetailsDto {
  /// Default constructor.
  const ProblemDetailsDto({
    required this.type,
    required this.title,
    required this.status,
    required this.code,
    required this.detail,
    required this.traceId,
    this.instance,
    this.errors = const <FieldErrorDto>[],
    this.retryAfterSeconds,
  });

  /// Problem URI.
  final String type;

  /// Short human title.
  final String title;

  /// HTTP status.
  final int status;

  /// Stable backend code (see Error Catalog).
  final String code;

  /// Long detail.
  final String detail;

  /// Trace id for support.
  final String traceId;

  /// Optional pointer to the offending resource.
  final String? instance;

  /// Optional list of field-level errors.
  final List<FieldErrorDto> errors;

  /// Optional retry-after hint, in seconds.
  final int? retryAfterSeconds;

  /// Parse from JSON.
  factory ProblemDetailsDto.fromJson(Map<String, dynamic> json) =>
      ProblemDetailsDto(
        type: (json['type'] ?? '') as String,
        title: (json['title'] ?? '') as String,
        status: (json['status'] as num?)?.toInt() ?? 0,
        code: (json['code'] ?? 'UNKNOWN') as String,
        detail: (json['detail'] ?? '') as String,
        traceId: (json['trace_id'] ?? '') as String,
        instance: json['instance'] as String?,
        errors: ((json['errors'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) =>
                FieldErrorDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        retryAfterSeconds: (json['retry_after_seconds'] as num?)?.toInt(),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'title': title,
        'status': status,
        'code': code,
        'detail': detail,
        'trace_id': traceId,
        if (instance != null) 'instance': instance,
        'errors': errors
            .map((FieldErrorDto e) => e.toJson())
            .toList(growable: false),
        if (retryAfterSeconds != null)
          'retry_after_seconds': retryAfterSeconds,
      };
}
