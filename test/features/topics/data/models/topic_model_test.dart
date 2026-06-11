import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/data/models/topic_model.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';

void main() {
  group('TopicModel', () {
    test('should create a model from a domain entity', () {
      // Arrange
      final topic = makeTopic();

      // Act
      final model = TopicModel.fromEntity(topic);

      // Assert
      expect(model.id, topic.id);
      expect(model.subjectId, topic.subjectId);
      expect(model.title, topic.title);
      expect(model.description, topic.description);
      expect(model.status, topic.status);
      expect(model.priority, topic.priority);
      expect(model.createdAt, topic.createdAt);
      expect(model.updatedAt, topic.updatedAt);
      expect(model.completedAt, topic.completedAt);
      expect(model.nextReviewAt, topic.nextReviewAt);
    });

    test('should convert a model to a domain entity', () {
      // Arrange
      final model = makeTopicModel();

      // Act
      final topic = model.toEntity();

      // Assert
      expect(topic, isA<Topic>());
      expect(topic.id, model.id);
      expect(topic.subjectId, model.subjectId);
      expect(topic.title, model.title);
      expect(topic.description, model.description);
      expect(topic.status, model.status);
      expect(topic.priority, model.priority);
      expect(topic.createdAt, model.createdAt);
      expect(topic.updatedAt, model.updatedAt);
      expect(topic.completedAt, model.completedAt);
      expect(topic.nextReviewAt, model.nextReviewAt);
    });

    test('should convert a model to map', () {
      // Arrange
      final model = makeTopicModel();

      // Act
      final map = model.toMap();

      // Assert
      expect(map['id'], 'topic-1');
      expect(map['subject_id'], 'subject-1');
      expect(map['title'], 'Relative pronoun');
      expect(map['description'], 'Grammar content');
      expect(map['status'], 'studying');
      expect(map['priority'], 'high');
      expect(map['created_at'], DateTime(2026, 6, 8).toIso8601String());
      expect(map['updated_at'], DateTime(2026, 6, 9).toIso8601String());
      expect(map['completed_at'], DateTime(2026, 6, 10).toIso8601String());
      expect(map['next_review_at'], DateTime(2026, 6, 17).toIso8601String());
    });

    test('should convert a map to model', () {
      // Arrange
      final map = {
        'id': 'topic-1',
        'subject_id': 'subject-1',
        'title': 'Relative pronoun',
        'description': null,
        'status': 'review',
        'priority': 'medium',
        'created_at': DateTime(2026, 6, 8).toIso8601String(),
        'updated_at': null,
        'completed_at': null,
        'next_review_at': null,
      };

      // Act
      final model = TopicModel.fromMap(map);

      // Assert
      expect(model.id, 'topic-1');
      expect(model.subjectId, 'subject-1');
      expect(model.title, 'Relative pronoun');
      expect(model.description, isNull);
      expect(model.status, TopicStatus.review);
      expect(model.priority, TopicPriority.medium);
      expect(model.createdAt, DateTime(2026, 6, 8));
      expect(model.updatedAt, isNull);
      expect(model.completedAt, isNull);
      expect(model.nextReviewAt, isNull);
    });
  });
}

Topic makeTopic() {
  return Topic(
    id: 'topic-1',
    subjectId: 'subject-1',
    title: 'Relative pronoun',
    description: 'Grammar content',
    status: TopicStatus.studying,
    priority: TopicPriority.high,
    createdAt: DateTime(2026, 6, 8),
    updatedAt: DateTime(2026, 6, 9),
    completedAt: DateTime(2026, 6, 10),
    nextReviewAt: DateTime(2026, 6, 17),
  );
}

TopicModel makeTopicModel() {
  return TopicModel(
    id: 'topic-1',
    subjectId: 'subject-1',
    title: 'Relative pronoun',
    description: 'Grammar content',
    status: TopicStatus.studying,
    priority: TopicPriority.high,
    createdAt: DateTime(2026, 6, 8),
    updatedAt: DateTime(2026, 6, 9),
    completedAt: DateTime(2026, 6, 10),
    nextReviewAt: DateTime(2026, 6, 17),
  );
}
