import '../repositories/export_repository.dart';
import '../values/ulid.dart';

/// Exports all user data in the requested format.
class ExportData {
  /// Default constructor.
  const ExportData(this._repo);

  final ExportRepository _repo;

  /// Invokes the use case.
  Future<ExportArtifact> call(
    Ulid userId, {
    ExportFormat format = ExportFormat.csv,
  }) =>
      _repo.exportAll(userId, format);
}
