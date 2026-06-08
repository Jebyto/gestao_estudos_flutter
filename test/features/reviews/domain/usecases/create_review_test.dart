import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/errors/review_exceptions.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/create_review.dart';

void main() {
  group('CreateReview', () {
    late FakeReviewRepository repository;
    late CreateReview usecase;

    setUp(() {
      repository = FakeReviewRepository();
      usecase = CreateReview(repository);
    });

    test('should create a valid review', () async {
      // Arrange
      final review = makeReview();

      // Act
      await usecase(review);

      // Assert
      expect(repository.reviews, contains(review));
    });

    test('should call the repository', () async {
      // Arrange
      final review = makeReview(id: 'review-2');

      // Act
      await usecase(review);

      // Assert
      expect(repository.createReviewWasCalled, isTrue);
      expect(repository.createdReview, review);
    });

    test('should throw an error when topicId is empty', () async {
      // Arrange
      final review = makeReview(topicId: '');

      // Act
      Future<void> action() => usecase(review);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyReviewTopicIdException>().having(
            (error) => error.message,
            'message',
            'Topic id is required.',
          ),
        ),
      );
    });

    test('should throw an error when topicId has only spaces', () async {
      // Arrange
      final review = makeReview(topicId: '   ');

      // Act
      Future<void> action() => usecase(review);

      // Assert
      expect(
        action,
        throwsA(
          isA<EmptyReviewTopicIdException>().having(
            (error) => error.message,
            'message',
            'Topic id is required.',
          ),
        ),
      );
    });
  });
}

Review makeReview({String id = 'review-1', String topicId = 'topic-1'}) {
  return Review(
    id: id,
    topicId: topicId,
    scheduledFor: DateTime(2026, 6, 10),
    createdAt: DateTime(2026, 6, 7),
  );
}

class FakeReviewRepository implements ReviewRepository {
  final List<Review> reviews = [];
  bool createReviewWasCalled = false;
  Review? createdReview;

  @override
  Future<void> createReview(Review review) async {
    createReviewWasCalled = true;
    createdReview = review;
    reviews.add(review);
  }

  @override
  Future<Review?> getReviewById(String id) async {
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
    final reviewIndex = reviews.indexWhere(
      (currentReview) => currentReview.id == review.id,
    );

    if (reviewIndex >= 0) {
      reviews[reviewIndex] = review;
    }
  }
}
