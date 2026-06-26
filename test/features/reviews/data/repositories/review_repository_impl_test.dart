import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/reviews/data/models/review_model.dart';
import 'package:gestao_estudos_flutter/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';

void main() {
  group('ReviewRepositoryImpl', () {
    late FakeReviewLocalDataSource localDataSource;
    late ReviewRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeReviewLocalDataSource();
      repository = ReviewRepositoryImpl(localDataSource);
    });

    test('should create a review using the local datasource', () async {
      // Arrange
      final review = makeReview(id: 'review-1');

      // Act
      await repository.createReview(review);

      // Assert
      expect(localDataSource.createReviewWasCalled, isTrue);
      expect(localDataSource.reviews.length, 1);
      expect(localDataSource.reviews.first.id, review.id);
      expect(localDataSource.reviews.first.topicId, review.topicId);
    });

    test('should return reviews as domain entities', () async {
      // Arrange
      localDataSource.reviews.add(makeReviewModel(id: 'review-1'));

      // Act
      final reviews = await repository.getReviews();

      // Assert
      expect(localDataSource.getReviewsWasCalled, isTrue);
      expect(reviews.length, 1);
      expect(reviews.first, isA<Review>());
      expect(reviews.first.id, 'review-1');
    });

    test('should return a review by id as a domain entity', () async {
      // Arrange
      localDataSource.reviews.add(makeReviewModel(id: 'review-1'));

      // Act
      final review = await repository.getReviewById('review-1');

      // Assert
      expect(localDataSource.getReviewByIdWasCalled, isTrue);
      expect(localDataSource.receivedReviewId, 'review-1');
      expect(review, isA<Review>());
      expect(review?.id, 'review-1');
    });

    test('should return null when review is not found', () async {
      // Arrange

      // Act
      final review = await repository.getReviewById('missing-review');

      // Assert
      expect(review, isNull);
    });

    test('should return reviews by topic as domain entities', () async {
      // Arrange
      localDataSource.reviews.addAll([
        makeReviewModel(id: 'review-1', topicId: 'topic-1'),
        makeReviewModel(id: 'review-2', topicId: 'topic-2'),
      ]);

      // Act
      final reviews = await repository.getReviewsByTopic('topic-1');

      // Assert
      expect(localDataSource.getReviewsByTopicWasCalled, isTrue);
      expect(localDataSource.receivedTopicId, 'topic-1');
      expect(reviews.length, 1);
      expect(reviews.first.topicId, 'topic-1');
    });

    test('should update a review using the local datasource', () async {
      // Arrange
      localDataSource.reviews.add(makeReviewModel(id: 'review-1'));
      final completedReview = makeReview(
        id: 'review-1',
        reviewedAt: DateTime(2026, 6, 25),
        quality: ReviewQuality.easy,
      );

      // Act
      await repository.updateReview(completedReview);

      // Assert
      expect(localDataSource.updateReviewWasCalled, isTrue);
      expect(localDataSource.reviews.first.reviewedAt, DateTime(2026, 6, 25));
      expect(localDataSource.reviews.first.quality, ReviewQuality.easy);
    });
  });
}

Review makeReview({
  required String id,
  String topicId = 'topic-1',
  DateTime? reviewedAt,
  ReviewQuality? quality,
}) {
  return Review(
    id: id,
    topicId: topicId,
    scheduledFor: DateTime(2026, 6, 25),
    reviewedAt: reviewedAt,
    quality: quality,
    createdAt: DateTime(2026, 6, 24),
  );
}

ReviewModel makeReviewModel({
  required String id,
  String topicId = 'topic-1',
  DateTime? reviewedAt,
  ReviewQuality? quality,
}) {
  return ReviewModel(
    id: id,
    topicId: topicId,
    scheduledFor: DateTime(2026, 6, 25),
    reviewedAt: reviewedAt,
    quality: quality,
    createdAt: DateTime(2026, 6, 24),
  );
}

class FakeReviewLocalDataSource implements ReviewLocalDataSource {
  final List<ReviewModel> reviews = [];
  bool createReviewWasCalled = false;
  bool getReviewsWasCalled = false;
  bool getReviewByIdWasCalled = false;
  bool getReviewsByTopicWasCalled = false;
  bool updateReviewWasCalled = false;
  String? receivedReviewId;
  String? receivedTopicId;

  @override
  Future<void> createReview(ReviewModel review) async {
    createReviewWasCalled = true;
    reviews.add(review);
  }

  @override
  Future<ReviewModel?> getReviewById(String id) async {
    getReviewByIdWasCalled = true;
    receivedReviewId = id;
    return reviews.where((review) => review.id == id).firstOrNull;
  }

  @override
  Future<List<ReviewModel>> getReviews() async {
    getReviewsWasCalled = true;
    return reviews;
  }

  @override
  Future<List<ReviewModel>> getReviewsByTopic(String topicId) async {
    getReviewsByTopicWasCalled = true;
    receivedTopicId = topicId;

    return reviews.where((review) => review.topicId == topicId).toList();
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    updateReviewWasCalled = true;
    final reviewIndex = reviews.indexWhere(
      (currentReview) => currentReview.id == review.id,
    );

    if (reviewIndex >= 0) {
      reviews[reviewIndex] = review;
    }
  }
}
