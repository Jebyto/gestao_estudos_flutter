import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';

void main() {
  group('Review', () {
    test('should create a valid pending review', () {
      // Arrange
      final scheduledFor = DateTime(2026, 6, 10);
      final createdAt = DateTime(2026, 6, 7);

      // Act
      final review = Review(
        id: 'review-1',
        topicId: 'topic-1',
        scheduledFor: scheduledFor,
        createdAt: createdAt,
      );

      // Assert
      expect(review.id, 'review-1');
      expect(review.topicId, 'topic-1');
      expect(review.scheduledFor, scheduledFor);
      expect(review.reviewedAt, isNull);
      expect(review.quality, isNull);
      expect(review.createdAt, createdAt);
    });

    test('should identify a pending review', () {
      // Arrange
      final review = makeReview();

      // Act

      // Assert
      expect(review.isPending, isTrue);
      expect(review.isCompleted, isFalse);
    });

    test('should identify a completed review', () {
      // Arrange
      final review = makeReview(
        reviewedAt: DateTime(2026, 6, 7),
        quality: ReviewQuality.good,
      );

      // Act

      // Assert
      expect(review.isPending, isFalse);
      expect(review.isCompleted, isTrue);
    });

    test('should compare reviews by value', () {
      // Arrange
      final firstReview = makeReview(
        reviewedAt: DateTime(2026, 6, 7),
        quality: ReviewQuality.easy,
      );
      final secondReview = makeReview(
        reviewedAt: DateTime(2026, 6, 7),
        quality: ReviewQuality.easy,
      );

      // Act

      // Assert
      expect(firstReview, secondReview);
    });
  });
}

Review makeReview({DateTime? reviewedAt, ReviewQuality? quality}) {
  return Review(
    id: 'review-1',
    topicId: 'topic-1',
    scheduledFor: DateTime(2026, 6, 10),
    reviewedAt: reviewedAt,
    quality: quality,
    createdAt: DateTime(2026, 6, 7),
  );
}
