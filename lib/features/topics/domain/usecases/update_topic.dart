import '../entities/topic.dart';
import '../errors/topic_exceptions.dart';
import '../repositories/topic_repository.dart';

class UpdateTopic {
  final TopicRepository repository;

  const UpdateTopic(this.repository);

  Future<void> call(Topic topic) async {
    if (topic.id.trim().isEmpty) {
      throw const EmptyTopicIdException();
    }

    if (topic.subjectId.trim().isEmpty) {
      throw const EmptyTopicSubjectIdException();
    }

    if (topic.title.trim().isEmpty) {
      throw const EmptyTopicTitleException();
    }

    await repository.updateTopic(topic);
  }
}
