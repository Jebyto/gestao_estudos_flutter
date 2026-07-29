import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_review_overview.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';

void main() {
  late FakeSubjectRepository subjectRepository;
  late FakeTopicRepository topicRepository;
  late FakeReviewRepository reviewRepository;
  late GetReviewOverview useCase;
  final createdAt = DateTime(2026, 7, 10);

  setUp(() {
    subjectRepository = FakeSubjectRepository();
    topicRepository = FakeTopicRepository();
    reviewRepository = FakeReviewRepository();
    useCase = GetReviewOverview(
      subjectRepository: subjectRepository,
      topicRepository: topicRepository,
      reviewRepository: reviewRepository,
    );
  });

  test('deve retornar listas vazias quando não houver dados', () async {
    final overview = await useCase();

    expect(overview.pendingReviews, isEmpty);
    expect(overview.completedReviews, isEmpty);
  });

  test('deve relacionar revisão com tópico e matéria', () async {
    final subject = Subject(
      id: 'subject-1',
      name: 'Banco de Dados',
      createdAt: createdAt,
    );
    final topic = Topic(
      id: 'topic-1',
      subjectId: subject.id,
      title: 'Normalização',
      status: TopicStatus.review,
      priority: TopicPriority.high,
      createdAt: createdAt,
    );
    final review = Review(
      id: 'review-1',
      topicId: topic.id,
      scheduledFor: createdAt.add(const Duration(days: 7)),
      createdAt: createdAt,
    );
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(topic);
    reviewRepository.reviews.add(review);

    final overview = await useCase();

    expect(overview.pendingReviews, hasLength(1));
    expect(overview.pendingReviews.first.review, review);
    expect(overview.pendingReviews.first.topic, topic);
    expect(overview.pendingReviews.first.subject, subject);
    expect(overview.completedReviews, isEmpty);
  });

  test('deve ordenar pendentes e concluídas pelas datas relevantes', () async {
    final subject = Subject(
      id: 'subject-1',
      name: 'Português',
      createdAt: createdAt,
    );
    final topic = Topic(
      id: 'topic-1',
      subjectId: subject.id,
      title: 'Gramática',
      status: TopicStatus.review,
      priority: TopicPriority.medium,
      createdAt: createdAt,
    );
    final laterPending = _review(
      id: 'pending-later',
      topicId: topic.id,
      scheduledFor: createdAt.add(const Duration(days: 7)),
    );
    final earlierPending = _review(
      id: 'pending-earlier',
      topicId: topic.id,
      scheduledFor: createdAt.add(const Duration(days: 1)),
    );
    final olderCompleted = _review(
      id: 'completed-older',
      topicId: topic.id,
      scheduledFor: createdAt,
      reviewedAt: createdAt.add(const Duration(days: 2)),
      quality: ReviewQuality.hard,
    );
    final recentCompleted = _review(
      id: 'completed-recent',
      topicId: topic.id,
      scheduledFor: createdAt,
      reviewedAt: createdAt.add(const Duration(days: 4)),
      quality: ReviewQuality.easy,
    );
    subjectRepository.subjects.add(subject);
    topicRepository.topics.add(topic);
    reviewRepository.reviews.addAll([
      laterPending,
      olderCompleted,
      earlierPending,
      recentCompleted,
    ]);

    final overview = await useCase();

    expect(overview.pendingReviews.map((item) => item.review), [
      earlierPending,
      laterPending,
    ]);
    expect(overview.completedReviews.map((item) => item.review), [
      recentCompleted,
      olderCompleted,
    ]);
  });

  test('deve ignorar revisão sem tópico conhecido', () async {
    reviewRepository.reviews.add(
      _review(
        id: 'review-1',
        topicId: 'missing-topic',
        scheduledFor: createdAt,
      ),
    );

    final overview = await useCase();

    expect(overview.pendingReviews, isEmpty);
    expect(overview.completedReviews, isEmpty);
  });
}

Review _review({
  required String id,
  required String topicId,
  required DateTime scheduledFor,
  DateTime? reviewedAt,
  ReviewQuality? quality,
}) {
  return Review(
    id: id,
    topicId: topicId,
    scheduledFor: scheduledFor,
    reviewedAt: reviewedAt,
    quality: quality,
    createdAt: DateTime(2026, 7, 10),
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
  Future<void> createReview(Review review) async {}

  @override
  Future<Review?> getReviewById(String id) async => null;

  @override
  Future<List<Review>> getReviews() async => reviews;

  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async => [];

  @override
  Future<void> updateReview(Review review) async {}
}
