import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/services/review_scheduler.dart';

void main() {
  group('ReviewScheduler', () {
    late ReviewScheduler scheduler;

    setUp(() {
      scheduler = const ReviewScheduler();
    });

    test('should schedule a hard review for the next day', () {
      // Arrange
      final baseDate = DateTime(2026, 6, 7);

      // Act
      final nextReviewDate = scheduler.calculateNextReviewDate(
        quality: ReviewQuality.hard,
        baseDate: baseDate,
      );

      // Assert
      expect(nextReviewDate, DateTime(2026, 6, 8));
    });

    test('should schedule a good review in three days', () {
      // Arrange
      final baseDate = DateTime(2026, 6, 7);

      // Act
      final nextReviewDate = scheduler.calculateNextReviewDate(
        quality: ReviewQuality.good,
        baseDate: baseDate,
      );

      // Assert
      expect(nextReviewDate, DateTime(2026, 6, 10));
    });

    test('should schedule an easy review in seven days', () {
      // Arrange
      final baseDate = DateTime(2026, 6, 7);

      // Act
      final nextReviewDate = scheduler.calculateNextReviewDate(
        quality: ReviewQuality.easy,
        baseDate: baseDate,
      );

      // Assert
      expect(nextReviewDate, DateTime(2026, 6, 14));
    });
  });
}
