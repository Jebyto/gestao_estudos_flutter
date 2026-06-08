import '../entities/review.dart';
import '../errors/review_exceptions.dart';
import '../repositories/review_repository.dart';
import '../services/review_scheduler.dart';

typedef ReviewIdGenerator = String Function();

class CompleteReview {
  final ReviewRepository repository;
  final ReviewScheduler scheduler;
  final ReviewIdGenerator generateReviewId;

  CompleteReview(
    this.repository, {
    ReviewScheduler? scheduler,
    ReviewIdGenerator? generateReviewId,
  }) : scheduler = scheduler ?? const ReviewScheduler(),
       generateReviewId = generateReviewId ?? _defaultGenerateReviewId;

  Future<void> call({
    required String reviewId,
    required ReviewQuality quality,
    required DateTime reviewedAt,
  }) async {
    if (reviewId.trim().isEmpty) {
      throw const EmptyReviewIdException();
    }

    final review = await repository.getReviewById(reviewId);

    if (review == null) {
      throw const ReviewNotFoundException();
    }

    final completedReview = Review(
      id: review.id,
      topicId: review.topicId,
      scheduledFor: review.scheduledFor,
      reviewedAt: reviewedAt,
      quality: quality,
      createdAt: review.createdAt,
    );
    final nextReview = Review(
      id: generateReviewId(),
      topicId: review.topicId,
      scheduledFor: scheduler.calculateNextReviewDate(
        quality: quality,
        baseDate: reviewedAt,
      ),
      createdAt: reviewedAt,
    );

    await repository.updateReview(completedReview);
    await repository.createReview(nextReview);
  }
}

String _defaultGenerateReviewId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}
