import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/data/datasources/study_session_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/data/models/study_session_model.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/datasources/subject_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/models/subject_model.dart';
import 'package:gestao_estudos_flutter/features/topics/data/datasources/topic_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/topics/data/models/topic_model.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('StudySessionLocalDataSourceImpl', () {
    late AppDatabase appDatabase;
    late SubjectLocalDataSourceImpl subjectDataSource;
    late TopicLocalDataSourceImpl topicDataSource;
    late StudySessionLocalDataSourceImpl studySessionDataSource;

    setUp(() {
      sqfliteFfiInit();
      appDatabase = AppDatabase(
        databasePath: inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        singleInstance: false,
      );
      subjectDataSource = SubjectLocalDataSourceImpl(appDatabase);
      topicDataSource = TopicLocalDataSourceImpl(appDatabase);
      studySessionDataSource = StudySessionLocalDataSourceImpl(appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('should save and get study sessions from SQLite', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      final studySession = makeStudySession(
        id: 'study-session-1',
        subjectId: 'subject-1',
      );

      // Act
      await studySessionDataSource.createStudySession(studySession);
      final studySessions = await studySessionDataSource.getStudySessions();

      // Assert
      expect(studySessions.length, 1);
      expect(studySessions.first.id, 'study-session-1');
      expect(studySessions.first.subjectId, 'subject-1');
      expect(studySessions.first.topicId, isNull);
      expect(studySessions.first.durationInMinutes, 45);
    });

    test('should save a study session with a topic', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await topicDataSource.createTopic(
        makeTopic(id: 'topic-1', subjectId: 'subject-1'),
      );
      final studySession = makeStudySession(
        id: 'study-session-1',
        subjectId: 'subject-1',
        topicId: 'topic-1',
      );

      // Act
      await studySessionDataSource.createStudySession(studySession);
      final studySessions = await studySessionDataSource.getStudySessions();

      // Assert
      expect(studySessions.first.topicId, 'topic-1');
    });

    test('should return study sessions by subject', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await subjectDataSource.createSubject(makeSubject(id: 'subject-2'));
      await studySessionDataSource.createStudySession(
        makeStudySession(id: 'study-session-1', subjectId: 'subject-1'),
      );
      await studySessionDataSource.createStudySession(
        makeStudySession(id: 'study-session-2', subjectId: 'subject-2'),
      );

      // Act
      final studySessions = await studySessionDataSource
          .getStudySessionsBySubject('subject-1');

      // Assert
      expect(studySessions.length, 1);
      expect(studySessions.first.id, 'study-session-1');
    });

    test('should order study sessions by studiedAt descending', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await studySessionDataSource.createStudySession(
        makeStudySession(
          id: 'study-session-1',
          subjectId: 'subject-1',
          studiedAt: DateTime(2026, 6, 18),
        ),
      );
      await studySessionDataSource.createStudySession(
        makeStudySession(
          id: 'study-session-2',
          subjectId: 'subject-1',
          studiedAt: DateTime(2026, 6, 19),
        ),
      );

      // Act
      final studySessions = await studySessionDataSource.getStudySessions();

      // Assert
      expect(studySessions.map((studySession) => studySession.id), [
        'study-session-2',
        'study-session-1',
      ]);
    });

    test('should update a study session in SQLite', () async {
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await topicDataSource.createTopic(
        makeTopic(id: 'topic-1', subjectId: 'subject-1'),
      );
      final original = makeStudySession(
        id: 'study-session-1',
        subjectId: 'subject-1',
        topicId: 'topic-1',
      );
      await studySessionDataSource.createStudySession(original);
      final updated = StudySessionModel(
        id: original.id,
        subjectId: original.subjectId,
        durationInMinutes: 90,
        studiedAt: DateTime(2026, 6, 20),
        notes: 'Updated notes',
        createdAt: original.createdAt,
        updatedAt: DateTime(2026, 6, 21),
      );

      await studySessionDataSource.updateStudySession(updated);
      final studySessions = await studySessionDataSource.getStudySessions();

      expect(studySessions.single.id, original.id);
      expect(studySessions.single.subjectId, original.subjectId);
      expect(studySessions.single.topicId, isNull);
      expect(studySessions.single.durationInMinutes, 90);
      expect(studySessions.single.studiedAt, DateTime(2026, 6, 20));
      expect(studySessions.single.notes, 'Updated notes');
      expect(studySessions.single.createdAt, original.createdAt);
      expect(studySessions.single.updatedAt, DateTime(2026, 6, 21));
    });

    test('should reject update when the topic does not exist', () async {
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      final original = makeStudySession(
        id: 'study-session-1',
        subjectId: 'subject-1',
      );
      await studySessionDataSource.createStudySession(original);
      final updated = StudySessionModel(
        id: original.id,
        subjectId: original.subjectId,
        topicId: 'missing-topic',
        durationInMinutes: original.durationInMinutes,
        studiedAt: original.studiedAt,
        createdAt: original.createdAt,
        updatedAt: DateTime(2026, 6, 21),
      );

      Future<void> action() =>
          studySessionDataSource.updateStudySession(updated);

      expect(action, throwsA(isA<DatabaseException>()));
    });

    test('should delete a study session from SQLite', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await studySessionDataSource.createStudySession(
        makeStudySession(id: 'study-session-1', subjectId: 'subject-1'),
      );

      // Act
      await studySessionDataSource.deleteStudySession('study-session-1');
      final studySessions = await studySessionDataSource.getStudySessions();

      // Assert
      expect(studySessions, isEmpty);
    });

    test(
      'should reject a study session when the subject does not exist',
      () async {
        // Arrange
        final studySession = makeStudySession(
          id: 'study-session-1',
          subjectId: 'missing-subject',
        );

        // Act
        Future<void> action() =>
            studySessionDataSource.createStudySession(studySession);

        // Assert
        expect(action, throwsA(isA<DatabaseException>()));
      },
    );

    test(
      'should reject a study session when the topic does not exist',
      () async {
        // Arrange
        await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
        final studySession = makeStudySession(
          id: 'study-session-1',
          subjectId: 'subject-1',
          topicId: 'missing-topic',
        );

        // Act
        Future<void> action() =>
            studySessionDataSource.createStudySession(studySession);

        // Assert
        expect(action, throwsA(isA<DatabaseException>()));
      },
    );

    test('should set topicId to null when the topic is deleted', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await topicDataSource.createTopic(
        makeTopic(id: 'topic-1', subjectId: 'subject-1'),
      );
      await studySessionDataSource.createStudySession(
        makeStudySession(
          id: 'study-session-1',
          subjectId: 'subject-1',
          topicId: 'topic-1',
        ),
      );

      // Act
      await topicDataSource.deleteTopic('topic-1');
      final studySessions = await studySessionDataSource.getStudySessions();

      // Assert
      expect(studySessions.first.topicId, isNull);
    });

    test(
      'should delete subject study sessions when the subject is deleted',
      () async {
        // Arrange
        await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
        await studySessionDataSource.createStudySession(
          makeStudySession(id: 'study-session-1', subjectId: 'subject-1'),
        );

        // Act
        await subjectDataSource.deleteSubject('subject-1');
        final studySessions = await studySessionDataSource.getStudySessions();

        // Assert
        expect(studySessions, isEmpty);
      },
    );
  });
}

SubjectModel makeSubject({required String id}) {
  return SubjectModel(id: id, name: 'Math', createdAt: DateTime(2026, 6, 19));
}

TopicModel makeTopic({required String id, required String subjectId}) {
  return TopicModel(
    id: id,
    subjectId: subjectId,
    title: 'Functions',
    status: TopicStatus.notStarted,
    priority: TopicPriority.medium,
    createdAt: DateTime(2026, 6, 19),
  );
}

StudySessionModel makeStudySession({
  required String id,
  required String subjectId,
  String? topicId,
  DateTime? studiedAt,
}) {
  return StudySessionModel(
    id: id,
    subjectId: subjectId,
    topicId: topicId,
    durationInMinutes: 45,
    studiedAt: studiedAt ?? DateTime(2026, 6, 19),
    notes: 'Studied data layer',
    createdAt: DateTime(2026, 6, 19, 10),
  );
}
