import '../entities/topic.dart';

abstract class TopicRepository {
  Future<void> createTopic(Topic topic);
  Future<List<Topic>> getTopicsBySubject(String subjectId);
  Future<void> updateTopicStatus(String topicId, TopicStatus status);
  Future<void> deleteTopic(String id);
}
