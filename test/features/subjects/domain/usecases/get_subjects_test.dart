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

    test('should return an empty list when there are no subjects', () async {
      // Arrange

      // Act
      final subjects = await usecase();

      // Assert
      expect(subjects, isEmpty);
    });

    test('should return the registered subjects', () async {
      // Arrange
      final firstSubject = makeSubject(id: 'subject-1', name: 'Mathematics');
      final secondSubject = makeSubject(id: 'subject-2', name: 'Programming');
      repository.subjects.addAll([firstSubject, secondSubject]);

      // Act
      final subjects = await usecase();

      // Assert
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
