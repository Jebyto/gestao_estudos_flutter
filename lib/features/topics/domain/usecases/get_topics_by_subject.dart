import '../entities/topic.dart';
import '../repositories/topic_repository.dart';

class GetTopicsBySubject {
  final TopicRepository repository;

  const GetTopicsBySubject(this.repository);

  Future<List<Topic>> call(String subjectId) async {
    if (subjectId.trim().isEmpty) {
      throw ArgumentError('O id da matéria é obrigatório.');
    }

    return repository.getTopicsBySubject(subjectId);
  }
}
