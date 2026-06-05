import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/repositories/study_session_repository.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/get_study_sessions.dart';

void main() {
  group('GetStudySessions', () {
    late FakeStudySessionRepository repository;
    late GetStudySessions usecase;

    setUp(() {
      repository = FakeStudySessionRepository();
      usecase = GetStudySessions(repository);
    });

    test('should return an empty list when there are no sessions', () async {
      // Arrange

      // Act
      final studySessions = await usecase();

      // Assert
      expect(studySessions, isEmpty);
    });

    test('should return all study sessions', () async {
      // Arrange
      final firstStudySession = makeStudySession(
        id: 'study-session-1',
        subjectId: 'subject-1',
      );
      final secondStudySession = makeStudySession(
        id: 'study-session-2',
        subjectId: 'subject-2',
      );
      repository.studySessions.addAll([firstStudySession, secondStudySession]);

      // Act
      final studySessions = await usecase();

      // Assert
      expect(studySessions, [firstStudySession, secondStudySession]);
    });

    test('should call the repository', () async {
      // Arrange

      // Act
      await usecase();

      // Assert
      expect(repository.getStudySessionsWasCalled, isTrue);
    });
  });
}

StudySession makeStudySession({required String id, required String subjectId}) {
  return StudySession(
    id: id,
    subjectId: subjectId,
    topicId: 'topic-1',
    durationInMinutes: 45,
    studiedAt: DateTime(2026, 6, 4),
    notes: 'Studied use cases',
    createdAt: DateTime(2026, 6, 4, 10),
  );
}

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> studySessions = [];
  bool getStudySessionsWasCalled = false;

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
    getStudySessionsWasCalled = true;
    return studySessions;
  }

  @override
  Future<List<StudySession>> getStudySessionsBySubject(String subjectId) async {
    return studySessions
        .where((studySession) => studySession.subjectId == subjectId)
        .toList();
  }
}
