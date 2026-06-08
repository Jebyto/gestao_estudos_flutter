import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetPendingReviews {
  final ReviewRepository repository;

  const GetPendingReviews(this.repository);

  Future<List<Review>> call(DateTime referenceDate) async {
    final reviews = await repository.getReviews();

    return reviews.where((review) {
      return review.isPending && !review.scheduledFor.isAfter(referenceDate);
    }).toList();
  }
}
