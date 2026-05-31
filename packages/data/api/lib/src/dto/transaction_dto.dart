/// REST representation of a transaction.
class TransactionDto {
  /// Default constructor.
  const TransactionDto({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.occurredAt,
    this.clientId,
    this.categoryId,
    this.description,
    this.tags = const <String>[],
    this.source,
    this.transferTargetAccountId,
    this.geo,
    this.attachments = const <Map<String, dynamic>>[],
    this.createdAt,
    this.updatedAt,
    this.revision = 0,
    this.balanceAfterMinor,
  });

  /// Server ULID (`tx_...`).
  final String id;

  /// Client-generated id (`ctx_...`) used for dedup; nullable when GETting.
  final String? clientId;

  /// Source account ULID.
  final String accountId;

  /// Category ULID or system id.
  final String? categoryId;

  /// `expense | income | transfer`.
  final String type;

  /// Amount in minor units (always positive).
  final int amountMinor;

  /// ISO 4217.
  final String currency;

  /// When the transaction occurred (UTC).
  final DateTime occurredAt;

  /// Optional description.
  final String? description;

  /// Up to 5 tags.
  final List<String> tags;

  /// Origin (`manual | widget | sms | kaspi_import | qr_receipt | api`).
  final String? source;

  /// Target account for transfers.
  final String? transferTargetAccountId;

  /// Optional geo blob (`{lat, lng, accuracy_m}`).
  final Map<String, dynamic>? geo;

  /// Attachment metadata (opaque).
  final List<Map<String, dynamic>> attachments;

  /// Server creation timestamp.
  final DateTime? createdAt;

  /// Server last-update timestamp.
  final DateTime? updatedAt;

  /// Optimistic-concurrency counter.
  final int revision;

  /// Server-computed balance after this transaction.
  final int? balanceAfterMinor;

  /// Parse from JSON.
  factory TransactionDto.fromJson(Map<String, dynamic> json) => TransactionDto(
        id: json['id'] as String,
        clientId: json['client_id'] as String?,
        accountId: json['account_id'] as String,
        categoryId: json['category_id'] as String?,
        type: json['type'] as String,
        amountMinor: (json['amount_minor'] as num).toInt(),
        currency: json['currency'] as String,
        occurredAt: DateTime.parse(json['occurred_at'] as String),
        description: json['description'] as String?,
        tags: ((json['tags'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) => e as String)
            .toList(growable: false),
        source: json['source'] as String?,
        transferTargetAccountId: json['transfer_target_account_id'] as String?,
        geo: json['geo'] is Map<String, dynamic>
            ? json['geo'] as Map<String, dynamic>
            : null,
        attachments:
            ((json['attachments'] as List<dynamic>?) ?? const <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .toList(growable: false),
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] is String
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        revision: (json['revision'] as num?)?.toInt() ?? 0,
        balanceAfterMinor: (json['balance_after_minor'] as num?)?.toInt(),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (clientId != null) 'client_id': clientId,
        'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        'type': type,
        'amount_minor': amountMinor,
        'currency': currency,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        if (description != null) 'description': description,
        'tags': tags,
        if (source != null) 'source': source,
        if (transferTargetAccountId != null)
          'transfer_target_account_id': transferTargetAccountId,
        if (geo != null) 'geo': geo,
        'attachments': attachments,
        if (createdAt != null)
          'created_at': createdAt!.toUtc().toIso8601String(),
        if (updatedAt != null)
          'updated_at': updatedAt!.toUtc().toIso8601String(),
        'revision': revision,
        if (balanceAfterMinor != null) 'balance_after_minor': balanceAfterMinor,
      };
}

/// Create-transaction payload.
class CreateTransactionRequest {
  /// Default constructor.
  const CreateTransactionRequest({
    required this.clientId,
    required this.accountId,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.occurredAt,
    this.categoryId,
    this.description,
    this.tags = const <String>[],
    this.source = 'manual',
    this.transferTargetAccountId,
    this.occurredAtLocal,
    this.timezone,
    this.geo,
    this.attachments = const <Map<String, dynamic>>[],
  });

  /// Client-generated dedup id (`ctx_...`).
  final String clientId;

  /// Source account ULID.
  final String accountId;

  /// `expense | income | transfer`.
  final String type;

  /// Amount in minor units.
  final int amountMinor;

  /// ISO 4217.
  final String currency;

  /// When the transaction occurred (UTC).
  final DateTime occurredAt;

  /// Category id.
  final String? categoryId;

  /// Description.
  final String? description;

  /// Tags.
  final List<String> tags;

  /// Origin.
  final String source;

  /// Transfer target.
  final String? transferTargetAccountId;

