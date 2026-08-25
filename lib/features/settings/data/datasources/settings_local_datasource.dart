import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel?> getSettings();
  Future<void> saveSettings(SettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final AppDatabase appDatabase;

  const SettingsLocalDataSourceImpl(this.appDatabase);

  @override
  Future<SettingsModel?> getSettings() async {
    final database = await appDatabase.database;
    final result = await database.query(
      'settings',
      where: 'key = ?',
      whereArgs: [SettingsModel.themePreferenceKey],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return SettingsModel.fromMap(result.first);
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    final database = await appDatabase.database;

    await database.insert(
      'settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
