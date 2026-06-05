import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/errors/study_session_exceptions.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/repositories/study_session_repository.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/get_study_sessions_by_subject.dart';

void main() {
  group('GetStudySessionsBySubject', () {
    late FakeStudySessionRepository repository;
    late GetStudySessionsBySubject usecase;

    setUp(() {
      repository = FakeStudySessionRepository();
      usecase = GetStudySessionsBySubject(repository);
    });

    test(
      'should return an empty list when the subject has no sessions',
      () async {
        // Arrange
        const subjectId = 'subject-1';

        // Act
        final studySessions = await usecase(subjectId);

        // Assert
        expect(studySessions, isEmpty);
      },
    );

    test('should return the study sessions from a subject', () async {
      // Arrange
      const subjectId = 'subject-1';
      final firstStudySession = makeStudySession(
        id: 'study-session-1',
        subjectId: subjectId,
      );
      final secondStudySession = makeStudySession(
        id: 'study-session-2',
        subjectId: subjectId,
      );
      final anotherSubjectStudySession = makeStudySession(
        id: 'study-session-3',
        subjectId: 'subject-2',
      );
      repository.studySessions.addAll([
        firstStudySession,
        secondStudySession,
        anotherSubjectStudySession,
      ]);

      // Act
      final studySessions = await usecase(subjectId);

      // Assert
      expect(studySessions, [firstStudySession, secondStudySession]);
    });

    test('should call the repository with the correct subjectId', () async {
      // Arrange
      const subjectId = 'subject-1';

      // Act
      await usecase(subjectId);

      // Assert
      expect(repository.getStudySessionsBySubjectWasCalled, isTrue);
      expect(repository.requestedSubjectId, subjectId);
    });

    test('should throw an error when subjectId is empty', () async {
      // Arrange

      // Act
      Future<List<StudySession>> action() => usecase('');

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

      // Act
      Future<List<StudySession>> action() => usecase('   ');

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
  });
}

StudySession makeStudySession({required String id, required String subjectId}) {
  return StudySession(
    id: id,
    subjectId: subjectId,
    topicId: 'topic-1',
    durationInMinutes: 45,
    studiedAt: DateTime(2026, 6, 4),
    notes: 'Studied architecture',
    createdAt: DateTime(2026, 6, 4, 10),
  );
}

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> studySessions = [];
  bool getStudySessionsBySubjectWasCalled = false;
  String? requestedSubjectId;

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
    getStudySessionsBySubjectWasCalled = true;
    requestedSubjectId = subjectId;
    return studySessions
        .where((studySession) => studySession.subjectId == subjectId)
        .toList();
  }
}
