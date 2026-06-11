import '../../domain/entities/topic.dart';
import '../../domain/repositories/topic_repository.dart';
import '../datasources/topic_local_datasource.dart';
import '../models/topic_model.dart';

class TopicRepositoryImpl implements TopicRepository {
  final TopicLocalDataSource localDataSource;

  const TopicRepositoryImpl(this.localDataSource);

  @override
  Future<void> createTopic(Topic topic) {
    final model = TopicModel.fromEntity(topic);

    return localDataSource.createTopic(model);
  }

  @override
  Future<void> deleteTopic(String id) {
    return localDataSource.deleteTopic(id);
  }

  @override
  Future<List<Topic>> getTopicsBySubject(String subjectId) async {
    final models = await localDataSource.getTopicsBySubject(subjectId);

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) {
    return localDataSource.updateTopicStatus(topicId, status);
  }
}
