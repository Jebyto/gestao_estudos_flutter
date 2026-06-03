import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
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

    test('deve atualizar o status de um tópico', () async {
      await usecase('topic-1', TopicStatus.completed);

      expect(repository.updatedStatus, TopicStatus.completed);
    });

    test('deve chamar o repository com topicId e status corretos', () async {
      await usecase('topic-1', TopicStatus.review);

      expect(repository.updateTopicStatusWasCalled, isTrue);
      expect(repository.updatedTopicId, 'topic-1');
      expect(repository.updatedStatus, TopicStatus.review);
    });

    test('deve lançar erro se topicId estiver vazio', () async {
      expect(
        () => usecase('', TopicStatus.studying),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'O id do tópico é obrigatório.',
          ),
        ),
      );
    });

    test('deve lançar erro se topicId tiver apenas espaços', () async {
      expect(
        () => usecase('   ', TopicStatus.studying),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'O id do tópico é obrigatório.',
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
