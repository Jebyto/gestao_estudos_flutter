import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';

abstract class ReminderPreferencesLocalDataSource {
  Future<bool> getEnabled();
  Future<void> setEnabled(bool enabled);
}

class ReminderPreferencesLocalDataSourceImpl
    implements ReminderPreferencesLocalDataSource {
  static const preferenceKey = 'review_reminders_enabled';
  final AppDatabase appDatabase;

  const ReminderPreferencesLocalDataSourceImpl(this.appDatabase);

  @override
  Future<bool> getEnabled() async {
    final db = await appDatabase.database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [preferenceKey],
    );
    return rows.isNotEmpty && rows.single['value'] == 'true';
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    final db = await appDatabase.database;
    await db.insert('settings', {
      'key': preferenceKey,
      'value': enabled.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
