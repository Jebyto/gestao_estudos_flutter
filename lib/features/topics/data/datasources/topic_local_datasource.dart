import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/topic.dart';
import '../models/topic_model.dart';

abstract class TopicLocalDataSource {
  Future<void> createTopic(TopicModel topic);
  Future<List<TopicModel>> getTopicsBySubject(String subjectId);
  Future<void> updateTopicStatus(String topicId, TopicStatus status);
  Future<void> deleteTopic(String id);
}

class TopicLocalDataSourceImpl implements TopicLocalDataSource {
  final AppDatabase appDatabase;

  const TopicLocalDataSourceImpl(this.appDatabase);

  @override
  Future<void> createTopic(TopicModel topic) async {
    final database = await appDatabase.database;

    await database.insert(
      'topics',
      topic.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTopic(String id) async {
    final database = await appDatabase.database;

    await database.delete('topics', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TopicModel>> getTopicsBySubject(String subjectId) async {
    final database = await appDatabase.database;
    final result = await database.query(
      'topics',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'created_at DESC',
    );

    return result.map(TopicModel.fromMap).toList();
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    final database = await appDatabase.database;

    await database.update(
      'topics',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }
}
