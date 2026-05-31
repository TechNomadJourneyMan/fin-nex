/// Cursor-based pagination envelope.
class PaginationDto {
  /// Default constructor.
  const PaginationDto({
    this.nextCursor,
    this.hasMore = false,
    this.limit = 50,
  });

  /// Opaque cursor for the next page, or `null` when at end.
  final String? nextCursor;

  /// Convenience flag.
  final bool hasMore;

  /// Page size echoed by the server.
  final int limit;

  /// Parse from JSON.
  factory PaginationDto.fromJson(Map<String, dynamic> json) => PaginationDto(
        nextCursor: json['next_cursor'] as String?,
        hasMore: (json['has_more'] as bool?) ?? false,
        limit: (json['limit'] as num?)?.toInt() ?? 50,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'next_cursor': nextCursor,
        'has_more': hasMore,
        'limit': limit,
      };
}

/// Generic paginated list envelope.
class PagedDto<T> {
  /// Default constructor.
  const PagedDto({
    required this.data,
    required this.pagination,
    this.aggregates,
  });

  /// Page data.
  final List<T> data;

  /// Pagination metadata.
  final PaginationDto pagination;

  /// Optional aggregates (e.g. totals).
  final Map<String, dynamic>? aggregates;

  /// Parse from JSON using [itemFromJson].
  static PagedDto<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final raw = (json['data'] as List<dynamic>?) ?? const <dynamic>[];
    final items = raw
        .map((dynamic e) => itemFromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    final pagination = json['pagination'] is Map<String, dynamic>
        ? PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>)
        : const PaginationDto();
    final aggregates = json['aggregates'] is Map<String, dynamic>
        ? json['aggregates'] as Map<String, dynamic>
        : null;
    return PagedDto<T>(
      data: items,
      pagination: pagination,
      aggregates: aggregates,
    );
  }
}
