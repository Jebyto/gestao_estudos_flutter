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
}
