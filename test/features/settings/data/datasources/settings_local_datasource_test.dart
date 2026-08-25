import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/settings/data/models/settings_model.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late SettingsLocalDataSource dataSource;

  setUp(() {
    sqfliteFfiInit();
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
      singleInstance: false,
    );
    dataSource = SettingsLocalDataSourceImpl(appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('deve retornar null quando não houver preferência salva', () async {
    expect(await dataSource.getSettings(), isNull);
  });

  test('deve salvar e recuperar preferência de tema', () async {
    const settings = SettingsModel(themePreference: ThemePreference.dark);

    await dataSource.saveSettings(settings);
    final result = await dataSource.getSettings();

    expect(result?.themePreference, ThemePreference.dark);
  });

  test('deve substituir a preferência existente', () async {
    await dataSource.saveSettings(
      const SettingsModel(themePreference: ThemePreference.light),
    );
    await dataSource.saveSettings(
      const SettingsModel(themePreference: ThemePreference.dark),
    );

    final result = await dataSource.getSettings();

    expect(result?.themePreference, ThemePreference.dark);
  });
}
