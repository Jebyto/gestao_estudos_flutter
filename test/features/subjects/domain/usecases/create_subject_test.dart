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

    test('deve criar uma matéria válida', () async {
      final subject = makeSubject(name: 'Matemática');

      await usecase(subject);

      expect(repository.subjects, contains(subject));
    });

    test('deve chamar o repository', () async {
      final subject = makeSubject(name: 'Português');

      await usecase(subject);

      expect(repository.createSubjectWasCalled, isTrue);
      expect(repository.createdSubject, subject);
    });

    test('deve lançar erro se o nome estiver vazio', () async {
      final subject = makeSubject(name: '');

      expect(
        () => usecase(subject),
        throwsA(
          isA<EmptySubjectNameException>().having(
            (error) => error.message,
            'message',
            'Subject name is required.',
          ),
        ),
      );
    });

    test('deve lançar erro se o nome tiver apenas espaços', () async {
      final subject = makeSubject(name: '   ');

      expect(
        () => usecase(subject),
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
