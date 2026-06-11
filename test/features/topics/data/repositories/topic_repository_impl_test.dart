import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/data/datasources/topic_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/topics/data/models/topic_model.dart';
import 'package:gestao_estudos_flutter/features/topics/data/repositories/topic_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';

void main() {
  group('TopicRepositoryImpl', () {
    late FakeTopicLocalDataSource localDataSource;
    late TopicRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeTopicLocalDataSource();
      repository = TopicRepositoryImpl(localDataSource);
    });

    test('should create a topic using the local datasource', () async {
      // Arrange
      final topic = makeTopic(id: 'topic-1', title: 'Functions');

      // Act
      await repository.createTopic(topic);

      // Assert
      expect(localDataSource.createTopicWasCalled, isTrue);
      expect(localDataSource.topics.length, 1);
      expect(localDataSource.topics.first.id, topic.id);
      expect(localDataSource.topics.first.title, topic.title);
    });

    test('should return topics as domain entities', () async {
      // Arrange
      localDataSource.topics.add(
        makeTopicModel(
          id: 'topic-1',
          subjectId: 'subject-1',
          title: 'Functions',
        ),
      );

      // Act
      final topics = await repository.getTopicsBySubject('subject-1');

      // Assert
      expect(localDataSource.getTopicsBySubjectWasCalled, isTrue);
      expect(localDataSource.receivedSubjectId, 'subject-1');
      expect(topics.length, 1);
      expect(topics.first, isA<Topic>());
      expect(topics.first.title, 'Functions');
    });

    test('should update topic status using the local datasource', () async {
      // Arrange
      localDataSource.topics.add(
        makeTopicModel(
          id: 'topic-1',
          subjectId: 'subject-1',
          title: 'Functions',
        ),
      );

      // Act
      await repository.updateTopicStatus('topic-1', TopicStatus.completed);

      // Assert
      expect(localDataSource.updateTopicStatusWasCalled, isTrue);
      expect(localDataSource.receivedTopicId, 'topic-1');
      expect(localDataSource.receivedStatus, TopicStatus.completed);
      expect(localDataSource.topics.first.status, TopicStatus.completed);
    });

    test('should delete a topic using the local datasource', () async {
      // Arrange
      localDataSource.topics.add(
        makeTopicModel(
          id: 'topic-1',
          subjectId: 'subject-1',
          title: 'Functions',
        ),
      );

      // Act
      await repository.deleteTopic('topic-1');

      // Assert
      expect(localDataSource.deleteTopicWasCalled, isTrue);
      expect(localDataSource.deletedTopicId, 'topic-1');
      expect(localDataSource.topics, isEmpty);
    });
  });
}

Topic makeTopic({required String id, required String title}) {
  return Topic(
    id: id,
    subjectId: 'subject-1',
    title: title,
    status: TopicStatus.notStarted,
    priority: TopicPriority.medium,
    createdAt: DateTime(2026, 6, 8),
  );
}

TopicModel makeTopicModel({
  required String id,
  required String subjectId,
  required String title,
  TopicStatus status = TopicStatus.notStarted,
}) {
  return TopicModel(
    id: id,
    subjectId: subjectId,
    title: title,
    status: status,
    priority: TopicPriority.medium,
    createdAt: DateTime(2026, 6, 8),
  );
}

class FakeTopicLocalDataSource implements TopicLocalDataSource {
  final List<TopicModel> topics = [];
  bool createTopicWasCalled = false;
  bool getTopicsBySubjectWasCalled = false;
  bool updateTopicStatusWasCalled = false;
  bool deleteTopicWasCalled = false;
  String? receivedSubjectId;
  String? receivedTopicId;
  TopicStatus? receivedStatus;
  String? deletedTopicId;

  @override
  Future<void> createTopic(TopicModel topic) async {
    createTopicWasCalled = true;
    topics.add(topic);
  }

  @override
  Future<void> deleteTopic(String id) async {
    deleteTopicWasCalled = true;
    deletedTopicId = id;
    topics.removeWhere((topic) => topic.id == id);
  }

  @override
  Future<List<TopicModel>> getTopicsBySubject(String subjectId) async {
    getTopicsBySubjectWasCalled = true;
    receivedSubjectId = subjectId;
    return topics.where((topic) => topic.subjectId == subjectId).toList();
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    updateTopicStatusWasCalled = true;
    receivedTopicId = topicId;
    receivedStatus = status;

    final topicIndex = topics.indexWhere((topic) => topic.id == topicId);

    if (topicIndex >= 0) {
      final topic = topics[topicIndex];
      topics[topicIndex] = TopicModel(
        id: topic.id,
        subjectId: topic.subjectId,
        title: topic.title,
        description: topic.description,
        status: status,
        priority: topic.priority,
        createdAt: topic.createdAt,
        updatedAt: topic.updatedAt,
        completedAt: topic.completedAt,
        nextReviewAt: topic.nextReviewAt,
      );
    }
  }
}
