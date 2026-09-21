import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_local_datasource.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewLocalDataSource localDataSource;
  final Future<void> Function()? onChanged;

  const ReviewRepositoryImpl(this.localDataSource, {this.onChanged});

  @override
  Future<void> deleteReview(String id) async {
    await localDataSource.deleteReview(id);
    await onChanged?.call();
  }

  @override
  Future<void> createReview(Review review) async {
    final model = ReviewModel.fromEntity(review);

    await localDataSource.createReview(model);
    await onChanged?.call();
  }

  @override
  Future<Review?> getReviewById(String id) async {
    final model = await localDataSource.getReviewById(id);

    return model?.toEntity();
  }

  @override
  Future<List<Review>> getReviews() async {
    final models = await localDataSource.getReviews();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async {
    final models = await localDataSource.getReviewsByTopic(topicId);

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateReview(Review review) async {
    final model = ReviewModel.fromEntity(review);

    await localDataSource.updateReview(model);
    await onChanged?.call();
  }
}
