import '../repositories/settings_repository.dart';

/// Replaces user settings.
class UpdateSettings {
  /// Default constructor.
  const UpdateSettings(this._repo);

  final SettingsRepository _repo;

  /// Invokes the use case.
  Future<void> call(UserSettings settings) => _repo.save(settings);
}
