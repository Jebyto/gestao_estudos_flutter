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
      'deve retornar lista vazia quando a matéria não tiver tópicos',
      () async {
        final topics = await usecase('subject-1');

        expect(topics, isEmpty);
      },
    );

    test('deve retornar os tópicos de uma matéria', () async {
      final firstTopic = makeTopic(
        id: 'topic-1',
        subjectId: 'subject-1',
        title: 'Pronome relativo',
      );
      final secondTopic = makeTopic(
        id: 'topic-2',
        subjectId: 'subject-1',
        title: 'Orações subordinadas',
      );
      final anotherSubjectTopic = makeTopic(
        id: 'topic-3',
        subjectId: 'subject-2',
        title: 'Funções',
      );
      repository.topics.addAll([firstTopic, secondTopic, anotherSubjectTopic]);

      final topics = await usecase('subject-1');

      expect(topics, [firstTopic, secondTopic]);
    });

    test('deve lançar erro se subjectId estiver vazio', () async {
      expect(
        () => usecase(''),
        throwsA(
          isA<EmptyTopicSubjectIdException>().having(
            (error) => error.message,
            'message',
            'Subject id is required.',
          ),
        ),
      );
    });

    test('deve lançar erro se subjectId tiver apenas espaços', () async {
      expect(
        () => usecase('   '),
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
