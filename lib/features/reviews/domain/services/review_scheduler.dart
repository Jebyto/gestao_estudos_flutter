import '../entities/review.dart';

class ReviewScheduler {
  const ReviewScheduler();

  DateTime calculateNextReviewDate({
    required ReviewQuality quality,
    required DateTime baseDate,
  }) {
    return switch (quality) {
      ReviewQuality.hard => baseDate.add(const Duration(days: 1)),
      ReviewQuality.good => baseDate.add(const Duration(days: 3)),
      ReviewQuality.easy => baseDate.add(const Duration(days: 7)),
    };
  }
}
