import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/repositories/study_session_repository.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/create_study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/delete_study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/get_study_sessions_by_subject.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/update_study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/presentation/cubit/study_sessions_cubit.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/presentation/cubit/study_sessions_state.dart';

void main() {
  late FakeStudySessionRepository repository;
  late StudySessionsCubit cubit;
  final today = DateTime(2026, 7, 2, 9);

  setUp(() {
    repository = FakeStudySessionRepository();
    cubit = StudySessionsCubit(
      subjectId: 'subject-1',
      getStudySessionsBySubject: GetStudySessionsBySubject(repository),
      createStudySessionUseCase: CreateStudySession(repository),
      updateStudySessionUseCase: UpdateStudySession(repository),
      deleteStudySessionUseCase: DeleteStudySession(repository),
      generateStudySessionId: () => 'session-1',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('deve iniciar com estado initial e lista vazia', () {
    expect(cubit.state.status, StudySessionsStatus.initial);
    expect(cubit.state.studySessions, isEmpty);
  });

  test('deve carregar sessões da matéria', () async {
    final studySession = StudySession(
      id: 'session-1',
      subjectId: 'subject-1',
      durationInMinutes: 40,
      studiedAt: today,
      createdAt: today,
    );
    repository.studySessions.add(studySession);
    repository.studySessions.add(
      StudySession(
        id: 'session-2',
        subjectId: 'subject-2',
        durationInMinutes: 25,
        studiedAt: today,
        createdAt: today,
      ),
    );

    await cubit.loadStudySessions();

    expect(cubit.state.status, StudySessionsStatus.success);
    expect(cubit.state.studySessions, [studySession]);
  });

  test('deve criar uma sessão e recarregar a lista', () async {
    final created = await cubit.createStudySession(
      durationInMinutes: 50,
      topicId: ' topic-1 ',
      notes: ' Revisão prática ',
    );

    expect(created, isTrue);
    expect(repository.studySessions.length, 1);
    expect(repository.studySessions.first.id, 'session-1');
    expect(repository.studySessions.first.subjectId, 'subject-1');
    expect(repository.studySessions.first.topicId, 'topic-1');
    expect(repository.studySessions.first.durationInMinutes, 50);
    expect(repository.studySessions.first.notes, 'Revisão prática');
    expect(repository.studySessions.first.studiedAt, today);
    expect(repository.studySessions.first.createdAt, today);
    expect(cubit.state.status, StudySessionsStatus.success);
  });

  test('deve rejeitar duração menor ou igual a zero', () async {
    final created = await cubit.createStudySession(durationInMinutes: 0);

    expect(created, isFalse);
    expect(repository.studySessions, isEmpty);
    expect(cubit.state.status, StudySessionsStatus.failure);
    expect(cubit.state.errorMessage, 'Informe uma duração maior que zero.');
  });

  test('deve editar uma sessão preservando id, matéria e criação', () async {
    final studySession = StudySession(
      id: 'session-1',
      subjectId: 'subject-1',
      topicId: 'topic-1',
      durationInMinutes: 30,
      studiedAt: DateTime(2026, 7, 1),
      notes: 'Notas antigas',
      createdAt: DateTime(2026, 6, 30, 10),
    );
    repository.studySessions.add(studySession);
    final updatedStudiedAt = DateTime(2026, 7, 2, 8);

    final updated = await cubit.updateStudySession(
      studySession: studySession,
      durationInMinutes: 75,
      topicId: '   ',
      studiedAt: updatedStudiedAt,
      notes: ' Novas notas ',
    );

    final savedSession = repository.studySessions.single;
    expect(updated, isTrue);
    expect(savedSession.id, studySession.id);
    expect(savedSession.subjectId, studySession.subjectId);
    expect(savedSession.topicId, isNull);
    expect(savedSession.durationInMinutes, 75);
    expect(savedSession.studiedAt, updatedStudiedAt);
    expect(savedSession.notes, 'Novas notas');
    expect(savedSession.createdAt, studySession.createdAt);
    expect(savedSession.updatedAt, today);
    expect(cubit.state.status, StudySessionsStatus.success);
  });

  test('deve rejeitar edição com duração menor ou igual a zero', () async {
    final studySession = StudySession(
      id: 'session-1',
      subjectId: 'subject-1',
      durationInMinutes: 30,
      studiedAt: today,
      createdAt: today,
    );
    repository.studySessions.add(studySession);

    final updated = await cubit.updateStudySession(
      studySession: studySession,
      durationInMinutes: 0,
      studiedAt: studySession.studiedAt,
    );

    expect(updated, isFalse);
    expect(repository.studySessions.single, studySession);
    expect(cubit.state.errorMessage, 'Informe uma duração maior que zero.');
  });

  test('deve excluir uma sessão e recarregar a lista', () async {
    repository.studySessions.add(
      StudySession(
        id: 'session-1',
        subjectId: 'subject-1',
        durationInMinutes: 30,
        studiedAt: today,
        createdAt: today,
      ),
    );

    await cubit.deleteStudySession('session-1');

    expect(repository.studySessions, isEmpty);
    expect(cubit.state.status, StudySessionsStatus.success);
    expect(cubit.state.studySessions, isEmpty);
  });
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

  @override
  Future<void> updateStudySession(StudySession studySession) async {
    final index = studySessions.indexWhere(
      (item) => item.id == studySession.id,
    );
    studySessions[index] = studySession;
  }
}
