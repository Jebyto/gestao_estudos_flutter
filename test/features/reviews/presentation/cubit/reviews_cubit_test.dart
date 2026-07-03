import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/create_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_pending_reviews.dart';
import 'package:gestao_estudos_flutter/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:gestao_estudos_flutter/features/reviews/presentation/cubit/reviews_state.dart';

void main() {
  late FakeReviewRepository repository;
  late ReviewsCubit cubit;
  final today = DateTime(2026, 7, 3, 9);

  setUp(() {
    repository = FakeReviewRepository();
    cubit = ReviewsCubit(
      topicIds: const ['topic-1', 'topic-2'],
      getPendingReviews: GetPendingReviews(repository),
      createReviewUseCase: CreateReview(repository),
      completeReviewUseCase: CompleteReview(
        repository,
        generateReviewId: () => 'review-next',
      ),
      generateReviewId: () => 'review-1',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('deve iniciar com estado initial e lista vazia', () {
    expect(cubit.state.status, ReviewsStatus.initial);
    expect(cubit.state.pendingReviews, isEmpty);
  });

  test('deve carregar revisões pendentes dos tópicos da matéria', () async {
    final review = Review(
      id: 'review-1',
      topicId: 'topic-1',
      scheduledFor: today,
      createdAt: today,
    );
    repository.reviews.add(review);
    repository.reviews.add(
      Review(
        id: 'review-2',
        topicId: 'topic-3',
        scheduledFor: today,
        createdAt: today,
      ),
    );

    await cubit.loadPendingReviews();

    expect(cubit.state.status, ReviewsStatus.success);
    expect(cubit.state.pendingReviews, [review]);
  });

  test('deve criar uma revisão pendente e recarregar a lista', () async {
    final created = await cubit.createReview(topicId: 'topic-1');

    expect(created, isTrue);
    expect(repository.reviews.length, 1);
    expect(repository.reviews.first.id, 'review-1');
    expect(repository.reviews.first.topicId, 'topic-1');
    expect(repository.reviews.first.scheduledFor, today);
    expect(repository.reviews.first.createdAt, today);
    expect(cubit.state.status, ReviewsStatus.success);
    expect(cubit.state.pendingReviews, repository.reviews);
  });

  test('deve rejeitar criação quando tópico estiver vazio', () async {
    final created = await cubit.createReview(topicId: '   ');

    expect(created, isFalse);
    expect(repository.reviews, isEmpty);
    expect(cubit.state.status, ReviewsStatus.failure);
    expect(cubit.state.errorMessage, 'Selecione um tópico para revisar.');
  });

  test('deve concluir revisão e criar a próxima', () async {
    repository.reviews.add(
      Review(
        id: 'review-1',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
      ),
    );

    await cubit.completeReview(
      reviewId: 'review-1',
      quality: ReviewQuality.good,
    );

    expect(repository.reviews.length, 2);
    expect(repository.reviews.first.reviewedAt, today);
    expect(repository.reviews.first.quality, ReviewQuality.good);
    expect(repository.reviews.last.id, 'review-next');
    expect(
      repository.reviews.last.scheduledFor,
      today.add(const Duration(days: 3)),
    );
    expect(cubit.state.status, ReviewsStatus.success);
    expect(cubit.state.pendingReviews, isEmpty);
  });
}

class FakeReviewRepository implements ReviewRepository {
  final List<Review> reviews = [];

  @override
  Future<void> createReview(Review review) async {
    reviews.add(review);
  }

  @override
  Future<Review?> getReviewById(String id) async {
    for (final review in reviews) {
      if (review.id == id) return review;
    }

    return null;
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
    final index = reviews.indexWhere((currentReview) {
      return currentReview.id == review.id;
    });

    reviews[index] = review;
  }
}
