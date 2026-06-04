import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/errors/subject_exceptions.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/create_subject.dart';

void main() {
  group('CreateSubject', () {
    late FakeSubjectRepository repository;
    late CreateSubject usecase;

    setUp(() {
      repository = FakeSubjectRepository();
      usecase = CreateSubject(repository);
    });

    test('should create a valid subject', () async {
      // Arrange
      final subject = makeSubject(name: 'Mathematics');

      // Act
      await usecase(subject);

      // Assert
      expect(repository.subjects, contains(subject));
    });

    test('should call the repository', () async {
      // Arrange
      final subject = makeSubject(name: 'Portuguese');

      // Act
      await usecase(subject);

      // Assert
      expect(repository.createSubjectWasCalled, isTrue);
      expect(repository.createdSubject, subject);
    });

    test('should throw an error when the name is empty', () async {
      // Arrange
      final subject = makeSubject(name: '');

      // Act
      Future<void> action() => usecase(subject);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptySubjectNameException>().having(
            (error) => error.message,
            'message',
            'Subject name is required.',
          ),
        ),
      );
    });

    test('should throw an error when the name has only spaces', () async {
      // Arrange
      final subject = makeSubject(name: '   ');

      // Act
      Future<void> action() => usecase(subject);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptySubjectNameException>().having(
            (error) => error.message,
            'message',
            'Subject name is required.',
          ),
        ),
      );
    });
  });
}

Subject makeSubject({required String name}) {
  return Subject(id: 'subject-1', name: name, createdAt: DateTime(2026, 6));
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects = [];
  bool createSubjectWasCalled = false;
  Subject? createdSubject;

  @override
  Future<void> createSubject(Subject subject) async {
    createSubjectWasCalled = true;
    createdSubject = subject;
    subjects.add(subject);
  }

  @override
  Future<void> deleteSubject(String id) async {
    subjects.removeWhere((subject) => subject.id == id);
  }

  @override
  Future<List<Subject>> getSubjects() async {
    return subjects;
  }
}
