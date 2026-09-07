import '../errors/review_exceptions.dart';
import '../repositories/review_repository.dart';

class CancelReview {
  final ReviewRepository repository;

  const CancelReview(this.repository);

  Future<void> call(String reviewId) async {
    if (reviewId.trim().isEmpty) throw const EmptyReviewIdException();
    final review = await repository.getReviewById(reviewId);
    if (review == null) throw const ReviewNotFoundException();
    if (review.isCompleted) throw const ReviewAlreadyCompletedException();

    await repository.deleteReview(reviewId);
  }
}
