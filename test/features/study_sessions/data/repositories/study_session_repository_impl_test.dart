import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/data/datasources/study_session_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/data/models/study_session_model.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/data/repositories/study_session_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';

void main() {
  group('StudySessionRepositoryImpl', () {
    late FakeStudySessionLocalDataSource localDataSource;
    late StudySessionRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeStudySessionLocalDataSource();
      repository = StudySessionRepositoryImpl(localDataSource);
    });

    test('should create a study session using the local datasource', () async {
      // Arrange
      final studySession = makeStudySession(id: 'study-session-1');

      // Act
      await repository.createStudySession(studySession);

      // Assert
      expect(localDataSource.createStudySessionWasCalled, isTrue);
      expect(localDataSource.studySessions.length, 1);
      expect(localDataSource.studySessions.first.id, studySession.id);
      expect(
        localDataSource.studySessions.first.durationInMinutes,
        studySession.durationInMinutes,
      );
    });

    test('should return study sessions as domain entities', () async {
      // Arrange
      localDataSource.studySessions.add(
        makeStudySessionModel(id: 'study-session-1', subjectId: 'subject-1'),
      );

      // Act
      final studySessions = await repository.getStudySessions();

      // Assert
      expect(localDataSource.getStudySessionsWasCalled, isTrue);
      expect(studySessions.length, 1);
      expect(studySessions.first, isA<StudySession>());
      expect(studySessions.first.id, 'study-session-1');
    });

    test(
      'should return study sessions by subject as domain entities',
      () async {
        // Arrange
        localDataSource.studySessions.addAll([
          makeStudySessionModel(id: 'study-session-1', subjectId: 'subject-1'),
          makeStudySessionModel(id: 'study-session-2', subjectId: 'subject-2'),
        ]);

        // Act
        final studySessions = await repository.getStudySessionsBySubject(
          'subject-1',
        );

        // Assert
        expect(localDataSource.getStudySessionsBySubjectWasCalled, isTrue);
        expect(localDataSource.receivedSubjectId, 'subject-1');
        expect(studySessions.length, 1);
        expect(studySessions.first.subjectId, 'subject-1');
      },
    );

    test('should delete a study session using the local datasource', () async {
      // Arrange
      localDataSource.studySessions.add(
        makeStudySessionModel(id: 'study-session-1', subjectId: 'subject-1'),
      );

      // Act
      await repository.deleteStudySession('study-session-1');

      // Assert
      expect(localDataSource.deleteStudySessionWasCalled, isTrue);
      expect(localDataSource.deletedStudySessionId, 'study-session-1');
      expect(localDataSource.studySessions, isEmpty);
    });
  });
}

StudySession makeStudySession({required String id}) {
  return StudySession(
    id: id,
    subjectId: 'subject-1',
    topicId: 'topic-1',
    durationInMinutes: 45,
    studiedAt: DateTime(2026, 6, 19),
    createdAt: DateTime(2026, 6, 19, 10),
  );
}

StudySessionModel makeStudySessionModel({
  required String id,
  required String subjectId,
}) {
  return StudySessionModel(
    id: id,
    subjectId: subjectId,
    topicId: 'topic-1',
    durationInMinutes: 45,
    studiedAt: DateTime(2026, 6, 19),
    createdAt: DateTime(2026, 6, 19, 10),
  );
}

class FakeStudySessionLocalDataSource implements StudySessionLocalDataSource {
  final List<StudySessionModel> studySessions = [];
  bool createStudySessionWasCalled = false;
  bool getStudySessionsWasCalled = false;
  bool getStudySessionsBySubjectWasCalled = false;
  bool deleteStudySessionWasCalled = false;
  String? receivedSubjectId;
  String? deletedStudySessionId;

  @override
  Future<void> createStudySession(StudySessionModel studySession) async {
    createStudySessionWasCalled = true;
    studySessions.add(studySession);
  }

  @override
  Future<void> deleteStudySession(String id) async {
    deleteStudySessionWasCalled = true;
    deletedStudySessionId = id;
    studySessions.removeWhere((studySession) => studySession.id == id);
  }

  @override
  Future<List<StudySessionModel>> getStudySessions() async {
    getStudySessionsWasCalled = true;
    return studySessions;
  }

  @override
  Future<List<StudySessionModel>> getStudySessionsBySubject(
    String subjectId,
  ) async {
    getStudySessionsBySubjectWasCalled = true;
    receivedSubjectId = subjectId;

    return studySessions
        .where((studySession) => studySession.subjectId == subjectId)
        .toList();
  }
}
