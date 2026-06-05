import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/errors/study_session_exceptions.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/repositories/study_session_repository.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/delete_study_session.dart';

void main() {
  group('DeleteStudySession', () {
    late FakeStudySessionRepository repository;
    late DeleteStudySession usecase;

    setUp(() {
      repository = FakeStudySessionRepository();
      usecase = DeleteStudySession(repository);
    });

    test('should delete a study session by id', () async {
      // Arrange
      final studySession = makeStudySession(id: 'study-session-1');
      repository.studySessions.add(studySession);

      // Act
      await usecase(studySession.id);

      // Assert
      expect(repository.studySessions, isEmpty);
    });

    test('should call the repository with the correct id', () async {
      // Arrange
      const studySessionId = 'study-session-1';

      // Act
      await usecase(studySessionId);

      // Assert
      expect(repository.deleteStudySessionWasCalled, isTrue);
      expect(repository.deletedId, studySessionId);
    });

    test('should throw an error when the id is empty', () async {
      // Arrange

      // Act
      Future<void> action() => usecase('');

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyStudySessionIdException>().having(
            (error) => error.message,
            'message',
            'Study session id is required.',
          ),
        ),
      );
    });

    test('should throw an error when the id has only spaces', () async {
      // Arrange

      // Act
      Future<void> action() => usecase('   ');

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyStudySessionIdException>().having(
            (error) => error.message,
            'message',
            'Study session id is required.',
          ),
        ),
      );
    });
  });
}

StudySession makeStudySession({required String id}) {
  return StudySession(
    id: id,
    subjectId: 'subject-1',
    topicId: 'topic-1',
    durationInMinutes: 45,
    studiedAt: DateTime(2026, 6, 4),
    notes: 'Studied domain',
    createdAt: DateTime(2026, 6, 4, 10),
  );
}

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> studySessions = [];
  bool deleteStudySessionWasCalled = false;
  String? deletedId;

  @override
  Future<void> createStudySession(StudySession studySession) async {
    studySessions.add(studySession);
  }

  @override
  Future<void> deleteStudySession(String id) async {
    deleteStudySessionWasCalled = true;
    deletedId = id;
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
