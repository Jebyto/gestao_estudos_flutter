import '../errors/topic_exceptions.dart';
import '../repositories/topic_repository.dart';

class DeleteTopic {
  final TopicRepository repository;

  const DeleteTopic(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw const EmptyTopicIdException();
    }

    await repository.deleteTopic(id);
  }
}
