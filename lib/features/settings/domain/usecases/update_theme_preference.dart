import '../entities/theme_preference.dart';
import '../repositories/settings_repository.dart';

class UpdateThemePreference {
  final SettingsRepository repository;

  const UpdateThemePreference(this.repository);

  Future<void> call(ThemePreference preference) {
    return repository.saveThemePreference(preference);
  }
}
