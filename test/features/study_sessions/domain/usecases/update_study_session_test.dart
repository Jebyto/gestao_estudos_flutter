import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/errors/study_session_exceptions.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/repositories/study_session_repository.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/update_study_session.dart';

void main() {
  group('UpdateStudySession', () {
    late FakeStudySessionRepository repository;
    late UpdateStudySession usecase;

    setUp(() {
      repository = FakeStudySessionRepository();
      usecase = UpdateStudySession(repository);
    });

    test('should update a valid study session', () async {
      final studySession = makeStudySession();

      await usecase(studySession);

      expect(repository.updatedStudySession, studySession);
    });

    test('should throw an error when the id is empty', () async {
      Future<void> action() => usecase(makeStudySession(id: ''));

      expect(action, throwsA(isA<EmptyStudySessionIdException>()));
    });

    test('should throw an error when the subject id is empty', () async {
      Future<void> action() => usecase(makeStudySession(subjectId: '   '));

      expect(action, throwsA(isA<EmptyStudySessionSubjectIdException>()));
    });

    test('should throw an error when duration is not positive', () async {
      Future<void> action() => usecase(makeStudySession(durationInMinutes: 0));

      expect(action, throwsA(isA<InvalidStudySessionDurationException>()));
    });
  });
}

StudySession makeStudySession({
  String id = 'session-1',
  String subjectId = 'subject-1',
  int durationInMinutes = 45,
}) {
  return StudySession(
    id: id,
    subjectId: subjectId,
    durationInMinutes: durationInMinutes,
    studiedAt: DateTime(2026, 7, 2),
    createdAt: DateTime(2026, 7, 2, 10),
  );
}

class FakeStudySessionRepository implements StudySessionRepository {
  StudySession? updatedStudySession;

  @override
  Future<void> updateStudySession(StudySession studySession) async {
    updatedStudySession = studySession;
  }

  @override
  Future<void> createStudySession(StudySession studySession) async {}

  @override
  Future<void> deleteStudySession(String id) async {}

  @override
  Future<List<StudySession>> getStudySessions() async => [];

  @override
  Future<List<StudySession>> getStudySessionsBySubject(String subjectId) async {
    return [];
  }
}
