import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/errors/review_exceptions.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';

void main() {
  group('CompleteReview', () {
    late FakeReviewRepository repository;
    late CompleteReview usecase;

    setUp(() {
      repository = FakeReviewRepository();
      usecase = CompleteReview(
        repository,
        generateReviewId: () => 'review-next',
      );
    });

    test('should complete a review', () async {
      // Arrange
      final review = makeReview(id: 'review-1');
      final reviewedAt = DateTime(2026, 6, 7);
      repository.reviews.add(review);

      // Act
      await usecase(
        reviewId: review.id,
        quality: ReviewQuality.good,
        reviewedAt: reviewedAt,
      );

      // Assert
      final completedReview = repository.reviews.firstWhere(
        (currentReview) => currentReview.id == review.id,
      );
      expect(completedReview.reviewedAt, reviewedAt);
      expect(completedReview.quality, ReviewQuality.good);
      expect(completedReview.isCompleted, isTrue);
    });

    test('should create the next review using the scheduler', () async {
      // Arrange
      final review = makeReview(id: 'review-1', topicId: 'topic-1');
      final reviewedAt = DateTime(2026, 6, 7);
      repository.reviews.add(review);

      // Act
      await usecase(
        reviewId: review.id,
        quality: ReviewQuality.good,
        reviewedAt: reviewedAt,
      );

      // Assert
      final nextReview = repository.reviews.firstWhere(
        (currentReview) => currentReview.id == 'review-next',
      );
      expect(nextReview.topicId, 'topic-1');
      expect(nextReview.scheduledFor, DateTime(2026, 6, 10));
      expect(nextReview.reviewedAt, isNull);
      expect(nextReview.quality, isNull);
      expect(nextReview.createdAt, reviewedAt);
    });

    test(
      'should call the repository when completing and creating reviews',
      () async {
        // Arrange
        final review = makeReview(id: 'review-1');
        repository.reviews.add(review);

        // Act
        await usecase(
          reviewId: review.id,
          quality: ReviewQuality.easy,
          reviewedAt: DateTime(2026, 6, 7),
        );

        // Assert
        expect(repository.getReviewByIdWasCalled, isTrue);
        expect(repository.updateReviewWasCalled, isTrue);
        expect(repository.createReviewWasCalled, isTrue);
      },
    );

    test('should throw an error when reviewId is empty', () async {
      // Arrange

      // Act
      Future<void> action() => usecase(
        reviewId: '',
        quality: ReviewQuality.good,
        reviewedAt: DateTime(2026, 6, 7),
      );

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyReviewIdException>().having(
            (error) => error.message,
            'message',
            'Review id is required.',
          ),
        ),
      );
    });

    test('should throw an error when reviewId has only spaces', () async {
      // Arrange

      // Act
      Future<void> action() => usecase(
        reviewId: '   ',
        quality: ReviewQuality.good,
        reviewedAt: DateTime(2026, 6, 7),
      );

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyReviewIdException>().having(
            (error) => error.message,
            'message',
            'Review id is required.',
          ),
        ),
      );
    });

    test('should throw an error when review is not found', () async {
      // Arrange

      // Act
      Future<void> action() => usecase(
        reviewId: 'review-1',
        quality: ReviewQuality.good,
        reviewedAt: DateTime(2026, 6, 7),
      );

      // Assert
      expect(
        action,
        throwsA(
          isA<ReviewNotFoundException>().having(
            (error) => error.message,
            'message',
            'Review was not found.',
          ),
        ),
      );
    });
  });
}

Review makeReview({required String id, String topicId = 'topic-1'}) {
  return Review(
    id: id,
    topicId: topicId,
    scheduledFor: DateTime(2026, 6, 7),
    createdAt: DateTime(2026, 6, 1),
  );
}

class FakeReviewRepository implements ReviewRepository {
  final List<Review> reviews = [];
  bool createReviewWasCalled = false;
  bool getReviewByIdWasCalled = false;
  bool updateReviewWasCalled = false;

  @override
  Future<void> createReview(Review review) async {
    createReviewWasCalled = true;
    reviews.add(review);
  }

  @override
  Future<Review?> getReviewById(String id) async {
    getReviewByIdWasCalled = true;
    return reviews.where((review) => review.id == id).firstOrNull;
  }

  @override
  Future<List<Review>> getReviews() async {
    return reviews;
  }

  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async {
    return reviews.where((review) => review.topicId == topicId).toList();
  }

  @override
  Future<void> updateReview(Review review) async {
    updateReviewWasCalled = true;
    final reviewIndex = reviews.indexWhere(
      (currentReview) => currentReview.id == review.id,
    );

    if (reviewIndex >= 0) {
      reviews[reviewIndex] = review;
    }
  }
}
