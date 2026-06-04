import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/errors/subject_exceptions.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/delete_subject.dart';

void main() {
  group('DeleteSubject', () {
    late FakeSubjectRepository repository;
    late DeleteSubject usecase;

    setUp(() {
      repository = FakeSubjectRepository();
      usecase = DeleteSubject(repository);
    });

    test('should delete a subject by id', () async {
      // Arrange
      final subject = makeSubject(id: 'subject-1', name: 'Mathematics');
      repository.subjects.add(subject);

      // Act
      await usecase(subject.id);

      // Assert
      expect(repository.subjects, isEmpty);
    });

    test('should call the repository with the correct id', () async {
      // Arrange
      const subjectId = 'subject-1';

      // Act
      await usecase(subjectId);

      // Assert
      expect(repository.deleteSubjectWasCalled, isTrue);
      expect(repository.deletedId, subjectId);
    });

    test('should throw an error when the id is empty', () async {
      // Arrange

      // Act
      Future<void> action() => usecase('');

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptySubjectIdException>().having(
            (error) => error.message,
            'message',
            'Subject id is required.',
          ),
        ),
      );
    });

    test('should throw an error when the id has only spaces', () async {
      // Arrange

      // Act
      Future<void> action() => usecase('   ');

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptySubjectIdException>().having(
            (error) => error.message,
            'message',
            'Subject id is required.',
          ),
        ),
      );
    });
  });
}

Subject makeSubject({required String id, required String name}) {
  return Subject(id: id, name: name, createdAt: DateTime(2026, 6));
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects = [];
  bool deleteSubjectWasCalled = false;
  String? deletedId;

  @override
  Future<void> createSubject(Subject subject) async {
    subjects.add(subject);
  }

  @override
  Future<void> deleteSubject(String id) async {
    deleteSubjectWasCalled = true;
    deletedId = id;
    subjects.removeWhere((subject) => subject.id == id);
  }

  @override
  Future<List<Subject>> getSubjects() async {
    return subjects;
  }
}
