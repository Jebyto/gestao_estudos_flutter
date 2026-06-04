import '../entities/topic.dart';
import '../errors/topic_exceptions.dart';
import '../repositories/topic_repository.dart';

class UpdateTopicStatus {
  final TopicRepository repository;

  const UpdateTopicStatus(this.repository);

  Future<void> call(String topicId, TopicStatus status) async {
    if (topicId.trim().isEmpty) {
      throw const EmptyTopicIdException();
    }

    await repository.updateTopicStatus(topicId, status);
  }
}
