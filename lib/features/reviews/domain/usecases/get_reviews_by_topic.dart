import '../entities/review.dart';
import '../errors/review_exceptions.dart';
import '../repositories/review_repository.dart';

class GetReviewsByTopic {
  final ReviewRepository repository;

  const GetReviewsByTopic(this.repository);

  Future<List<Review>> call(String topicId) async {
    if (topicId.trim().isEmpty) {
      throw const EmptyReviewTopicIdException();
    }

    return repository.getReviewsByTopic(topicId);
  }
}
