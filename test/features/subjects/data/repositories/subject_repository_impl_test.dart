import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/datasources/subject_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/models/subject_model.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/repositories/subject_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';

void main() {
  group('SubjectRepositoryImpl', () {
    late FakeSubjectLocalDataSource localDataSource;
    late SubjectRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeSubjectLocalDataSource();
      repository = SubjectRepositoryImpl(localDataSource);
    });

    test('should create a subject using the local datasource', () async {
      // Arrange
      final subject = makeSubject(id: 'subject-1', name: 'Portuguese');

      // Act
      await repository.createSubject(subject);

      // Assert
      expect(localDataSource.createSubjectWasCalled, isTrue);
      expect(localDataSource.subjects.length, 1);
      expect(localDataSource.subjects.first.id, subject.id);
      expect(localDataSource.subjects.first.name, subject.name);
    });

    test('should return subjects as domain entities', () async {
      // Arrange
      localDataSource.subjects.add(
        SubjectModel(
          id: 'subject-1',
          name: 'Portuguese',
          createdAt: DateTime(2026, 6, 8),
        ),
      );

      // Act
      final subjects = await repository.getSubjects();

      // Assert
      expect(localDataSource.getSubjectsWasCalled, isTrue);
      expect(subjects.length, 1);
      expect(subjects.first, isA<Subject>());
      expect(subjects.first.name, 'Portuguese');
    });

    test('should delete a subject using the local datasource', () async {
      // Arrange
      localDataSource.subjects.add(
        SubjectModel(
          id: 'subject-1',
          name: 'Portuguese',
          createdAt: DateTime(2026, 6, 8),
        ),
      );

      // Act
      await repository.deleteSubject('subject-1');

      // Assert
      expect(localDataSource.deleteSubjectWasCalled, isTrue);
      expect(localDataSource.deletedSubjectId, 'subject-1');
      expect(localDataSource.subjects, isEmpty);
    });
  });
}

Subject makeSubject({required String id, required String name}) {
  return Subject(id: id, name: name, createdAt: DateTime(2026, 6, 8));
}

class FakeSubjectLocalDataSource implements SubjectLocalDataSource {
  final List<SubjectModel> subjects = [];
  bool createSubjectWasCalled = false;
  bool getSubjectsWasCalled = false;
  bool deleteSubjectWasCalled = false;
  String? deletedSubjectId;

  @override
  Future<void> createSubject(SubjectModel subject) async {
    createSubjectWasCalled = true;
    subjects.add(subject);
  }

  @override
  Future<void> deleteSubject(String id) async {
    deleteSubjectWasCalled = true;
    deletedSubjectId = id;
    subjects.removeWhere((subject) => subject.id == id);
  }

  @override
  Future<List<SubjectModel>> getSubjects() async {
    getSubjectsWasCalled = true;
    return subjects;
  }
}
