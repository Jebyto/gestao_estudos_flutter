import '../../domain/entities/review.dart';

String reviewQualityLabel(ReviewQuality quality) {
  return switch (quality) {
    ReviewQuality.hard => 'Difícil',
    ReviewQuality.good => 'Boa',
    ReviewQuality.easy => 'Fácil',
  };
}

String formatReviewDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day/$month/$year';
}
