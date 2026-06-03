import '../entities/topic.dart';
import '../repositories/topic_repository.dart';

class UpdateTopicStatus {
  final TopicRepository repository;

  const UpdateTopicStatus(this.repository);

  Future<void> call(String topicId, TopicStatus status) async {
    if (topicId.trim().isEmpty) {
      throw ArgumentError('O id do tópico é obrigatório.');
    }

    await repository.updateTopicStatus(topicId, status);
  }
}
