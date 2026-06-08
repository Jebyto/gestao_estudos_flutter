import '../entities/review.dart';
import '../errors/review_exceptions.dart';
import '../repositories/review_repository.dart';

class CreateReview {
  final ReviewRepository repository;

  const CreateReview(this.repository);

  Future<void> call(Review review) async {
    if (review.topicId.trim().isEmpty) {
      throw const EmptyReviewTopicIdException();
    }

    await repository.createReview(review);
  }
}
