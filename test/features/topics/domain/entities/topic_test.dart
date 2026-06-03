import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';

void main() {
  group('Topic', () {
    final createdAt = DateTime(2026, 6);
    final updatedAt = DateTime(2026, 6, 1);
    final completedAt = DateTime(2026, 6, 2);
    final nextReviewAt = DateTime(2026, 6, 9);

    test('deve criar um tópico válido', () {
      final topic = Topic(
        id: 'topic-1',
        subjectId: 'subject-1',
        title: 'Pronome relativo',
        description: 'Conteúdo de português',
        status: TopicStatus.notStarted,
        priority: TopicPriority.medium,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
        nextReviewAt: nextReviewAt,
      );

      expect(topic, isA<Topic>());
    });

    test('deve manter os valores passados no construtor', () {
      final topic = Topic(
        id: 'topic-1',
        subjectId: 'subject-1',
        title: 'Orações subordinadas',
        description: 'Revisar classificação das orações',
        status: TopicStatus.studying,
        priority: TopicPriority.high,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
        nextReviewAt: nextReviewAt,
      );

      expect(topic.id, 'topic-1');
      expect(topic.subjectId, 'subject-1');
      expect(topic.title, 'Orações subordinadas');
      expect(topic.description, 'Revisar classificação das orações');
      expect(topic.status, TopicStatus.studying);
      expect(topic.priority, TopicPriority.high);
      expect(topic.createdAt, createdAt);
      expect(topic.updatedAt, updatedAt);
      expect(topic.completedAt, completedAt);
      expect(topic.nextReviewAt, nextReviewAt);
    });

    test('deve aceitar descrição nula', () {
      final topic = makeTopic(description: null);

      expect(topic.description, isNull);
    });

    test('deve aceitar updatedAt, completedAt e nextReviewAt nulos', () {
      final topic = makeTopic(
        updatedAt: null,
        completedAt: null,
        nextReviewAt: null,
      );

      expect(topic.updatedAt, isNull);
      expect(topic.completedAt, isNull);
      expect(topic.nextReviewAt, isNull);
    });

    test('deve pertencer a uma matéria via subjectId', () {
      final topic = makeTopic(subjectId: 'subject-portugues');

      expect(topic.subjectId, 'subject-portugues');
    });

    test('deve comparar tópicos por valor', () {
      final firstTopic = makeTopic();
      final secondTopic = makeTopic();

      expect(firstTopic, secondTopic);
    });
  });
}

Topic makeTopic({
  String id = 'topic-1',
  String subjectId = 'subject-1',
  String title = 'Concordância verbal',
  String? description = 'Estudo de regras gerais',
  TopicStatus status = TopicStatus.notStarted,
  TopicPriority priority = TopicPriority.medium,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? completedAt,
  DateTime? nextReviewAt,
}) {
  return Topic(
    id: id,
    subjectId: subjectId,
    title: title,
    description: description,
    status: status,
    priority: priority,
    createdAt: createdAt ?? DateTime(2026, 6),
    updatedAt: updatedAt,
    completedAt: completedAt,
    nextReviewAt: nextReviewAt,
  );
}
