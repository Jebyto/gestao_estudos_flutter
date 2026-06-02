import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/get_subjects.dart';

void main() {
  group('GetSubjects', () {
    late FakeSubjectRepository repository;
    late GetSubjects usecase;

    setUp(() {
      repository = FakeSubjectRepository();
      usecase = GetSubjects(repository);
    });

    test('deve retornar uma lista vazia quando não houver matérias', () async {
      final subjects = await usecase();

      expect(subjects, isEmpty);
    });

    test('deve retornar as matérias cadastradas', () async {
      final firstSubject = makeSubject(id: 'subject-1', name: 'Matemática');
      final secondSubject = makeSubject(id: 'subject-2', name: 'Programação');
      repository.subjects.addAll([firstSubject, secondSubject]);

      final subjects = await usecase();

      expect(subjects, [firstSubject, secondSubject]);
    });
  });
}

Subject makeSubject({required String id, required String name}) {
  return Subject(id: id, name: name, createdAt: DateTime(2026, 6));
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects = [];

  @override
  Future<void> createSubject(Subject subject) async {
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
