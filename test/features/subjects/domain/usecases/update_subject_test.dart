import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/errors/subject_exceptions.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/update_subject.dart';

void main() {
  group('UpdateSubject', () {
    late FakeSubjectRepository repository;
    late UpdateSubject usecase;

    setUp(() {
      repository = FakeSubjectRepository();
      usecase = UpdateSubject(repository);
    });

    test('should update a valid subject', () async {
      final subject = makeSubject();

      await usecase(subject);

      expect(repository.updatedSubject, subject);
    });

    test('should throw an error when the id is empty', () async {
      final subject = makeSubject(id: '');

      Future<void> action() => usecase(subject);

      expect(action, throwsA(isA<EmptySubjectIdException>()));
    });

    test('should throw an error when the name is empty', () async {
      final subject = makeSubject(name: '   ');

      Future<void> action() => usecase(subject);

      expect(action, throwsA(isA<EmptySubjectNameException>()));
    });
  });
}

Subject makeSubject({String id = 'subject-1', String name = 'Mathematics'}) {
  return Subject(id: id, name: name, createdAt: DateTime(2026, 6, 8));
}

class FakeSubjectRepository implements SubjectRepository {
  Subject? updatedSubject;

  @override
  Future<void> updateSubject(Subject subject) async {
    updatedSubject = subject;
  }

  @override
  Future<void> createSubject(Subject subject) async {}

  @override
  Future<void> deleteSubject(String id) async {}

  @override
  Future<List<Subject>> getSubjects() async => [];
}
