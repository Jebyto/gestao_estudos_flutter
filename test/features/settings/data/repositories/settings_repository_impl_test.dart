import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/settings/data/models/settings_model.dart';
import 'package:gestao_estudos_flutter/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';

void main() {
  late FakeSettingsLocalDataSource dataSource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    dataSource = FakeSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(dataSource);
  });

  test(
    'deve retornar tema do sistema quando não houver configuração',
    () async {
      expect(await repository.getThemePreference(), ThemePreference.system);
    },
  );

  test('deve retornar preferência salva', () async {
    dataSource.settings = const SettingsModel(
      themePreference: ThemePreference.dark,
    );

    expect(await repository.getThemePreference(), ThemePreference.dark);
  });

  test('deve salvar preferência usando o datasource', () async {
    await repository.saveThemePreference(ThemePreference.light);

    expect(dataSource.settings?.themePreference, ThemePreference.light);
  });
}

class FakeSettingsLocalDataSource implements SettingsLocalDataSource {
  SettingsModel? settings;

  @override
  Future<SettingsModel?> getSettings() async => settings;

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    this.settings = settings;
  }
}
