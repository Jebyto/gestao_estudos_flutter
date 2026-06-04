import '../entities/topic.dart';
import '../errors/topic_exceptions.dart';
import '../repositories/topic_repository.dart';

class CreateTopic {
  final TopicRepository repository;

  const CreateTopic(this.repository);

  Future<void> call(Topic topic) async {
    if (topic.subjectId.trim().isEmpty) {
      throw const EmptyTopicSubjectIdException();
    }

    if (topic.title.trim().isEmpty) {
      throw const EmptyTopicTitleException();
    }

    await repository.createTopic(topic);
  }
}
