import '../entities/topic.dart';
import '../repositories/topic_repository.dart';

class CreateTopic {
  final TopicRepository repository;

  const CreateTopic(this.repository);

  Future<void> call(Topic topic) async {
    if (topic.subjectId.trim().isEmpty) {
      throw ArgumentError('O id da matéria é obrigatório.');
    }

    if (topic.title.trim().isEmpty) {
      throw ArgumentError('O título do tópico é obrigatório.');
    }

    await repository.createTopic(topic);
  }
}
