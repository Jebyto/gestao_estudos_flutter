import '../entities/review.dart';

abstract class ReviewRepository {
  Future<void> createReview(Review review);
  Future<List<Review>> getReviews();
  Future<Review?> getReviewById(String id);
  Future<List<Review>> getReviewsByTopic(String topicId);
  Future<void> updateReview(Review review);
}
