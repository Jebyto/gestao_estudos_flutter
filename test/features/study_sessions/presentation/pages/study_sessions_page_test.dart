import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/repositories/study_session_repository.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/create_study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/delete_study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/get_study_sessions_by_subject.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/presentation/cubit/study_sessions_cubit.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/presentation/pages/study_sessions_page.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';

void main() {
  late FakeStudySessionRepository repository;
  late StudySessionsCubit cubit;
  final today = DateTime(2026, 7, 2, 9, 30);
  final subject = Subject(
    id: 'subject-1',
    name: 'Banco de Dados',
    createdAt: today,
  );
  final topics = [
    Topic(
      id: 'topic-1',
      subjectId: subject.id,
      title: 'Normalização',
      status: TopicStatus.studying,
      priority: TopicPriority.high,
      createdAt: today,
    ),
  ];

  setUp(() {
    repository = FakeStudySessionRepository();
    cubit = StudySessionsCubit(
      subjectId: subject.id,
      getStudySessionsBySubject: GetStudySessionsBySubject(repository),
      createStudySessionUseCase: CreateStudySession(repository),
      deleteStudySessionUseCase: DeleteStudySession(repository),
      generateStudySessionId: () => 'session-created',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('deve exibir estado vazio quando não houver sessões', (
    tester,
  ) async {
    await cubit.loadStudySessions();
    await tester.pumpStudySessionsPage(cubit, subject, topics);

    expect(find.text('Sessões - Banco de Dados'), findsOneWidget);
    expect(find.text('Nenhuma sessão registrada'), findsOneWidget);
  });

  testWidgets('deve listar sessões cadastradas', (tester) async {
    repository.studySessions.add(
      StudySession(
        id: 'session-1',
        subjectId: subject.id,
        topicId: 'topic-1',
        durationInMinutes: 75,
        studiedAt: today,
        notes: 'Prática de modelagem',
        createdAt: today,
      ),
    );

    await cubit.loadStudySessions();
    await tester.pumpStudySessionsPage(cubit, subject, topics);

    expect(find.text('1h 15min'), findsOneWidget);
    expect(find.text('Normalização'), findsOneWidget);
    expect(find.text('Prática de modelagem'), findsOneWidget);
  });

  testWidgets('deve criar sessão pelo formulário', (tester) async {
    await cubit.loadStudySessions();
    await tester.pumpStudySessionsPage(cubit, subject, topics);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '45');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Normalização').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Exercícios');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(repository.studySessions.length, 1);
    expect(repository.studySessions.first.durationInMinutes, 45);
    expect(repository.studySessions.first.topicId, 'topic-1');
    expect(repository.studySessions.first.notes, 'Exercícios');
    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('Exercícios'), findsOneWidget);
  });

  testWidgets('deve validar duração obrigatória no formulário', (tester) async {
    await cubit.loadStudySessions();
    await tester.pumpStudySessionsPage(cubit, subject, topics);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe uma duração maior que zero'), findsOneWidget);
    expect(repository.studySessions, isEmpty);
  });
}

extension on WidgetTester {
  Future<void> pumpStudySessionsPage(
    StudySessionsCubit cubit,
    Subject subject,
    List<Topic> topics,
  ) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: StudySessionsPage(subject: subject, topics: topics),
        ),
      ),
    );
  }
}

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> studySessions = [];

  @override
  Future<void> createStudySession(StudySession studySession) async {
    studySessions.add(studySession);
  }

  @override
  Future<void> deleteStudySession(String id) async {
    studySessions.removeWhere((studySession) => studySession.id == id);
  }

  @override
  Future<List<StudySession>> getStudySessions() async {
    return studySessions;
  }

  @override
  Future<List<StudySession>> getStudySessionsBySubject(String subjectId) async {
    return studySessions
        .where((studySession) => studySession.subjectId == subjectId)
        .toList();
  }
}
