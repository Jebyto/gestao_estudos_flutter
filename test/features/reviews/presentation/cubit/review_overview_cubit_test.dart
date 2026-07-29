import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';
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
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
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
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {}
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
  Future<List<Review>> getReviews() async => reviews;

  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async {
    return reviews.where((review) => review.topicId == topicId).toList();
  }

  @override
  Future<void> updateReview(Review review) async {
    final index = reviews.indexWhere((item) => item.id == review.id);
    reviews[index] = review;
  }
}
