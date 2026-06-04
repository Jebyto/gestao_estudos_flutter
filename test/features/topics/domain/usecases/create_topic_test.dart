import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/errors/topic_exceptions.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/create_topic.dart';

void main() {
  group('CreateTopic', () {
    late FakeTopicRepository repository;
    late CreateTopic usecase;

    setUp(() {
      repository = FakeTopicRepository();
      usecase = CreateTopic(repository);
    });

    test('should create a valid topic', () async {
      // Arrange
      final topic = makeTopic(title: 'Relative pronoun');

      // Act
      await usecase(topic);

      // Assert
      expect(repository.topics, contains(topic));
    });

    test('should call the repository', () async {
      // Arrange
      final topic = makeTopic(title: 'Subordinate clauses');

      // Act
      await usecase(topic);

      // Assert
      expect(repository.createTopicWasCalled, isTrue);
      expect(repository.createdTopic, topic);
    });

    test('should throw an error when subjectId is empty', () async {
      // Arrange
      final topic = makeTopic(subjectId: '');

      // Act
      Future<void> action() => usecase(topic);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyTopicSubjectIdException>().having(
            (error) => error.message,
            'message',
            'Subject id is required.',
          ),
        ),
      );
    });

    test('should throw an error when subjectId has only spaces', () async {
      // Arrange
      final topic = makeTopic(subjectId: '   ');

      // Act
      Future<void> action() => usecase(topic);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyTopicSubjectIdException>().having(
            (error) => error.message,
            'message',
            'Subject id is required.',
          ),
        ),
      );
    });

    test('should throw an error when title is empty', () async {
      // Arrange
      final topic = makeTopic(title: '');

      // Act
      Future<void> action() => usecase(topic);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyTopicTitleException>().having(
            (error) => error.message,
            'message',
            'Topic title is required.',
          ),
        ),
      );
    });

    test('should throw an error when title has only spaces', () async {
      // Arrange
      final topic = makeTopic(title: '   ');

      // Act
      Future<void> action() => usecase(topic);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyTopicTitleException>().having(
            (error) => error.message,
            'message',
            'Topic title is required.',
          ),
        ),
      );
    });
  });
}

Topic makeTopic({
  String id = 'topic-1',
  String subjectId = 'subject-1',
  String title = 'Subject-verb agreement',
}) {
  return Topic(
    id: id,
    subjectId: subjectId,
    title: title,
    status: TopicStatus.notStarted,
    priority: TopicPriority.medium,
    createdAt: DateTime(2026, 6),
  );
}

class FakeTopicRepository implements TopicRepository {
  final List<Topic> topics = [];
  bool createTopicWasCalled = false;
  Topic? createdTopic;

  @override
  Future<void> createTopic(Topic topic) async {
    createTopicWasCalled = true;
    createdTopic = topic;
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
