import '../entities/theme_preference.dart';

abstract class SettingsRepository {
  Future<ThemePreference> getThemePreference();
  Future<void> saveThemePreference(ThemePreference preference);
}
