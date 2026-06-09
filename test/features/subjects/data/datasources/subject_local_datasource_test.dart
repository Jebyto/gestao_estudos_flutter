import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/datasources/subject_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/models/subject_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SubjectLocalDataSourceImpl', () {
    late AppDatabase appDatabase;
    late SubjectLocalDataSourceImpl dataSource;

    setUp(() {
      sqfliteFfiInit();
      appDatabase = AppDatabase(
        databasePath: inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        singleInstance: false,
      );
      dataSource = SubjectLocalDataSourceImpl(appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('should save and get subjects from SQLite', () async {
      // Arrange
      final subject = makeSubject(id: 'subject-1', name: 'Math');

      // Act
      await dataSource.createSubject(subject);
      final subjects = await dataSource.getSubjects();

      // Assert
      expect(subjects.length, 1);
      expect(subjects.first.id, 'subject-1');
      expect(subjects.first.name, 'Math');
    });

    test('should order subjects by createdAt descending', () async {
      // Arrange
      final olderSubject = makeSubject(
        id: 'subject-1',
        name: 'Math',
        createdAt: DateTime(2026, 6, 7),
      );
      final newerSubject = makeSubject(
        id: 'subject-2',
        name: 'Portuguese',
        createdAt: DateTime(2026, 6, 8),
      );

      // Act
      await dataSource.createSubject(olderSubject);
      await dataSource.createSubject(newerSubject);
      final subjects = await dataSource.getSubjects();

      // Assert
      expect(subjects.map((subject) => subject.id), ['subject-2', 'subject-1']);
    });

    test(
      'should replace a subject when creating with an existing id',
      () async {
        // Arrange
        final subject = makeSubject(id: 'subject-1', name: 'Math');
        final updatedSubject = makeSubject(
          id: 'subject-1',
          name: 'Advanced Math',
        );

        // Act
        await dataSource.createSubject(subject);
        await dataSource.createSubject(updatedSubject);
        final subjects = await dataSource.getSubjects();

        // Assert
        expect(subjects.length, 1);
        expect(subjects.first.name, 'Advanced Math');
      },
    );

    test('should delete a subject from SQLite', () async {
      // Arrange
      final subject = makeSubject(id: 'subject-1', name: 'Math');
      await dataSource.createSubject(subject);

      // Act
      await dataSource.deleteSubject('subject-1');
      final subjects = await dataSource.getSubjects();

      // Assert
      expect(subjects, isEmpty);
    });
  });
}

SubjectModel makeSubject({
  required String id,
  required String name,
  DateTime? createdAt,
}) {
  return SubjectModel(
    id: id,
    name: name,
    createdAt: createdAt ?? DateTime(2026, 6, 8),
  );
}
