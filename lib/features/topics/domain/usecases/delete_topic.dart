import '../repositories/topic_repository.dart';

class DeleteTopic {
  final TopicRepository repository;

  const DeleteTopic(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('O id do tópico é obrigatório.');
    }

    await repository.deleteTopic(id);
  }
}
