import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_pending_reviews.dart';

void main() {
  group('GetPendingReviews', () {
    late FakeReviewRepository repository;
    late GetPendingReviews usecase;

    setUp(() {
      repository = FakeReviewRepository();
      usecase = GetPendingReviews(repository);
    });

    test('should return an empty list when there are no reviews', () async {
      // Arrange

      // Act
      final reviews = await usecase(DateTime(2026, 6, 7));

      // Assert
      expect(reviews, isEmpty);
    });

    test(
      'should return pending reviews scheduled until the reference date',
      () async {
        // Arrange
        final overdueReview = makeReview(
          id: 'review-1',
          scheduledFor: DateTime(2026, 6, 6),
        );
        final todayReview = makeReview(
          id: 'review-2',
          scheduledFor: DateTime(2026, 6, 7),
        );
        final futureReview = makeReview(
          id: 'review-3',
          scheduledFor: DateTime(2026, 6, 8),
        );
        final completedReview = makeReview(
          id: 'review-4',
          scheduledFor: DateTime(2026, 6, 6),
          reviewedAt: DateTime(2026, 6, 7),
          quality: ReviewQuality.good,
        );
        repository.reviews.addAll([
          overdueReview,
          todayReview,
          futureReview,
          completedReview,
        ]);

        // Act
        final reviews = await usecase(DateTime(2026, 6, 7));

        // Assert
        expect(reviews, [overdueReview, todayReview]);
      },
    );

    test('should call the repository', () async {
      // Arrange

      // Act
      await usecase(DateTime(2026, 6, 7));

      // Assert
      expect(repository.getReviewsWasCalled, isTrue);
    });
  });
}

Review makeReview({
  required String id,
  required DateTime scheduledFor,
  DateTime? reviewedAt,
  ReviewQuality? quality,
}) {
  return Review(
    id: id,
    topicId: 'topic-1',
    scheduledFor: scheduledFor,
    reviewedAt: reviewedAt,
    quality: quality,
    createdAt: DateTime(2026, 6, 1),
  );
}

class FakeReviewRepository implements ReviewRepository {
  final List<Review> reviews = [];
  bool getReviewsWasCalled = false;

  @override
  Future<void> createReview(Review review) async {
    reviews.add(review);
  }

  @override
  Future<Review?> getReviewById(String id) async {
    return reviews.where((review) => review.id == id).firstOrNull;
  }

  @override
  Future<List<Review>> getReviews() async {
    getReviewsWasCalled = true;
    return reviews;
  }

  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async {
    return reviews.where((review) => review.topicId == topicId).toList();
  }

  @override
  Future<void> updateReview(Review review) async {
    final reviewIndex = reviews.indexWhere(
      (currentReview) => currentReview.id == review.id,
    );

    if (reviewIndex >= 0) {
      reviews[reviewIndex] = review;
    }
  }
}
