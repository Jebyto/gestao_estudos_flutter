import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_local_datasource.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewLocalDataSource localDataSource;

  const ReviewRepositoryImpl(this.localDataSource);

  @override
  Future<void> createReview(Review review) {
    final model = ReviewModel.fromEntity(review);

    return localDataSource.createReview(model);
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
  Future<void> updateReview(Review review) {
    final model = ReviewModel.fromEntity(review);

    return localDataSource.updateReview(model);
  }
}
