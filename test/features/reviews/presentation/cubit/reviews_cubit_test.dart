import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/cancel_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/reschedule_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/create_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_reviews_by_topic.dart';
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
      getReviewsByTopic: GetReviewsByTopic(repository),
      createReviewUseCase: CreateReview(repository),
      completeReviewUseCase: CompleteReview(
        repository,
        generateReviewId: () => 'review-next',
      ),
      cancelReviewUseCase: CancelReview(repository),
      rescheduleReviewUseCase: RescheduleReview(repository, now: () => today),
      generateReviewId: () => 'review-1',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('cancela pendência futura preservando histórico', () async {
    final pending = Review(
      id: 'pending',
      topicId: 'topic-1',
      scheduledFor: today.add(const Duration(days: 7)),
      createdAt: today,
    );
    final history = Review(
      id: 'history',
      topicId: 'topic-1',
      scheduledFor: today,
      reviewedAt: today,
      quality: ReviewQuality.good,
      createdAt: today,
    );
    repository.reviews.addAll([pending, history]);
    await cubit.loadReviews();
    await cubit.cancelReview(pending.id);
    expect(cubit.state.pendingReviews, isEmpty);
    expect(cubit.state.completedReviews, [history]);
    expect(repository.reviews, [history]);
  });

  test('reagenda pendência e recarrega em ordem de data', () async {
    repository.reviews.addAll([
      Review(
        id: 'first',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
      ),
      Review(
        id: 'second',
        topicId: 'topic-1',
        scheduledFor: today.add(const Duration(days: 1)),
        createdAt: today,
      ),
    ]);
    final date = today.add(const Duration(days: 7));
    await cubit.rescheduleReview('first', date);
    final pending = cubit.state.pendingReviews;
    expect(pending.map((r) => r.id), ['second', 'first']);
    expect(pending.last.scheduledFor, date);
  });

  test('mantém a lista e informa falhas de gravação', () async {
    final review = Review(
      id: 'pending',
      topicId: 'topic-1',
      scheduledFor: today,
      createdAt: today,
    );
    repository.reviews.add(review);
    await cubit.loadReviews();
    repository.failWrites = true;
    await cubit.cancelReview(review.id);
    expect(cubit.state.errorMessage, 'Não foi possível cancelar a revisão.');
    expect(cubit.state.pendingReviews, [review]);
    await cubit.rescheduleReview(review.id, today);
    expect(cubit.state.errorMessage, 'Não foi possível reagendar a revisão.');
    expect(cubit.state.pendingReviews, [review]);
  });

  test('explica data inválida e permite tentar novamente', () async {
    repository.reviews.add(
      Review(
        id: 'pending',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
      ),
    );
    await cubit.rescheduleReview(
      'pending',
      today.subtract(const Duration(days: 1)),
    );
    expect(cubit.state.errorMessage, 'Escolha hoje ou uma data futura.');
    await cubit.rescheduleReview('pending', today);
    expect(cubit.state.errorMessage, isNull);
  });

  test('ignora novas ações enquanto salva', () async {
    repository.reviews.add(
      Review(
        id: 'pending',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
      ),
    );
    final gate = Completer<void>();
    repository.deleteGate = gate.future;
    final operation = cubit.cancelReview('pending');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isSubmitting, isTrue);
    await cubit.loadReviews();
    expect(cubit.state.isSubmitting, isTrue);
    await cubit.cancelReview('pending');
    await cubit.rescheduleReview('pending', today);
    await cubit.completeReview(
      reviewId: 'pending',
      quality: ReviewQuality.good,
    );
    gate.complete();
    await operation;
    expect(repository.deleteCalls, 1);
    expect(repository.reviews, isEmpty);
  });

  test('deve iniciar com estado initial e lista vazia', () {
    expect(cubit.state.status, ReviewsStatus.initial);
    expect(cubit.state.pendingReviews, isEmpty);
    expect(cubit.state.completedReviews, isEmpty);
  });

  test('deve carregar revisões pendentes e concluídas da matéria', () async {
    final pendingReview = Review(
      id: 'review-1',
      topicId: 'topic-1',
      scheduledFor: today,
      createdAt: today,
    );
    final completedReview = Review(
      id: 'review-2',
      topicId: 'topic-2',
      scheduledFor: today.subtract(const Duration(days: 3)),
      reviewedAt: today.subtract(const Duration(days: 1)),
      quality: ReviewQuality.good,
      createdAt: today.subtract(const Duration(days: 3)),
    );
    repository.reviews.add(pendingReview);
    repository.reviews.add(completedReview);
    repository.reviews.add(
      Review(
        id: 'review-3',
        topicId: 'topic-3',
        scheduledFor: today,
        createdAt: today,
      ),
    );

    await cubit.loadReviews();

    expect(cubit.state.status, ReviewsStatus.success);
    expect(cubit.state.pendingReviews, [pendingReview]);
    expect(cubit.state.completedReviews, [completedReview]);
  });

  test('deve ordenar histórico pela conclusão mais recente', () async {
    final olderReview = Review(
      id: 'review-1',
      topicId: 'topic-1',
      scheduledFor: today.subtract(const Duration(days: 5)),
      reviewedAt: today.subtract(const Duration(days: 2)),
      quality: ReviewQuality.hard,
      createdAt: today.subtract(const Duration(days: 5)),
    );
    final recentReview = Review(
      id: 'review-2',
      topicId: 'topic-2',
      scheduledFor: today.subtract(const Duration(days: 3)),
      reviewedAt: today.subtract(const Duration(days: 1)),
      quality: ReviewQuality.easy,
      createdAt: today.subtract(const Duration(days: 3)),
    );
    repository.reviews.addAll([olderReview, recentReview]);

    await cubit.loadReviews();

    expect(cubit.state.completedReviews, [recentReview, olderReview]);
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
    expect(cubit.state.completedReviews, isEmpty);
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
    expect(cubit.state.pendingReviews, [repository.reviews.last]);
    expect(cubit.state.completedReviews, [repository.reviews.first]);
  });
}

class FakeReviewRepository implements ReviewRepository {
  bool failWrites = false;
  Future<void>? deleteGate;
  int deleteCalls = 0;
  @override
  Future<void> deleteReview(String id) async {
    deleteCalls++;
    await deleteGate;
    if (failWrites) throw StateError('write failed');
    reviews.removeWhere((review) => review.id == id);
  }

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
    if (failWrites) throw StateError('write failed');
    final index = reviews.indexWhere((currentReview) {
      return currentReview.id == review.id;
    });

    reviews[index] = review;
  }
}
