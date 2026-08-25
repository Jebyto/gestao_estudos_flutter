import '../entities/theme_preference.dart';
import '../repositories/settings_repository.dart';

class GetThemePreference {
  final SettingsRepository repository;

  const GetThemePreference(this.repository);

  Future<ThemePreference> call() {
    return repository.getThemePreference();
  }
}
