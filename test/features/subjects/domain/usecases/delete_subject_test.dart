import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
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

    test('deve excluir uma matéria pelo id', () async {
      final subject = makeSubject(id: 'subject-1', name: 'Matemática');
      repository.subjects.add(subject);

      await usecase(subject.id);

      expect(repository.subjects, isEmpty);
    });

    test('deve chamar o repository com o id correto', () async {
      await usecase('subject-1');

      expect(repository.deleteSubjectWasCalled, isTrue);
      expect(repository.deletedId, 'subject-1');
    });

    test('deve lançar erro se o id estiver vazio', () async {
      expect(
        () => usecase(''),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'O id da matéria é obrigatório.',
          ),
        ),
      );
    });

    test('deve lançar erro se o id tiver apenas espaços', () async {
      expect(
        () => usecase('   '),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'O id da matéria é obrigatório.',
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
