import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/errors/topic_exceptions.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/delete_topic.dart';

void main() {
  group('DeleteTopic', () {
    late FakeTopicRepository repository;
    late DeleteTopic usecase;

    setUp(() {
      repository = FakeTopicRepository();
      usecase = DeleteTopic(repository);
    });

    test('deve excluir um tópico pelo id', () async {
      final topic = makeTopic(id: 'topic-1');
      repository.topics.add(topic);

      await usecase(topic.id);

      expect(repository.topics, isEmpty);
    });

    test('deve chamar o repository com o id correto', () async {
      await usecase('topic-1');

      expect(repository.deleteTopicWasCalled, isTrue);
      expect(repository.deletedId, 'topic-1');
    });

    test('deve lançar erro se o id estiver vazio', () async {
      expect(
        () => usecase(''),
        throwsA(
          isA<EmptyTopicIdException>().having(
            (error) => error.message,
            'message',
            'Topic id is required.',
          ),
        ),
      );
    });

    test('deve lançar erro se o id tiver apenas espaços', () async {
      expect(
        () => usecase('   '),
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

Topic makeTopic({required String id}) {
  return Topic(
    id: id,
    subjectId: 'subject-1',
    title: 'Concordância verbal',
    status: TopicStatus.notStarted,
    priority: TopicPriority.medium,
    createdAt: DateTime(2026, 6),
  );
}

class FakeTopicRepository implements TopicRepository {
  final List<Topic> topics = [];
  bool deleteTopicWasCalled = false;
  String? deletedId;

  @override
  Future<void> createTopic(Topic topic) async {
    topics.add(topic);
  }

  @override
  Future<void> deleteTopic(String id) async {
    deleteTopicWasCalled = true;
    deletedId = id;
    topics.removeWhere((topic) => topic.id == id);
  }

  @override
  Future<List<Topic>> getTopicsBySubject(String subjectId) async {
    return topics.where((topic) => topic.subjectId == subjectId).toList();
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {}
}
