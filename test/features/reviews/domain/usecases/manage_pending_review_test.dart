import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/errors/review_exceptions.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/cancel_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/reschedule_review.dart';

void main() {
  final today = DateTime(2026, 9, 7, 15);
  late MemoryReviewRepository repository;
  late CancelReview cancel;
  late RescheduleReview reschedule;
  Review makeReview(String id, {bool completed = false}) => Review(
    id: id,
    topicId: 'topic-1',
    scheduledFor: DateTime(2026, 9, 1),
    createdAt: DateTime(2026, 8, 1),
    reviewedAt: completed ? today : null,
    quality: completed ? ReviewQuality.good : null,
  );

  setUp(() {
    repository = MemoryReviewRepository();
    cancel = CancelReview(repository);
    reschedule = RescheduleReview(repository, now: () => today);
  });

  test(
    'cancel removes only the pending record and preserves history',
    () async {
      final history = makeReview('history', completed: true);
      repository.reviews.addAll([history, makeReview('pending')]);
      await cancel('pending');
      expect(repository.reviews, [history]);
    },
  );

  for (final id in ['', '   ']) {
    test('rejects blank id "$id" before writing', () async {
      await expectLater(cancel(id), throwsA(isA<EmptyReviewIdException>()));
      await expectLater(
        reschedule(reviewId: id, scheduledFor: today),
        throwsA(isA<EmptyReviewIdException>()),
      );
      expect(repository.writes, 0);
    });
  }

  test('rejects missing and completed reviews', () async {
    await expectLater(
      cancel('missing'),
      throwsA(isA<ReviewNotFoundException>()),
    );
    await expectLater(
      reschedule(reviewId: 'missing', scheduledFor: today),
      throwsA(isA<ReviewNotFoundException>()),
    );
    final completed = makeReview('completed', completed: true);
    repository.reviews.add(completed);
    await expectLater(
      cancel(completed.id),
      throwsA(isA<ReviewAlreadyCompletedException>()),
    );
    await expectLater(
      reschedule(reviewId: completed.id, scheduledFor: today),
      throwsA(isA<ReviewAlreadyCompletedException>()),
    );
    expect(repository.reviews, [completed]);
    expect(repository.writes, 0);
  });

  test(
    'reschedules today or future preserving identity and creation',
    () async {
      final original = makeReview('pending');
      repository.reviews.add(original);
      for (final date in [DateTime(2026, 9, 7), DateTime(2027, 1, 1)]) {
        await reschedule(reviewId: original.id, scheduledFor: date);
        expect(
          repository.reviews.single,
          Review(
            id: original.id,
            topicId: original.topicId,
            scheduledFor: date,
            createdAt: original.createdAt,
          ),
        );
      }
    },
  );

  test('rejects past calendar dates without modifying the review', () async {
    final original = makeReview('pending');
    repository.reviews.add(original);
    await expectLater(
      reschedule(
        reviewId: original.id,
        scheduledFor: DateTime(2026, 9, 6, 23, 59),
      ),
      throwsA(isA<InvalidReviewScheduleException>()),
    );
    expect(repository.reviews, [original]);
    expect(repository.writes, 0);
  });

  test('propagates persistence errors', () async {
    repository.reviews.add(makeReview('pending'));
    repository.failWrites = true;
    await expectLater(cancel('pending'), throwsStateError);
    await expectLater(
      reschedule(reviewId: 'pending', scheduledFor: today),
      throwsStateError,
    );
    expect(repository.reviews.single.id, 'pending');
  });
}

class MemoryReviewRepository implements ReviewRepository {
  final reviews = <Review>[];
  int writes = 0;
  bool failWrites = false;
  @override
  Future<void> deleteReview(String id) async {
    if (failWrites) throw StateError('write failed');
    writes++;
    reviews.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> updateReview(Review review) async {
    if (failWrites) throw StateError('write failed');
    writes++;
    reviews[reviews.indexWhere((r) => r.id == review.id)] = review;
  }

  @override
  Future<void> createReview(Review review) async => reviews.add(review);
  @override
  Future<Review?> getReviewById(String id) async =>
      reviews.where((r) => r.id == id).firstOrNull;
  @override
  Future<List<Review>> getReviews() async => reviews;
  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async =>
      reviews.where((r) => r.topicId == topicId).toList();
}
