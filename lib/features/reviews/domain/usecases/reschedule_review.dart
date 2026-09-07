import '../entities/review.dart';
import '../errors/review_exceptions.dart';
import '../repositories/review_repository.dart';

class RescheduleReview {
  final ReviewRepository repository;
  final DateTime Function() now;

  RescheduleReview(this.repository, {DateTime Function()? now})
    : now = now ?? DateTime.now;

  Future<void> call({
    required String reviewId,
    required DateTime scheduledFor,
  }) async {
    if (reviewId.trim().isEmpty) throw const EmptyReviewIdException();
    final review = await repository.getReviewById(reviewId);
    if (review == null) throw const ReviewNotFoundException();
    if (review.isCompleted) throw const ReviewAlreadyCompletedException();

    final today = now().toLocal();
    final date = scheduledFor.toLocal();
    if (DateTime(
      date.year,
      date.month,
      date.day,
    ).isBefore(DateTime(today.year, today.month, today.day))) {
      throw const InvalidReviewScheduleException();
    }

    await repository.updateReview(
      Review(
        id: review.id,
        topicId: review.topicId,
        scheduledFor: scheduledFor,
        reviewedAt: review.reviewedAt,
        quality: review.quality,
        createdAt: review.createdAt,
      ),
    );
  }
}
