import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/cancel_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/reschedule_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_review_overview.dart';
import 'package:gestao_estudos_flutter/features/reviews/presentation/cubit/review_overview_cubit.dart';
import 'package:gestao_estudos_flutter/features/reviews/presentation/cubit/review_overview_state.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';

void main() {
  late FakeSubjectRepository subjectRepository;
  late FakeTopicRepository topicRepository;
  late FakeReviewRepository reviewRepository;
  late ReviewOverviewCubit cubit;
  final today = DateTime(2026, 7, 10, 9);

  setUp(() {
    subjectRepository = FakeSubjectRepository();
    topicRepository = FakeTopicRepository();
    reviewRepository = FakeReviewRepository();
    cubit = ReviewOverviewCubit(
      getReviewOverview: GetReviewOverview(
        subjectRepository: subjectRepository,
        topicRepository: topicRepository,
        reviewRepository: reviewRepository,
      ),
      completeReviewUseCase: CompleteReview(
        reviewRepository,
        generateReviewId: () => 'review-next',
      ),
      cancelReviewUseCase: CancelReview(reviewRepository),
      rescheduleReviewUseCase: RescheduleReview(
        reviewRepository,
        now: () => today,
      ),
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('cancela pendência futura preservando histórico', () async {
    final subject = _subject(today);
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(_topic(subject, today));
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
    reviewRepository.reviews.addAll([pending, history]);
    await cubit.loadOverview();
    await cubit.cancelReview(pending.id);
    expect(
      cubit.state.overview!.pendingReviews.map((item) => item.review).toList(),
      isEmpty,
    );
    expect(
      cubit.state.overview!.completedReviews
          .map((item) => item.review)
          .toList(),
      [history],
    );
    expect(reviewRepository.reviews, [history]);
  });

  test('reagenda pendência e recarrega em ordem de data', () async {
    final subject = _subject(today);
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(_topic(subject, today));
    reviewRepository.reviews.addAll([
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
    final pending = cubit.state.overview!.pendingReviews
        .map((item) => item.review)
        .toList();
    expect(pending.map((r) => r.id), ['second', 'first']);
    expect(pending.last.scheduledFor, date);
  });

  test('mantém a lista e informa falhas de gravação', () async {
    final subject = _subject(today);
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(_topic(subject, today));
    final review = Review(
      id: 'pending',
      topicId: 'topic-1',
      scheduledFor: today,
      createdAt: today,
    );
    reviewRepository.reviews.add(review);
    await cubit.loadOverview();
    reviewRepository.failWrites = true;
    await cubit.cancelReview(review.id);
    expect(cubit.state.errorMessage, 'Não foi possível cancelar a revisão.');
    expect(
      cubit.state.overview!.pendingReviews.map((item) => item.review).toList(),
      [review],
    );
    await cubit.rescheduleReview(review.id, today);
    expect(cubit.state.errorMessage, 'Não foi possível reagendar a revisão.');
    expect(
      cubit.state.overview!.pendingReviews.map((item) => item.review).toList(),
      [review],
    );
  });

  test('explica data inválida e permite tentar novamente', () async {
    final subject = _subject(today);
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(_topic(subject, today));
    reviewRepository.reviews.add(
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
    final subject = _subject(today);
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(_topic(subject, today));
    reviewRepository.reviews.add(
      Review(
        id: 'pending',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
      ),
    );
    final gate = Completer<void>();
    reviewRepository.deleteGate = gate.future;
    final operation = cubit.cancelReview('pending');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isSubmitting, isTrue);
    await cubit.loadOverview();
    expect(cubit.state.isSubmitting, isTrue);
    await cubit.cancelReview('pending');
    await cubit.rescheduleReview('pending', today);
    await cubit.completeReview(
      reviewId: 'pending',
      quality: ReviewQuality.good,
    );
    gate.complete();
    await operation;
    expect(reviewRepository.deleteCalls, 1);
    expect(reviewRepository.reviews, isEmpty);
  });

  test('deve carregar a visão global de revisões', () async {
    final subject = _subject(today);
    final topic = _topic(subject, today);
    final review = _review(topic, today);
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(topic);
    reviewRepository.reviews.add(review);

    await cubit.loadOverview();

    expect(cubit.state.status, ReviewOverviewStatus.success);
    expect(cubit.state.overview?.pendingReviews.single.review, review);
    expect(cubit.state.overview?.pendingReviews.single.topic, topic);
    expect(cubit.state.overview?.pendingReviews.single.subject, subject);
  });

  test('deve concluir revisão e recarregar a visão global', () async {
    final subject = _subject(today);
    final topic = _topic(subject, today);
    final review = _review(topic, today);
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(topic);
    reviewRepository.reviews.add(review);

    await cubit.completeReview(
      reviewId: review.id,
      quality: ReviewQuality.good,
    );

    expect(cubit.state.status, ReviewOverviewStatus.success);
    expect(
      cubit.state.overview?.completedReviews.single.review.reviewedAt,
      today,
    );
    expect(
      cubit.state.overview?.completedReviews.single.review.quality,
      ReviewQuality.good,
    );
    expect(
      cubit.state.overview?.pendingReviews.single.review.id,
      'review-next',
    );
  });
}

Subject _subject(DateTime createdAt) {
  return Subject(id: 'subject-1', name: 'Banco de Dados', createdAt: createdAt);
}

Topic _topic(Subject subject, DateTime createdAt) {
  return Topic(
    id: 'topic-1',
    subjectId: subject.id,
    title: 'Normalização',
    status: TopicStatus.review,
    priority: TopicPriority.high,
    createdAt: createdAt,
  );
}

Review _review(Topic topic, DateTime createdAt) {
  return Review(
    id: 'review-1',
    topicId: topic.id,
    scheduledFor: createdAt,
    createdAt: createdAt,
  );
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects = [];

  @override
  Future<void> createSubject(Subject subject) async {}

  @override
  Future<void> updateSubject(Subject subject) async {}

  @override
  Future<void> deleteSubject(String id) async {}

  @override
  Future<List<Subject>> getSubjects() async => subjects;
}

class FakeTopicRepository implements TopicRepository {
  final List<Topic> topics = [];

  @override
  Future<void> createTopic(Topic topic) async {}

  @override
  Future<void> deleteTopic(String id) async {}

  @override
  Future<List<Topic>> getTopicsBySubject(String subjectId) async {
    return topics.where((topic) => topic.subjectId == subjectId).toList();
  }

  @override
  Future<void> updateTopic(Topic topic) async {}

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {}
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
  Future<List<Review>> getReviews() async => reviews;

  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async {
    return reviews.where((review) => review.topicId == topicId).toList();
  }

  @override
  Future<void> updateReview(Review review) async {
    if (failWrites) throw StateError('write failed');
    final index = reviews.indexWhere((item) => item.id == review.id);
    reviews[index] = review;
  }
}
