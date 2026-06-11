import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/datasources/subject_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/models/subject_model.dart';
import 'package:gestao_estudos_flutter/features/topics/data/datasources/topic_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/topics/data/models/topic_model.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('TopicLocalDataSourceImpl', () {
    late AppDatabase appDatabase;
    late SubjectLocalDataSourceImpl subjectDataSource;
    late TopicLocalDataSourceImpl topicDataSource;

    setUp(() {
      sqfliteFfiInit();
      appDatabase = AppDatabase(
        databasePath: inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        singleInstance: false,
      );
      subjectDataSource = SubjectLocalDataSourceImpl(appDatabase);
      topicDataSource = TopicLocalDataSourceImpl(appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('should save and get topics from SQLite by subject', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      final topic = makeTopic(id: 'topic-1', subjectId: 'subject-1');

      // Act
      await topicDataSource.createTopic(topic);
      final topics = await topicDataSource.getTopicsBySubject('subject-1');

      // Assert
      expect(topics.length, 1);
      expect(topics.first.id, 'topic-1');
      expect(topics.first.subjectId, 'subject-1');
      expect(topics.first.status, TopicStatus.notStarted);
      expect(topics.first.priority, TopicPriority.medium);
    });

    test('should not return topics from another subject', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await subjectDataSource.createSubject(makeSubject(id: 'subject-2'));
      await topicDataSource.createTopic(
        makeTopic(id: 'topic-1', subjectId: 'subject-1'),
      );
      await topicDataSource.createTopic(
        makeTopic(id: 'topic-2', subjectId: 'subject-2'),
      );

      // Act
      final topics = await topicDataSource.getTopicsBySubject('subject-1');

      // Assert
      expect(topics.length, 1);
      expect(topics.first.id, 'topic-1');
    });

    test('should order topics by createdAt descending', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await topicDataSource.createTopic(
        makeTopic(
          id: 'topic-1',
          subjectId: 'subject-1',
          createdAt: DateTime(2026, 6, 7),
        ),
      );
      await topicDataSource.createTopic(
        makeTopic(
          id: 'topic-2',
          subjectId: 'subject-1',
          createdAt: DateTime(2026, 6, 8),
        ),
      );

      // Act
      final topics = await topicDataSource.getTopicsBySubject('subject-1');

      // Assert
      expect(topics.map((topic) => topic.id), ['topic-2', 'topic-1']);
    });

    test('should update a topic status in SQLite', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await topicDataSource.createTopic(
        makeTopic(id: 'topic-1', subjectId: 'subject-1'),
      );

      // Act
      await topicDataSource.updateTopicStatus('topic-1', TopicStatus.completed);
      final topics = await topicDataSource.getTopicsBySubject('subject-1');

      // Assert
      expect(topics.first.status, TopicStatus.completed);
    });

    test('should delete a topic from SQLite', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await topicDataSource.createTopic(
        makeTopic(id: 'topic-1', subjectId: 'subject-1'),
      );

      // Act
      await topicDataSource.deleteTopic('topic-1');
      final topics = await topicDataSource.getTopicsBySubject('subject-1');

      // Assert
      expect(topics, isEmpty);
    });

    test('should reject a topic when the subject does not exist', () async {
      // Arrange
      final topic = makeTopic(id: 'topic-1', subjectId: 'missing-subject');

      // Act
      Future<void> action() => topicDataSource.createTopic(topic);

      // Assert
      expect(action, throwsA(isA<DatabaseException>()));
    });

    test('should delete subject topics when the subject is deleted', () async {
      // Arrange
      await subjectDataSource.createSubject(makeSubject(id: 'subject-1'));
      await topicDataSource.createTopic(
        makeTopic(id: 'topic-1', subjectId: 'subject-1'),
      );

      // Act
      await subjectDataSource.deleteSubject('subject-1');
      final topics = await topicDataSource.getTopicsBySubject('subject-1');

      // Assert
      expect(topics, isEmpty);
    });
  });
}

SubjectModel makeSubject({required String id}) {
  return SubjectModel(id: id, name: 'Math', createdAt: DateTime(2026, 6, 8));
}

TopicModel makeTopic({
  required String id,
  required String subjectId,
  DateTime? createdAt,
}) {
  return TopicModel(
    id: id,
    subjectId: subjectId,
    title: 'Functions',
    description: 'Study functions',
    status: TopicStatus.notStarted,
    priority: TopicPriority.medium,
    createdAt: createdAt ?? DateTime(2026, 6, 8),
  );
}
