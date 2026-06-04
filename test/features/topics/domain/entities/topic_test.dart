import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';

void main() {
  group('Topic', () {
    final createdAt = DateTime(2026, 6);
    final updatedAt = DateTime(2026, 6, 1);
    final completedAt = DateTime(2026, 6, 2);
    final nextReviewAt = DateTime(2026, 6, 9);

    test('should create a valid topic', () {
      // Arrange
      const title = 'Relative pronoun';
      const description = 'Grammar content';

      // Act
      final topic = Topic(
        id: 'topic-1',
        subjectId: 'subject-1',
        title: title,
        description: description,
        status: TopicStatus.notStarted,
        priority: TopicPriority.medium,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
        nextReviewAt: nextReviewAt,
      );

      // Assert
      expect(topic, isA<Topic>());
    });

    test('should keep the values passed to the constructor', () {
      // Arrange
      const title = 'Subordinate clauses';
      const description = 'Review clause classification';

      // Act
      final topic = Topic(
        id: 'topic-1',
        subjectId: 'subject-1',
        title: title,
        description: description,
        status: TopicStatus.studying,
        priority: TopicPriority.high,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
        nextReviewAt: nextReviewAt,
      );

      // Assert
      expect(topic.id, 'topic-1');
      expect(topic.subjectId, 'subject-1');
      expect(topic.title, title);
      expect(topic.description, description);
      expect(topic.status, TopicStatus.studying);
      expect(topic.priority, TopicPriority.high);
      expect(topic.createdAt, createdAt);
      expect(topic.updatedAt, updatedAt);
      expect(topic.completedAt, completedAt);
      expect(topic.nextReviewAt, nextReviewAt);
    });

    test('should accept a null description', () {
      // Arrange
      final topic = makeTopic(description: null);

      // Act
      final description = topic.description;

      // Assert
      expect(description, isNull);
    });

    test('should accept null updatedAt, completedAt, and nextReviewAt', () {
      // Arrange
      final topic = makeTopic(
        updatedAt: null,
        completedAt: null,
        nextReviewAt: null,
      );

      // Act
      final updatedAt = topic.updatedAt;
      final completedAt = topic.completedAt;
      final nextReviewAt = topic.nextReviewAt;

      // Assert
      expect(updatedAt, isNull);
      expect(completedAt, isNull);
      expect(nextReviewAt, isNull);
    });

    test('should belong to a subject through subjectId', () {
      // Arrange
      const subjectId = 'subject-english';
      final topic = makeTopic(subjectId: subjectId);

      // Act
      final topicSubjectId = topic.subjectId;

      // Assert
      expect(topicSubjectId, subjectId);
    });

    test('should compare topics by value', () {
      // Arrange
      final firstTopic = makeTopic();
      final secondTopic = makeTopic();

      // Act
      final topicsAreEqual = firstTopic == secondTopic;

      // Assert
      expect(topicsAreEqual, isTrue);
    });
  });
}

Topic makeTopic({
  String id = 'topic-1',
  String subjectId = 'subject-1',
  String title = 'Subject-verb agreement',
  String? description = 'Study general rules',
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
