import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/create_subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/delete_subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/usecases/get_subjects.dart';
import 'package:gestao_estudos_flutter/features/subjects/presentation/cubit/subjects_cubit.dart';
import 'package:gestao_estudos_flutter/features/subjects/presentation/pages/subjects_page.dart';

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
      generateSubjectId: () => 'subject-created',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('deve exibir estado vazio quando não houver matérias', (
    tester,
  ) async {
    await cubit.loadSubjects();
    await tester.pumpSubjectsPage(cubit);

    expect(find.text('Nenhuma matéria cadastrada'), findsOneWidget);
  });

  testWidgets('deve listar matérias cadastradas', (tester) async {
    repository.subjects.add(
      Subject(
        id: 'subject-1',
        name: 'Banco de Dados',
        description: 'Modelagem relacional',
        createdAt: today,
      ),
    );

    await cubit.loadSubjects();
    await tester.pumpSubjectsPage(cubit);

    expect(find.text('Banco de Dados'), findsOneWidget);
    expect(find.text('Modelagem relacional'), findsOneWidget);
  });

  testWidgets('deve chamar callback ao tocar em uma matéria', (tester) async {
    Subject? selectedSubject;
    final subject = Subject(
      id: 'subject-1',
      name: 'Banco de Dados',
      createdAt: today,
    );
    repository.subjects.add(subject);

    await cubit.loadSubjects();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: SubjectsPage(
            onSubjectSelected: (_, subject) {
              selectedSubject = subject;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Banco de Dados'));
    await tester.pump();

    expect(selectedSubject, subject);
  });

  testWidgets('deve criar matéria pelo formulário', (tester) async {
    await cubit.loadSubjects();
    await tester.pumpSubjectsPage(cubit);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Português');
    await tester.enterText(find.byType(TextFormField).last, 'Gramática');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(repository.subjects.length, 1);
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('Gramática'), findsOneWidget);
  });

  testWidgets('deve validar nome obrigatório no formulário', (tester) async {
    await cubit.loadSubjects();
    await tester.pumpSubjectsPage(cubit);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o nome da matéria'), findsOneWidget);
    expect(repository.subjects, isEmpty);
  });
}

extension on WidgetTester {
  Future<void> pumpSubjectsPage(SubjectsCubit cubit) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const SubjectsPage()),
      ),
    );
  }
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
