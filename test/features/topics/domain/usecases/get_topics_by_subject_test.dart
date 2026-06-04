import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/errors/topic_exceptions.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/get_topics_by_subject.dart';

void main() {
  group('GetTopicsBySubject', () {
    late FakeTopicRepository repository;
    late GetTopicsBySubject usecase;

    setUp(() {
      repository = FakeTopicRepository();
      usecase = GetTopicsBySubject(repository);
    });

    test(
      'should return an empty list when the subject has no topics',
      () async {
        // Arrange
        const subjectId = 'subject-1';

        // Act
        final topics = await usecase(subjectId);

        // Assert
        expect(topics, isEmpty);
      },
    );

    test('should return the topics from a subject', () async {
      // Arrange
      const subjectId = 'subject-1';
      final firstTopic = makeTopic(
        id: 'topic-1',
        subjectId: subjectId,
        title: 'Relative pronoun',
      );
      final secondTopic = makeTopic(
        id: 'topic-2',
        subjectId: subjectId,
        title: 'Subordinate clauses',
      );
      final anotherSubjectTopic = makeTopic(
        id: 'topic-3',
        subjectId: 'subject-2',
        title: 'Functions',
      );
      repository.topics.addAll([firstTopic, secondTopic, anotherSubjectTopic]);

      // Act
      final topics = await usecase(subjectId);

      // Assert
      expect(topics, [firstTopic, secondTopic]);
    });

    test('should throw an error when subjectId is empty', () async {
      // Arrange

      // Act
      Future<List<Topic>> action() => usecase('');

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

      // Act
      Future<List<Topic>> action() => usecase('   ');

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
  });
}

Topic makeTopic({
  required String id,
  required String subjectId,
  required String title,
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
