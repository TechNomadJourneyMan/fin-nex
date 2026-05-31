// Abstraction + default Dio implementation for the voice transcription
// backend call (`POST /v1/voice/transcribe`).
//
// The feature package depends only on the [VoiceTranscriptionService]
// interface so it stays testable; the default [DioVoiceTranscriptionService]
// performs the actual multipart upload. Apps may override the provider with a
// fake during widget tests.

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fnx_domain/domain.dart';

/// Result of a successful transcription + parse round-trip.
///
/// The backend is expected to return both the raw transcript and a best-effort
/// structured interpretation of the utterance as a draft transaction. All
/// structured fields are nullable because parsing is heuristic.
class VoiceTranscriptionResult {
  /// Builds a transcription result.
  const VoiceTranscriptionResult({
    required this.transcript,
    this.amount,
    this.type,
    this.suggestedCategoryId,
    this.suggestedCategoryLabel,
    this.suggestedAccountId,
    this.suggestedAccountLabel,
    this.note,
    this.confidence = 0,
  });

  /// Raw recognized text.
  final String transcript;

  /// Parsed monetary amount, if the model extracted one.
  final Money? amount;

  /// Parsed transaction direction.
  final TransactionType? type;

  /// Suggested category id (ULID or system-category surrogate string).
  final String? suggestedCategoryId;

  /// Human-readable category label for display.
  final String? suggestedCategoryLabel;

  /// Suggested account id.
  final String? suggestedAccountId;

  /// Human-readable account label for display.
  final String? suggestedAccountLabel;

  /// Optional free-text note extracted from the utterance.
  final String? note;

  /// Model confidence in `[0, 1]`.
  final double confidence;

  /// Parses the backend JSON envelope into a [VoiceTranscriptionResult].
  factory VoiceTranscriptionResult.fromJson(Map<String, dynamic> json) {
    final amountJson = json['amount'];
    Money? amount;
    if (amountJson is Map<String, dynamic>) {
      final minor = amountJson['minor'];
      final currency = amountJson['currency'];
      if (minor != null && currency is String) {
        final parsed = Currency.tryParse(currency);
        if (parsed != null) {
          amount = Money(BigInt.parse(minor.toString()), parsed);
        }
      }
    }
    final typeCode = json['type'] as String?;
    return VoiceTranscriptionResult(
      transcript: (json['transcript'] as String?) ?? '',
      amount: amount,
      type: typeCode == null ? null : _tryParseType(typeCode),
      suggestedCategoryId: json['category_id'] as String?,
      suggestedCategoryLabel: json['category_label'] as String?,
      suggestedAccountId: json['account_id'] as String?,
      suggestedAccountLabel: json['account_label'] as String?,
      note: json['note'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  static TransactionType? _tryParseType(String code) {
    try {
      return TransactionType.parse(code);
    } on ArgumentError {
      return null;
    }
  }

  /// Returns a copy with selected overrides.
  VoiceTranscriptionResult copyWith({
    String? transcript,
    Money? amount,
    TransactionType? type,
    String? suggestedCategoryId,
    String? suggestedCategoryLabel,
    String? suggestedAccountId,
    String? suggestedAccountLabel,
    String? note,
    double? confidence,
  }) {
    return VoiceTranscriptionResult(
      transcript: transcript ?? this.transcript,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      suggestedCategoryId: suggestedCategoryId ?? this.suggestedCategoryId,
      suggestedCategoryLabel:
          suggestedCategoryLabel ?? this.suggestedCategoryLabel,
      suggestedAccountId: suggestedAccountId ?? this.suggestedAccountId,
      suggestedAccountLabel:
          suggestedAccountLabel ?? this.suggestedAccountLabel,
      note: note ?? this.note,
      confidence: confidence ?? this.confidence,
    );
  }
}

/// Uploads recorded audio and returns a parsed transaction draft.
///
/// Implementations must not throw for expected network failures; instead they
/// should surface a [VoiceTranscriptionException] that the controller maps to
/// its `error` state.
abstract class VoiceTranscriptionService {
  /// Sends [bytes] (encoded per [mimeType]) to the backend for transcription.
  Future<VoiceTranscriptionResult> transcribe(
    Uint8List bytes, {
    String mimeType = 'audio/m4a',
    String? locale,
  });
}

/// Raised when transcription cannot be completed.
class VoiceTranscriptionException implements Exception {
  /// Creates a transcription exception with a user-presentable [message].
  const VoiceTranscriptionException(this.message, {this.cause});

  /// Human-readable message.
  final String message;

  /// Underlying error, if any.
  final Object? cause;

  @override
  String toString() => 'VoiceTranscriptionException: $message';
}

/// Default [VoiceTranscriptionService] that performs a multipart `POST` to
/// `/v1/voice/transcribe` using an injected [Dio].
class DioVoiceTranscriptionService implements VoiceTranscriptionService {
  /// Creates the service over [_dio].
  DioVoiceTranscriptionService(this._dio, {this.path = '/v1/voice/transcribe'});

  final Dio _dio;

  /// Endpoint path (override for versioning/testing).
  final String path;

  @override
  Future<VoiceTranscriptionResult> transcribe(
    Uint8List bytes, {
    String mimeType = 'audio/m4a',
    String? locale,
  }) async {
    try {
      final form = FormData.fromMap(<String, dynamic>{
        if (locale != null) 'locale': locale,
        'audio': MultipartFile.fromBytes(
          bytes,
          filename: 'utterance.m4a',
        ),
      });
      final res = await _dio.post<Map<String, dynamic>>(
        path,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final body = res.data ?? const <String, dynamic>{};
      // Tolerate both bare and `{ data: {...} }` envelopes.
      final payload = (body['data'] as Map<String, dynamic>?) ?? body;
      return VoiceTranscriptionResult.fromJson(payload);
    } on DioException catch (e) {
      throw VoiceTranscriptionException(
        e.message ?? 'Could not reach the transcription service.',
        cause: e,
      );
    }
  }
}
