import '../entities/topic.dart';
import '../errors/topic_exceptions.dart';
import '../repositories/topic_repository.dart';

class GetTopicsBySubject {
  final TopicRepository repository;

  const GetTopicsBySubject(this.repository);

  Future<List<Topic>> call(String subjectId) async {
    if (subjectId.trim().isEmpty) {
      throw const EmptyTopicSubjectIdException();
    }

    return repository.getTopicsBySubject(subjectId);
  }
}
