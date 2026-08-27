import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/create_topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/delete_topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/get_topics_by_subject.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/update_topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/update_topic_status.dart';
import 'package:gestao_estudos_flutter/features/topics/presentation/cubit/topics_cubit.dart';
import 'package:gestao_estudos_flutter/features/topics/presentation/cubit/topics_state.dart';

void main() {
  late FakeTopicRepository repository;
  late TopicsCubit cubit;
  final today = DateTime(2026, 6, 30);

  setUp(() {
    repository = FakeTopicRepository();
    cubit = TopicsCubit(
      subjectId: 'subject-1',
      getTopicsBySubject: GetTopicsBySubject(repository),
      createTopicUseCase: CreateTopic(repository),
      updateTopicUseCase: UpdateTopic(repository),
      updateTopicStatusUseCase: UpdateTopicStatus(repository),
      deleteTopicUseCase: DeleteTopic(repository),
      generateTopicId: () => 'topic-1',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('deve iniciar com estado initial e lista vazia', () {
    expect(cubit.state.status, TopicsStatus.initial);
    expect(cubit.state.topics, isEmpty);
  });

  test('deve carregar tópicos da matéria', () async {
    final topic = Topic(
      id: 'topic-1',
      subjectId: 'subject-1',
      title: 'Normalização',
      status: TopicStatus.notStarted,
      priority: TopicPriority.high,
      createdAt: today,
    );
    repository.topics.add(topic);
    repository.topics.add(
      Topic(
        id: 'topic-2',
        subjectId: 'subject-2',
        title: 'Concordância verbal',
        status: TopicStatus.notStarted,
        priority: TopicPriority.medium,
        createdAt: today,
      ),
    );

    await cubit.loadTopics();

    expect(cubit.state.status, TopicsStatus.success);
    expect(cubit.state.topics, [topic]);
  });

  test('deve criar um tópico e recarregar a lista', () async {
    final created = await cubit.createTopic(
      title: ' Índices ',
      description: ' Estruturas de busca ',
      priority: TopicPriority.high,
    );

    expect(created, isTrue);
    expect(repository.topics.length, 1);
    expect(repository.topics.first.id, 'topic-1');
    expect(repository.topics.first.subjectId, 'subject-1');
    expect(repository.topics.first.title, 'Índices');
    expect(repository.topics.first.description, 'Estruturas de busca');
    expect(repository.topics.first.status, TopicStatus.notStarted);
    expect(repository.topics.first.priority, TopicPriority.high);
    expect(repository.topics.first.createdAt, today);
    expect(cubit.state.status, TopicsStatus.success);
    expect(cubit.state.topics, repository.topics);
  });

  test('deve rejeitar criação quando o título estiver vazio', () async {
    final created = await cubit.createTopic(title: '   ');

    expect(created, isFalse);
    expect(repository.topics, isEmpty);
    expect(cubit.state.status, TopicsStatus.failure);
    expect(cubit.state.errorMessage, 'Informe o título do tópico.');
  });

  test('deve atualizar status do tópico e recarregar a lista', () async {
    repository.topics.add(
      Topic(
        id: 'topic-1',
        subjectId: 'subject-1',
        title: 'Normalização',
        status: TopicStatus.notStarted,
        priority: TopicPriority.medium,
        createdAt: today,
      ),
    );

    await cubit.updateStatus(topicId: 'topic-1', status: TopicStatus.completed);

    expect(repository.topics.first.status, TopicStatus.completed);
    expect(cubit.state.status, TopicsStatus.success);
    expect(cubit.state.topics.first.status, TopicStatus.completed);
  });

  test('deve editar tópico preservando status e datas relacionadas', () async {
    final topic = Topic(
      id: 'topic-1',
      subjectId: 'subject-1',
      title: 'Normalização',
      status: TopicStatus.completed,
      priority: TopicPriority.medium,
      createdAt: DateTime(2026, 6, 1),
      completedAt: DateTime(2026, 6, 20),
      nextReviewAt: DateTime(2026, 7, 1),
    );
    repository.topics.add(topic);

    final updated = await cubit.updateTopic(
      topic: topic,
      title: ' Normalização avançada ',
      description: ' Formas normais ',
      priority: TopicPriority.high,
    );

    final savedTopic = repository.topics.single;
    expect(updated, isTrue);
    expect(savedTopic.id, topic.id);
    expect(savedTopic.subjectId, topic.subjectId);
    expect(savedTopic.title, 'Normalização avançada');
    expect(savedTopic.description, 'Formas normais');
    expect(savedTopic.status, topic.status);
    expect(savedTopic.priority, TopicPriority.high);
    expect(savedTopic.createdAt, topic.createdAt);
    expect(savedTopic.updatedAt, today);
    expect(savedTopic.completedAt, topic.completedAt);
    expect(savedTopic.nextReviewAt, topic.nextReviewAt);
  });

  test('deve rejeitar edição quando o título estiver vazio', () async {
    final topic = Topic(
      id: 'topic-1',
      subjectId: 'subject-1',
      title: 'Normalização',
      status: TopicStatus.notStarted,
      priority: TopicPriority.medium,
      createdAt: today,
    );
    repository.topics.add(topic);

    final updated = await cubit.updateTopic(
      topic: topic,
      title: '   ',
      priority: TopicPriority.high,
    );

    expect(updated, isFalse);
    expect(repository.topics.single, topic);
    expect(cubit.state.errorMessage, 'Informe o título do tópico.');
  });

  test('deve excluir um tópico e recarregar a lista', () async {
    repository.topics.add(
      Topic(
        id: 'topic-1',
        subjectId: 'subject-1',
        title: 'Normalização',
        status: TopicStatus.notStarted,
        priority: TopicPriority.medium,
        createdAt: today,
      ),
    );

    await cubit.deleteTopic('topic-1');

    expect(repository.topics, isEmpty);
    expect(cubit.state.status, TopicsStatus.success);
    expect(cubit.state.topics, isEmpty);
  });
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
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    final index = topics.indexWhere((topic) => topic.id == topicId);
    final topic = topics[index];

    topics[index] = Topic(
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

  @override
  Future<void> updateTopic(Topic topic) async {
    final index = topics.indexWhere((item) => item.id == topic.id);
    topics[index] = topic;
  }
}
