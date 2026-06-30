import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/create_subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/delete_subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/get_subjects.dart';
import 'package:gestao_estudos_flutter/features/subjects/presentation/cubit/subjects_cubit.dart';
import 'package:gestao_estudos_flutter/features/subjects/presentation/cubit/subjects_state.dart';

void main() {
  late FakeSubjectRepository repository;
  late SubjectsCubit cubit;
  final today = DateTime(2026, 6, 29);

  setUp(() {
    repository = FakeSubjectRepository();
    cubit = SubjectsCubit(
      getSubjects: GetSubjects(repository),
      createSubjectUseCase: CreateSubject(repository),
      deleteSubjectUseCase: DeleteSubject(repository),
      generateSubjectId: () => 'subject-1',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('deve iniciar com estado initial e lista vazia', () {
    expect(cubit.state.status, SubjectsStatus.initial);
    expect(cubit.state.subjects, isEmpty);
  });

  test('deve carregar matérias do repository', () async {
    final subject = Subject(
      id: 'subject-1',
      name: 'Matemática',
      createdAt: today,
    );
    repository.subjects.add(subject);

    await cubit.loadSubjects();

    expect(cubit.state.status, SubjectsStatus.success);
    expect(cubit.state.subjects, [subject]);
  });

  test('deve criar uma matéria e recarregar a lista', () async {
    final created = await cubit.createSubject(
      name: ' Português ',
      description: ' Gramática ',
    );

    expect(created, isTrue);
    expect(repository.subjects.length, 1);
    expect(repository.subjects.first.id, 'subject-1');
    expect(repository.subjects.first.name, 'Português');
    expect(repository.subjects.first.description, 'Gramática');
    expect(repository.subjects.first.createdAt, today);
    expect(cubit.state.status, SubjectsStatus.success);
    expect(cubit.state.subjects, repository.subjects);
  });

  test('deve rejeitar criação quando o nome estiver vazio', () async {
    final created = await cubit.createSubject(name: '   ');

    expect(created, isFalse);
    expect(repository.subjects, isEmpty);
    expect(cubit.state.status, SubjectsStatus.failure);
    expect(cubit.state.errorMessage, 'Informe o nome da matéria.');
  });

  test('deve excluir uma matéria e recarregar a lista', () async {
    repository.subjects.add(
      Subject(id: 'subject-1', name: 'História', createdAt: today),
    );

    await cubit.deleteSubject('subject-1');

    expect(repository.subjects, isEmpty);
    expect(cubit.state.status, SubjectsStatus.success);
    expect(cubit.state.subjects, isEmpty);
  });
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
