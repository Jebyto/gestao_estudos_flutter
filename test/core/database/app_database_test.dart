import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase appDatabase;

    setUp(() {
      sqfliteFfiInit();
      appDatabase = AppDatabase(
        databasePath: inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        singleInstance: false,
      );
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('should create the initial database tables', () async {
      // Arrange
      final database = await appDatabase.database;

      // Act
      final result = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );

      // Assert
      final tableNames = result.map((row) => row['name']).toList();
      expect(tableNames, contains('subjects'));
      expect(tableNames, contains('topics'));
      expect(tableNames, contains('study_sessions'));
      expect(tableNames, contains('reviews'));
      expect(tableNames, contains('settings'));
    });

    test('should enable foreign keys', () async {
      // Arrange
      final database = await appDatabase.database;

      // Act
      final result = await database.rawQuery('PRAGMA foreign_keys');

      // Assert
      expect(result.first['foreign_keys'], 1);
    });
  });

  test('should migrate version 1 database without losing data', () async {
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'study-flow-database-test-',
    );
    final databasePath = '${temporaryDirectory.path}/study_flow.db';
    final versionOneDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE subjects (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT
            )
          ''');
          await database.insert('subjects', {
            'id': 'subject-1',
            'name': 'Matemática',
            'created_at': DateTime(2026, 8, 25).toIso8601String(),
          });
        },
      ),
    );
    await versionOneDatabase.close();
    final migratedDatabase = AppDatabase(
      databasePath: databasePath,
      databaseFactory: databaseFactoryFfi,
      singleInstance: false,
    );

    try {
      final database = await migratedDatabase.database;
      final settingsTable = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'settings'",
      );
      final subjects = await database.query('subjects');

      expect(settingsTable, isNotEmpty);
      expect(subjects.single['name'], 'Matemática');
      expect(await database.getVersion(), AppDatabase.databaseVersion);
    } finally {
      await migratedDatabase.close();
      await temporaryDirectory.delete(recursive: true);
    }
  });
}
