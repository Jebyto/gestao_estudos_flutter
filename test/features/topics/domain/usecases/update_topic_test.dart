import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/errors/topic_exceptions.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/update_topic.dart';

void main() {
  group('UpdateTopic', () {
    late FakeTopicRepository repository;
    late UpdateTopic usecase;

    setUp(() {
      repository = FakeTopicRepository();
      usecase = UpdateTopic(repository);
    });

    test('should update a valid topic', () async {
      final topic = makeTopic();

      await usecase(topic);

      expect(repository.updatedTopic, topic);
    });

    test('should throw an error when the id is empty', () async {
      Future<void> action() => usecase(makeTopic(id: ''));

      expect(action, throwsA(isA<EmptyTopicIdException>()));
    });

    test('should throw an error when the subject id is empty', () async {
      Future<void> action() => usecase(makeTopic(subjectId: '   '));

      expect(action, throwsA(isA<EmptyTopicSubjectIdException>()));
    });

    test('should throw an error when the title is empty', () async {
      Future<void> action() => usecase(makeTopic(title: ''));

      expect(action, throwsA(isA<EmptyTopicTitleException>()));
    });
  });
}

Topic makeTopic({
  String id = 'topic-1',
  String subjectId = 'subject-1',
  String title = 'Functions',
}) {
  return Topic(
    id: id,
    subjectId: subjectId,
    title: title,
    status: TopicStatus.studying,
    priority: TopicPriority.medium,
    createdAt: DateTime(2026, 6, 8),
  );
}

class FakeTopicRepository implements TopicRepository {
  Topic? updatedTopic;

  @override
  Future<void> updateTopic(Topic topic) async {
    updatedTopic = topic;
  }

  @override
  Future<void> createTopic(Topic topic) async {}

  @override
  Future<void> deleteTopic(String id) async {}

  @override
  Future<List<Topic>> getTopicsBySubject(String subjectId) async => [];

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {}
}
