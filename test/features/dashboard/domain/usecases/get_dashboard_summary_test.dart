import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/repositories/study_session_repository.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';

void main() {
  group('GetDashboardSummary', () {
    late FakeSubjectRepository subjectRepository;
    late FakeTopicRepository topicRepository;
    late FakeStudySessionRepository studySessionRepository;
    late GetDashboardSummary usecase;

    setUp(() {
      subjectRepository = FakeSubjectRepository();
      topicRepository = FakeTopicRepository();
      studySessionRepository = FakeStudySessionRepository();
      usecase = GetDashboardSummary(
        subjectRepository: subjectRepository,
        topicRepository: topicRepository,
        studySessionRepository: studySessionRepository,
        now: () => DateTime(2026, 6, 5, 10),
      );
    });

    test('should return zero values when there is no data', () async {
      // Arrange

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.totalSubjects, 0);
      expect(summary.totalTopics, 0);
      expect(summary.completedTopics, 0);
      expect(summary.studyingTopics, 0);
      expect(summary.pendingTopics, 0);
      expect(summary.totalStudyMinutesToday, 0);
      expect(summary.totalStudyMinutesThisWeek, 0);
      expect(summary.progressPercentage, 0);
      expect(summary.mostStudiedSubjectId, isNull);
      expect(summary.mostStudiedSubjectName, isNull);
      expect(summary.mostStudiedSubjectMinutes, 0);
    });

    test('should calculate the total subjects', () async {
      // Arrange
      subjectRepository.subjects.addAll([
        makeSubject(id: 'subject-1', name: 'Programming'),
        makeSubject(id: 'subject-2', name: 'Math'),
      ]);

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.totalSubjects, 2);
    });

    test('should calculate topic totals by subject', () async {
      // Arrange
      subjectRepository.subjects.addAll([
        makeSubject(id: 'subject-1', name: 'Programming'),
        makeSubject(id: 'subject-2', name: 'Math'),
      ]);
      topicRepository.topics.addAll([
        makeTopic(id: 'topic-1', subjectId: 'subject-1'),
        makeTopic(id: 'topic-2', subjectId: 'subject-1'),
        makeTopic(id: 'topic-3', subjectId: 'subject-2'),
        makeTopic(id: 'topic-4', subjectId: 'another-subject'),
      ]);

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.totalTopics, 3);
    });

    test('should calculate completed and studying topics', () async {
      // Arrange
      subjectRepository.subjects.add(makeSubject(id: 'subject-1'));
      topicRepository.topics.addAll([
        makeTopic(
          id: 'topic-1',
          subjectId: 'subject-1',
          status: TopicStatus.completed,
        ),
        makeTopic(
          id: 'topic-2',
          subjectId: 'subject-1',
          status: TopicStatus.completed,
        ),
        makeTopic(
          id: 'topic-3',
          subjectId: 'subject-1',
          status: TopicStatus.studying,
        ),
        makeTopic(id: 'topic-4', subjectId: 'subject-1'),
      ]);

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.completedTopics, 2);
      expect(summary.studyingTopics, 1);
      expect(summary.pendingTopics, 2);
    });

    test('should calculate overall progress', () async {
      // Arrange
      subjectRepository.subjects.add(makeSubject(id: 'subject-1'));
      topicRepository.topics.addAll([
        makeTopic(
          id: 'topic-1',
          subjectId: 'subject-1',
          status: TopicStatus.completed,
        ),
        makeTopic(
          id: 'topic-2',
          subjectId: 'subject-1',
          status: TopicStatus.completed,
        ),
        makeTopic(id: 'topic-3', subjectId: 'subject-1'),
        makeTopic(id: 'topic-4', subjectId: 'subject-1'),
      ]);

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.progressPercentage, 50);
    });

    test('should calculate study minutes from today', () async {
      // Arrange
      studySessionRepository.studySessions.addAll([
        makeStudySession(
          id: 'study-session-1',
          studiedAt: DateTime(2026, 6, 5, 8),
          durationInMinutes: 45,
        ),
        makeStudySession(
          id: 'study-session-2',
          studiedAt: DateTime(2026, 6, 5, 21),
          durationInMinutes: 30,
        ),
        makeStudySession(
          id: 'study-session-3',
          studiedAt: DateTime(2026, 6, 4, 10),
          durationInMinutes: 60,
        ),
      ]);

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.totalStudyMinutesToday, 75);
    });

    test('should calculate study minutes from this week', () async {
      // Arrange
      studySessionRepository.studySessions.addAll([
        makeStudySession(
          id: 'study-session-1',
          studiedAt: DateTime(2026, 6, 1, 8),
          durationInMinutes: 45,
        ),
        makeStudySession(
          id: 'study-session-2',
          studiedAt: DateTime(2026, 6, 5, 9),
          durationInMinutes: 60,
        ),
        makeStudySession(
          id: 'study-session-3',
          studiedAt: DateTime(2026, 6, 7, 20),
          durationInMinutes: 30,
        ),
        makeStudySession(
          id: 'study-session-4',
          studiedAt: DateTime(2026, 5, 31, 10),
          durationInMinutes: 90,
        ),
        makeStudySession(
          id: 'study-session-5',
          studiedAt: DateTime(2026, 6, 8, 10),
          durationInMinutes: 120,
        ),
      ]);

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.totalStudyMinutesThisWeek, 135);
    });

    test('should return the subject with more study minutes', () async {
      // Arrange
      subjectRepository.subjects.addAll([
        makeSubject(id: 'subject-1', name: 'Programming'),
        makeSubject(id: 'subject-2', name: 'Math'),
      ]);
      studySessionRepository.studySessions.addAll([
        makeStudySession(
          id: 'study-session-1',
          subjectId: 'subject-1',
          durationInMinutes: 45,
        ),
        makeStudySession(
          id: 'study-session-2',
          subjectId: 'subject-2',
          durationInMinutes: 60,
        ),
        makeStudySession(
          id: 'study-session-3',
          subjectId: 'subject-2',
          durationInMinutes: 90,
        ),
      ]);

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.mostStudiedSubjectId, 'subject-2');
      expect(summary.mostStudiedSubjectName, 'Math');
      expect(summary.mostStudiedSubjectMinutes, 150);
    });

    test('should calculate a full dashboard summary', () async {
      // Arrange
      subjectRepository.subjects.addAll([
        makeSubject(id: 'subject-1', name: 'Programming'),
        makeSubject(id: 'subject-2', name: 'Math'),
      ]);
      topicRepository.topics.addAll([
        makeTopic(
          id: 'topic-1',
          subjectId: 'subject-1',
          status: TopicStatus.completed,
        ),
        makeTopic(
          id: 'topic-2',
          subjectId: 'subject-1',
          status: TopicStatus.completed,
        ),
        makeTopic(
          id: 'topic-3',
          subjectId: 'subject-2',
          status: TopicStatus.studying,
        ),
        makeTopic(id: 'topic-4', subjectId: 'subject-2'),
      ]);
      studySessionRepository.studySessions.addAll([
        makeStudySession(
          id: 'study-session-1',
          subjectId: 'subject-1',
          studiedAt: DateTime(2026, 6, 5, 8),
          durationInMinutes: 45,
        ),
        makeStudySession(
          id: 'study-session-2',
          subjectId: 'subject-2',
          studiedAt: DateTime(2026, 6, 4, 9),
          durationInMinutes: 120,
        ),
        makeStudySession(
          id: 'study-session-3',
          subjectId: 'subject-2',
          studiedAt: DateTime(2026, 6, 1, 19),
          durationInMinutes: 80,
        ),
      ]);

      // Act
      final summary = await usecase();

      // Assert
      expect(summary.totalSubjects, 2);
      expect(summary.totalTopics, 4);
      expect(summary.completedTopics, 2);
      expect(summary.studyingTopics, 1);
      expect(summary.pendingTopics, 2);
      expect(summary.progressPercentage, 50);
      expect(summary.totalStudyMinutesToday, 45);
      expect(summary.totalStudyMinutesThisWeek, 245);
      expect(summary.mostStudiedSubjectId, 'subject-2');
      expect(summary.mostStudiedSubjectName, 'Math');
      expect(summary.mostStudiedSubjectMinutes, 200);
    });
  });
}

