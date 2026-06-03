import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
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

    test('deve criar um tópico válido', () async {
      final topic = makeTopic(title: 'Pronome relativo');

      await usecase(topic);

      expect(repository.topics, contains(topic));
    });

    test('deve chamar o repository', () async {
      final topic = makeTopic(title: 'Orações subordinadas');

      await usecase(topic);

      expect(repository.createTopicWasCalled, isTrue);
      expect(repository.createdTopic, topic);
    });

    test('deve lançar erro se subjectId estiver vazio', () async {
      final topic = makeTopic(subjectId: '');

      expect(
        () => usecase(topic),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'O id da matéria é obrigatório.',
          ),
        ),
      );
    });

    test('deve lançar erro se subjectId tiver apenas espaços', () async {
      final topic = makeTopic(subjectId: '   ');

      expect(
        () => usecase(topic),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'O id da matéria é obrigatório.',
          ),
        ),
      );
    });

    test('deve lançar erro se title estiver vazio', () async {
      final topic = makeTopic(title: '');

      expect(
        () => usecase(topic),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'O título do tópico é obrigatório.',
          ),
        ),
      );
    });

    test('deve lançar erro se title tiver apenas espaços', () async {
      final topic = makeTopic(title: '   ');

      expect(
        () => usecase(topic),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'O título do tópico é obrigatório.',
          ),
        ),
      );
    });
  });
}

Topic makeTopic({
  String id = 'topic-1',
  String subjectId = 'subject-1',
  String title = 'Regência verbal',
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
