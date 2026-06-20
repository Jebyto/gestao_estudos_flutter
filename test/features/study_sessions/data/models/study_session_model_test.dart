import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/data/models/study_session_model.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';

void main() {
  group('StudySessionModel', () {
    test('should create a model from a domain entity', () {
      // Arrange
      final studySession = makeStudySession();

      // Act
      final model = StudySessionModel.fromEntity(studySession);

      // Assert
      expect(model.id, studySession.id);
      expect(model.subjectId, studySession.subjectId);
      expect(model.topicId, studySession.topicId);
      expect(model.durationInMinutes, studySession.durationInMinutes);
      expect(model.studiedAt, studySession.studiedAt);
      expect(model.notes, studySession.notes);
      expect(model.createdAt, studySession.createdAt);
      expect(model.updatedAt, studySession.updatedAt);
    });

    test('should convert a model to a domain entity', () {
      // Arrange
      final model = makeStudySessionModel();

      // Act
      final studySession = model.toEntity();

      // Assert
      expect(studySession, isA<StudySession>());
      expect(studySession.id, model.id);
      expect(studySession.subjectId, model.subjectId);
      expect(studySession.topicId, model.topicId);
      expect(studySession.durationInMinutes, model.durationInMinutes);
      expect(studySession.studiedAt, model.studiedAt);
      expect(studySession.notes, model.notes);
      expect(studySession.createdAt, model.createdAt);
      expect(studySession.updatedAt, model.updatedAt);
    });

    test('should convert a model to map', () {
      // Arrange
      final model = makeStudySessionModel();

      // Act
      final map = model.toMap();

      // Assert
      expect(map['id'], 'study-session-1');
      expect(map['subject_id'], 'subject-1');
      expect(map['topic_id'], 'topic-1');
      expect(map['duration_in_minutes'], 45);
      expect(map['studied_at'], DateTime(2026, 6, 19, 9).toIso8601String());
      expect(map['notes'], 'Studied functions');
      expect(map['created_at'], DateTime(2026, 6, 19, 10).toIso8601String());
      expect(map['updated_at'], DateTime(2026, 6, 19, 11).toIso8601String());
    });

    test('should convert a map to model', () {
      // Arrange
      final map = {
        'id': 'study-session-1',
        'subject_id': 'subject-1',
        'topic_id': null,
        'duration_in_minutes': 45,
        'studied_at': DateTime(2026, 6, 19, 9).toIso8601String(),
        'notes': null,
        'created_at': DateTime(2026, 6, 19, 10).toIso8601String(),
        'updated_at': null,
      };

      // Act
      final model = StudySessionModel.fromMap(map);

      // Assert
      expect(model.id, 'study-session-1');
      expect(model.subjectId, 'subject-1');
      expect(model.topicId, isNull);
      expect(model.durationInMinutes, 45);
      expect(model.studiedAt, DateTime(2026, 6, 19, 9));
      expect(model.notes, isNull);
      expect(model.createdAt, DateTime(2026, 6, 19, 10));
      expect(model.updatedAt, isNull);
    });
  });
}

StudySession makeStudySession() {
  return StudySession(
    id: 'study-session-1',
    subjectId: 'subject-1',
    topicId: 'topic-1',
    durationInMinutes: 45,
    studiedAt: DateTime(2026, 6, 19, 9),
    notes: 'Studied functions',
    createdAt: DateTime(2026, 6, 19, 10),
    updatedAt: DateTime(2026, 6, 19, 11),
  );
}

StudySessionModel makeStudySessionModel() {
  return StudySessionModel(
    id: 'study-session-1',
    subjectId: 'subject-1',
    topicId: 'topic-1',
    durationInMinutes: 45,
    studiedAt: DateTime(2026, 6, 19, 9),
    notes: 'Studied functions',
    createdAt: DateTime(2026, 6, 19, 10),
    updatedAt: DateTime(2026, 6, 19, 11),
  );
}