  /// Local-time occurrence (ISO 8601, no tz).
  final String? occurredAtLocal;

  /// IANA timezone.
  final String? timezone;

  /// Optional geo blob.
  final Map<String, dynamic>? geo;

  /// Attachments.
  final List<Map<String, dynamic>> attachments;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'client_id': clientId,
        'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        'type': type,
        'amount_minor': amountMinor,
        'currency': currency,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        if (occurredAtLocal != null) 'occurred_at_local': occurredAtLocal,
        if (timezone != null) 'timezone': timezone,
        if (description != null) 'description': description,
        'tags': tags,
        'source': source,
        if (transferTargetAccountId != null)
          'transfer_target_account_id': transferTargetAccountId,
        if (geo != null) 'geo': geo,
        'attachments': attachments,
      };
}

/// Partial update payload.
class UpdateTransactionRequest {
  /// Default constructor.
  const UpdateTransactionRequest({
    this.accountId,
    this.categoryId,
    this.type,
    this.amountMinor,
    this.currency,
    this.occurredAt,
    this.description,
    this.tags,
    this.transferTargetAccountId,
  });

  /// New account.
  final String? accountId;

  /// New category.
  final String? categoryId;

  /// New type.
  final String? type;

  /// New amount.
  final int? amountMinor;

  /// New currency.
  final String? currency;

  /// New occurrence time.
  final DateTime? occurredAt;

  /// New description.
  final String? description;

  /// New tags.
  final List<String>? tags;

  /// New transfer target.
  final String? transferTargetAccountId;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (accountId != null) 'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        if (type != null) 'type': type,
        if (amountMinor != null) 'amount_minor': amountMinor,
        if (currency != null) 'currency': currency,
        if (occurredAt != null)
          'occurred_at': occurredAt!.toUtc().toIso8601String(),
        if (description != null) 'description': description,
        if (tags != null) 'tags': tags,
        if (transferTargetAccountId != null)
          'transfer_target_account_id': transferTargetAccountId,
      };
}

/// `POST /transactions/bulk` payload.
class BulkCreateTransactionsRequest {
  /// Default constructor.
  const BulkCreateTransactionsRequest({
    required this.transactions,
    this.importSessionId,
    this.source = 'kaspi_import',
    this.onConflict = 'skip',
  });

  /// Up to 1000 transactions.
  final List<CreateTransactionRequest> transactions;

  /// Optional import session id (`imp_...`).
  final String? importSessionId;

  /// Origin.
  final String source;

  /// `skip | update | fail`.
  final String onConflict;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'transactions': transactions
            .map((CreateTransactionRequest e) => e.toJson())
            .toList(growable: false),
        if (importSessionId != null) 'import_session_id': importSessionId,
        'source': source,
        'on_conflict': onConflict,
      };
}

/// `POST /transactions/bulk` response.
class BulkCreateResponse {
  /// Default constructor.
  const BulkCreateResponse({
    required this.created,
    required this.skipped,
    required this.updated,
    required this.failed,
    this.failures = const <BulkFailureDto>[],
  });

  /// Number of newly created rows.
  final int created;

  /// Number of skipped (conflicting) rows.
  final int skipped;

  /// Number of updated rows.
  final int updated;

  /// Number of failed rows.
  final int failed;

  /// Per-row failure details.
  final List<BulkFailureDto> failures;

  /// Parse from JSON.
  factory BulkCreateResponse.fromJson(Map<String, dynamic> json) =>
      BulkCreateResponse(
        created: (json['created'] as num?)?.toInt() ?? 0,
        skipped: (json['skipped'] as num?)?.toInt() ?? 0,
        updated: (json['updated'] as num?)?.toInt() ?? 0,
        failed: (json['failed'] as num?)?.toInt() ?? 0,
        failures: ((json['failures'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) =>
                BulkFailureDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'created': created,
        'skipped': skipped,
        'updated': updated,
        'failed': failed,
        'failures':
            failures.map((BulkFailureDto e) => e.toJson()).toList(growable: false),
      };
}

/// Single failed row inside a bulk response.
class BulkFailureDto {
  /// Default constructor.
  const BulkFailureDto({
    required this.index,
    required this.code,
    required this.detail,
  });

  /// Row index in the request.
  final int index;

  /// Error code from the backend catalog.
  final String code;

  /// Human-readable detail.
  final String detail;

  /// Parse from JSON.
  factory BulkFailureDto.fromJson(Map<String, dynamic> json) => BulkFailureDto(
        index: (json['index'] as num).toInt(),
        code: json['code'] as String,
        detail: (json['detail'] ?? '') as String,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'index': index,
        'code': code,
        'detail': detail,
      };
}
