import '../values/ulid.dart';

/// File format for an export job.
enum ExportFormat { csv, json, ofx }

/// Result of an export request.
class ExportArtifact {
  /// Default constructor.
  const ExportArtifact({
    required this.bytes,
    required this.mimeType,
    required this.filename,
  });

  /// Raw exported payload.
  final List<int> bytes;

  /// Mime type for the artifact.
  final String mimeType;

  /// Suggested filename.
  final String filename;
}

/// Export contract — backed by data layer aggregations.
abstract interface class ExportRepository {
  /// Produces an export of all user data for [userId] in [format].
  Future<ExportArtifact> exportAll(Ulid userId, ExportFormat format);
}
