import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';

void main() {
  group('StudySession', () {
    final studiedAt = DateTime(2026, 6, 4);
    final createdAt = DateTime(2026, 6, 4, 10);
    final updatedAt = DateTime(2026, 6, 4, 11);

    test('should create a valid study session', () {
      // Arrange
      const notes = 'Studied domain, repositories and use cases.';

      // Act
      final studySession = StudySession(
        id: 'study-session-1',
        subjectId: 'subject-1',
        topicId: 'topic-1',
        durationInMinutes: 45,
        studiedAt: studiedAt,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(studySession, isA<StudySession>());
    });

    test('should keep the values passed to the constructor', () {
      // Arrange
      const notes = 'Reviewed architecture notes.';

      // Act
      final studySession = StudySession(
        id: 'study-session-1',
        subjectId: 'subject-1',
        topicId: 'topic-1',
        durationInMinutes: 45,
        studiedAt: studiedAt,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(studySession.id, 'study-session-1');
      expect(studySession.subjectId, 'subject-1');
      expect(studySession.topicId, 'topic-1');
      expect(studySession.durationInMinutes, 45);
      expect(studySession.studiedAt, studiedAt);
      expect(studySession.notes, notes);
      expect(studySession.createdAt, createdAt);
      expect(studySession.updatedAt, updatedAt);
    });

    test('should accept a null topicId', () {
      // Arrange
      final studySession = makeStudySession(topicId: null);

      // Act
      final topicId = studySession.topicId;

      // Assert
      expect(topicId, isNull);
    });

    test('should accept null notes and updatedAt', () {
      // Arrange
      final studySession = makeStudySession(notes: null, updatedAt: null);

      // Act
      final notes = studySession.notes;
      final updatedAt = studySession.updatedAt;

      // Assert
      expect(notes, isNull);
      expect(updatedAt, isNull);
    });

    test('should belong to a subject through subjectId', () {
      // Arrange
      const subjectId = 'subject-programming';
      final studySession = makeStudySession(subjectId: subjectId);

      // Act
      final studySessionSubjectId = studySession.subjectId;

      // Assert
      expect(studySessionSubjectId, subjectId);
    });

    test('should optionally belong to a topic through topicId', () {
      // Arrange
      const topicId = 'topic-flutter-architecture';
      final studySession = makeStudySession(topicId: topicId);

      // Act
      final studySessionTopicId = studySession.topicId;

      // Assert
      expect(studySessionTopicId, topicId);
    });

    test('should compare study sessions by value', () {
      // Arrange
      final firstStudySession = makeStudySession();
      final secondStudySession = makeStudySession();

      // Act
      final studySessionsAreEqual = firstStudySession == secondStudySession;

      // Assert
      expect(studySessionsAreEqual, isTrue);
    });
  });
}

StudySession makeStudySession({
  String id = 'study-session-1',
  String subjectId = 'subject-1',
  String? topicId = 'topic-1',
  int durationInMinutes = 45,
  DateTime? studiedAt,
  String? notes = 'Studied domain layer',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return StudySession(
    id: id,
    subjectId: subjectId,
    topicId: topicId,
    durationInMinutes: durationInMinutes,
    studiedAt: studiedAt ?? DateTime(2026, 6, 4),
    notes: notes,
    createdAt: createdAt ?? DateTime(2026, 6, 4, 10),
    updatedAt: updatedAt,
  );
}
