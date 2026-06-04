import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/errors/topic_exceptions.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/update_topic_status.dart';

void main() {
  group('UpdateTopicStatus', () {
    late FakeTopicRepository repository;
    late UpdateTopicStatus usecase;

    setUp(() {
      repository = FakeTopicRepository();
      usecase = UpdateTopicStatus(repository);
    });

    test('should update the status of a topic', () async {
      // Arrange
      const topicId = 'topic-1';
      const status = TopicStatus.completed;

      // Act
      await usecase(topicId, status);

      // Assert
      expect(repository.updatedStatus, status);
    });

    test(
      'should call the repository with the correct topicId and status',
      () async {
        // Arrange
        const topicId = 'topic-1';
        const status = TopicStatus.review;

        // Act
        await usecase(topicId, status);

        // Assert
        expect(repository.updateTopicStatusWasCalled, isTrue);
        expect(repository.updatedTopicId, topicId);
        expect(repository.updatedStatus, status);
      },
    );

    test('should throw an error when topicId is empty', () async {
      // Arrange

      // Act
      Future<void> action() => usecase('', TopicStatus.studying);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyTopicIdException>().having(
            (error) => error.message,
            'message',
            'Topic id is required.',
          ),
        ),
      );
    });

    test('should throw an error when topicId has only spaces', () async {
      // Arrange

      // Act
      Future<void> action() => usecase('   ', TopicStatus.studying);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyTopicIdException>().having(
            (error) => error.message,
            'message',
            'Topic id is required.',
          ),
        ),
      );
    });
  });
}

class FakeTopicRepository implements TopicRepository {
  final List<Topic> topics = [];
  bool updateTopicStatusWasCalled = false;
  String? updatedTopicId;
  TopicStatus? updatedStatus;

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
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    updateTopicStatusWasCalled = true;
    updatedTopicId = topicId;
    updatedStatus = status;
  }
}
