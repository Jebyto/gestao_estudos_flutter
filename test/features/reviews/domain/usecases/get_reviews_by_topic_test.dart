import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/errors/review_exceptions.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_reviews_by_topic.dart';

void main() {
  group('GetReviewsByTopic', () {
    late FakeReviewRepository repository;
    late GetReviewsByTopic usecase;

    setUp(() {
      repository = FakeReviewRepository();
      usecase = GetReviewsByTopic(repository);
    });

    test('should return an empty list when the topic has no reviews', () async {
      // Arrange
      const topicId = 'topic-1';

      // Act
      final reviews = await usecase(topicId);

      // Assert
      expect(reviews, isEmpty);
    });

    test('should return the reviews from a topic', () async {
      // Arrange
      const topicId = 'topic-1';
      final firstReview = makeReview(id: 'review-1', topicId: topicId);
      final secondReview = makeReview(id: 'review-2', topicId: topicId);
      final anotherTopicReview = makeReview(id: 'review-3', topicId: 'topic-2');
      repository.reviews.addAll([
        firstReview,
        secondReview,
        anotherTopicReview,
      ]);

      // Act
      final reviews = await usecase(topicId);

      // Assert
      expect(reviews, [firstReview, secondReview]);
    });

    test('should call the repository with the correct topicId', () async {
      // Arrange
      const topicId = 'topic-1';

      // Act
      await usecase(topicId);

      // Assert
      expect(repository.getReviewsByTopicWasCalled, isTrue);
      expect(repository.receivedTopicId, topicId);
    });

    test('should throw an error when topicId is empty', () async {
      // Arrange

      // Act
      Future<List<Review>> action() => usecase('');

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

      // Act
      Future<List<Review>> action() => usecase('   ');

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

Review makeReview({required String id, required String topicId}) {
  return Review(
    id: id,
    topicId: topicId,
    scheduledFor: DateTime(2026, 6, 10),
    createdAt: DateTime(2026, 6, 7),
  );
}

class FakeReviewRepository implements ReviewRepository {
  final List<Review> reviews = [];
  bool getReviewsByTopicWasCalled = false;
  String? receivedTopicId;

  @override
  Future<void> createReview(Review review) async {
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
    getReviewsByTopicWasCalled = true;
    receivedTopicId = topicId;
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
