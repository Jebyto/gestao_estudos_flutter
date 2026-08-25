import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  const SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<ThemePreference> getThemePreference() async {
    final model = await localDataSource.getSettings();

    return model?.toPreference() ?? ThemePreference.system;
  }

  @override
  Future<void> saveThemePreference(ThemePreference preference) {
    return localDataSource.saveSettings(
      SettingsModel.fromPreference(preference),
    );
  }
}