Subject makeSubject({required String id, String name = 'Programming'}) {
  return Subject(id: id, name: name, createdAt: DateTime(2026, 6));
}

Topic makeTopic({
  required String id,
  required String subjectId,
  TopicStatus status = TopicStatus.notStarted,
}) {
  return Topic(
    id: id,
    subjectId: subjectId,
    title: 'Use cases',
    status: status,
    priority: TopicPriority.medium,
    createdAt: DateTime(2026, 6),
  );
}

StudySession makeStudySession({
  required String id,
  String subjectId = 'subject-1',
  DateTime? studiedAt,
  int durationInMinutes = 45,
}) {
  return StudySession(
    id: id,
    subjectId: subjectId,
    topicId: 'topic-1',
    durationInMinutes: durationInMinutes,
    studiedAt: studiedAt ?? DateTime(2026, 6, 5),
    notes: 'Studied dashboard',
    createdAt: DateTime(2026, 6, 5, 10),
  );
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects = [];

  @override
  Future<void> createSubject(Subject subject) async {
    subjects.add(subject);
  }

  @override
  Future<void> deleteSubject(String id) async {
    subjects.removeWhere((subject) => subject.id == id);
  }

  @override
  Future<List<Subject>> getSubjects() async {
    return subjects;
  }
}

class FakeTopicRepository implements TopicRepository {
  final List<Topic> topics = [];

  @override
  Future<void> createTopic(Topic topic) async {
    topics.add(topic);
  }

  @override
  Future<void> deleteTopic(String id) async {
    topics.removeWhere((topic) => topic.id == id);
  }

  @override
  Future<List<Topic>> getTopicsBySubject(String subjectId) async {
    return topics.where((topic) => topic.subjectId == subjectId).toList();
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {}
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
}
