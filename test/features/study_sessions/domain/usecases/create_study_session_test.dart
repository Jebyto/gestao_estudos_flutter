import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/errors/study_session_exceptions.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/repositories/study_session_repository.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/create_study_session.dart';

void main() {
  group('CreateStudySession', () {
    late FakeStudySessionRepository repository;
    late CreateStudySession usecase;

    setUp(() {
      repository = FakeStudySessionRepository();
      usecase = CreateStudySession(repository);
    });

    test('should create a valid study session', () async {
      // Arrange
      final studySession = makeStudySession();

      // Act
      await usecase(studySession);

      // Assert
      expect(repository.studySessions, contains(studySession));
    });

    test('should call the repository', () async {
      // Arrange
      final studySession = makeStudySession(notes: 'Studied Flutter widgets');

      // Act
      await usecase(studySession);

      // Assert
      expect(repository.createStudySessionWasCalled, isTrue);
      expect(repository.createdStudySession, studySession);
    });

    test('should throw an error when subjectId is empty', () async {
      // Arrange
      final studySession = makeStudySession(subjectId: '');

      // Act
      Future<void> action() => usecase(studySession);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyStudySessionSubjectIdException>().having(
            (error) => error.message,
            'message',
            'Subject id is required.',
          ),
        ),
      );
    });

    test('should throw an error when subjectId has only spaces', () async {
      // Arrange
      final studySession = makeStudySession(subjectId: '   ');

      // Act
      Future<void> action() => usecase(studySession);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyStudySessionSubjectIdException>().having(
            (error) => error.message,
            'message',
            'Subject id is required.',
          ),
        ),
      );
    });

    test('should throw an error when duration is zero', () async {
      // Arrange
      final studySession = makeStudySession(durationInMinutes: 0);

      // Act
      Future<void> action() => usecase(studySession);

      // Assert
      expect(
        action,
        throwsA(
          isA<InvalidStudySessionDurationException>().having(
            (error) => error.message,
            'message',
            'Study session duration must be greater than zero.',
          ),
        ),
      );
    });

    test('should throw an error when duration is negative', () async {
      // Arrange
      final studySession = makeStudySession(durationInMinutes: -15);

      // Act
      Future<void> action() => usecase(studySession);

      // Assert
      expect(
        action,
        throwsA(
          isA<InvalidStudySessionDurationException>().having(
            (error) => error.message,
            'message',
            'Study session duration must be greater than zero.',
          ),
        ),
      );
    });
  });
}

StudySession makeStudySession({
  String id = 'study-session-1',
  String subjectId = 'subject-1',
  String? topicId = 'topic-1',
  int durationInMinutes = 45,
  String? notes = 'Studied repositories',
}) {
  return StudySession(
    id: id,
    subjectId: subjectId,
    topicId: topicId,
    durationInMinutes: durationInMinutes,
    studiedAt: DateTime(2026, 6, 4),
    notes: notes,
    createdAt: DateTime(2026, 6, 4, 10),
  );
}

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> studySessions = [];
  bool createStudySessionWasCalled = false;
  StudySession? createdStudySession;

  @override
  Future<void> createStudySession(StudySession studySession) async {
    createStudySessionWasCalled = true;
    createdStudySession = studySession;
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
