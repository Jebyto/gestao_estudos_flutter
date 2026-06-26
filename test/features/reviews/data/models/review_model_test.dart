import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/data/models/review_model.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';

void main() {
  group('ReviewModel', () {
    test('should create a model from a domain entity', () {
      // Arrange
      final review = makeReview();

      // Act
      final model = ReviewModel.fromEntity(review);

      // Assert
      expect(model.id, review.id);
      expect(model.topicId, review.topicId);
      expect(model.scheduledFor, review.scheduledFor);
      expect(model.reviewedAt, review.reviewedAt);
      expect(model.quality, review.quality);
      expect(model.createdAt, review.createdAt);
    });

    test('should convert a model to a domain entity', () {
      // Arrange
      final model = makeReviewModel();

      // Act
      final review = model.toEntity();

      // Assert
      expect(review, isA<Review>());
      expect(review.id, model.id);
      expect(review.topicId, model.topicId);
      expect(review.scheduledFor, model.scheduledFor);
      expect(review.reviewedAt, model.reviewedAt);
      expect(review.quality, model.quality);
      expect(review.createdAt, model.createdAt);
    });

    test('should convert a model to map', () {
      // Arrange
      final model = makeReviewModel();

      // Act
      final map = model.toMap();

      // Assert
      expect(map['id'], 'review-1');
      expect(map['topic_id'], 'topic-1');
      expect(map['scheduled_for'], DateTime(2026, 6, 25).toIso8601String());
      expect(map['reviewed_at'], DateTime(2026, 6, 26).toIso8601String());
      expect(map['quality'], 'good');
      expect(map['created_at'], DateTime(2026, 6, 24).toIso8601String());
    });

    test('should convert a map to model', () {
      // Arrange
      final map = {
        'id': 'review-1',
        'topic_id': 'topic-1',
        'scheduled_for': DateTime(2026, 6, 25).toIso8601String(),
        'reviewed_at': null,
        'quality': null,
        'created_at': DateTime(2026, 6, 24).toIso8601String(),
      };

      // Act
      final model = ReviewModel.fromMap(map);

      // Assert
      expect(model.id, 'review-1');
      expect(model.topicId, 'topic-1');
      expect(model.scheduledFor, DateTime(2026, 6, 25));
      expect(model.reviewedAt, isNull);
      expect(model.quality, isNull);
      expect(model.createdAt, DateTime(2026, 6, 24));
    });
  });
}

Review makeReview() {
  return Review(
    id: 'review-1',
    topicId: 'topic-1',
    scheduledFor: DateTime(2026, 6, 25),
    reviewedAt: DateTime(2026, 6, 26),
    quality: ReviewQuality.good,
    createdAt: DateTime(2026, 6, 24),
  );
}

ReviewModel makeReviewModel() {
  return ReviewModel(
    id: 'review-1',
    topicId: 'topic-1',
    scheduledFor: DateTime(2026, 6, 25),
    reviewedAt: DateTime(2026, 6, 26),
    quality: ReviewQuality.good,
    createdAt: DateTime(2026, 6, 24),
  );
}
