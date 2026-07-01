import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/create_topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/delete_topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/get_topics_by_subject.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/usecases/update_topic_status.dart';
import 'package:gestao_estudos_flutter/features/topics/presentation/cubit/topics_cubit.dart';
import 'package:gestao_estudos_flutter/features/topics/presentation/pages/topics_page.dart';

void main() {
  late FakeTopicRepository repository;
  late TopicsCubit cubit;
  final today = DateTime(2026, 6, 30);
  final subject = Subject(
    id: 'subject-1',
    name: 'Banco de Dados',
    createdAt: today,
  );

  setUp(() {
    repository = FakeTopicRepository();
    cubit = TopicsCubit(
      subjectId: subject.id,
      getTopicsBySubject: GetTopicsBySubject(repository),
      createTopicUseCase: CreateTopic(repository),
      updateTopicStatusUseCase: UpdateTopicStatus(repository),
      deleteTopicUseCase: DeleteTopic(repository),
      generateTopicId: () => 'topic-created',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('deve exibir estado vazio quando não houver tópicos', (
    tester,
  ) async {
    await cubit.loadTopics();
    await tester.pumpTopicsPage(cubit, subject);

    expect(find.text('Banco de Dados'), findsOneWidget);
    expect(find.text('Nenhum tópico cadastrado'), findsOneWidget);
  });

  testWidgets('deve listar tópicos cadastrados', (tester) async {
    repository.topics.add(
      Topic(
        id: 'topic-1',
        subjectId: subject.id,
        title: 'Normalização',
        description: 'Formas normais',
        status: TopicStatus.studying,
        priority: TopicPriority.high,
        createdAt: today,
      ),
    );

    await cubit.loadTopics();
    await tester.pumpTopicsPage(cubit, subject);

    expect(find.text('Normalização'), findsOneWidget);
    expect(find.text('Formas normais'), findsOneWidget);
    expect(find.text('Estudando'), findsOneWidget);
    expect(find.text('Alta'), findsOneWidget);
  });

  testWidgets('deve criar tópico pelo formulário', (tester) async {
    await cubit.loadTopics();
    await tester.pumpTopicsPage(cubit, subject);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Índices');
    await tester.enterText(find.byType(TextFormField).last, 'Busca rápida');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(repository.topics.length, 1);
    expect(find.text('Índices'), findsOneWidget);
    expect(find.text('Busca rápida'), findsOneWidget);
  });

  testWidgets('deve validar título obrigatório no formulário', (tester) async {
    await cubit.loadTopics();
    await tester.pumpTopicsPage(cubit, subject);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o título do tópico'), findsOneWidget);
    expect(repository.topics, isEmpty);
  });

  testWidgets('deve atualizar status do tópico pela tela', (tester) async {
    repository.topics.add(
      Topic(
        id: 'topic-1',
        subjectId: subject.id,
        title: 'Normalização',
        status: TopicStatus.notStarted,
        priority: TopicPriority.medium,
        createdAt: today,
      ),
    );

    await cubit.loadTopics();
    await tester.pumpTopicsPage(cubit, subject);
    await tester.tap(find.byTooltip('Alterar status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluído').last);
    await tester.pumpAndSettle();

    expect(repository.topics.first.status, TopicStatus.completed);
    expect(find.text('Concluído'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpTopicsPage(TopicsCubit cubit, Subject subject) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: TopicsPage(subject: subject),
        ),
      ),
    );
  }
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
}
