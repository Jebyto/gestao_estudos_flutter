import '../../../subjects/domain/entities/subject.dart';
import '../../../subjects/domain/repositories/subject_repository.dart';
import '../../../topics/domain/entities/topic.dart';
import '../../../topics/domain/repositories/topic_repository.dart';
import '../entities/review.dart';
import '../entities/review_overview.dart';
import '../repositories/review_repository.dart';

class GetReviewOverview {
  final SubjectRepository subjectRepository;
  final TopicRepository topicRepository;
  final ReviewRepository reviewRepository;

  const GetReviewOverview({
    required this.subjectRepository,
    required this.topicRepository,
    required this.reviewRepository,
  });

  Future<ReviewOverview> call() async {
    final subjects = await subjectRepository.getSubjects();
    final topics = await _getTopics(subjects);
    final reviews = await reviewRepository.getReviews();
    final subjectsById = {for (final subject in subjects) subject.id: subject};
    final topicsById = {for (final topic in topics) topic.id: topic};
    final pendingReviews = <ReviewOverviewItem>[];
    final completedReviews = <ReviewOverviewItem>[];

    for (final review in reviews) {
      final item = _buildItem(
        review: review,
        topicsById: topicsById,
        subjectsById: subjectsById,
      );

      if (item == null) continue;

      if (review.isPending) {
        pendingReviews.add(item);
      } else {
        completedReviews.add(item);
      }
    }

    pendingReviews.sort((first, second) {
      return first.review.scheduledFor.compareTo(second.review.scheduledFor);
    });
    completedReviews.sort((first, second) {
      return second.review.reviewedAt!.compareTo(first.review.reviewedAt!);
    });

    return ReviewOverview(
      pendingReviews: pendingReviews,
      completedReviews: completedReviews,
    );
  }

  Future<List<Topic>> _getTopics(List<Subject> subjects) async {
    final topics = <Topic>[];

    for (final subject in subjects) {
      topics.addAll(await topicRepository.getTopicsBySubject(subject.id));
    }

    return topics;
  }

  ReviewOverviewItem? _buildItem({
    required Review review,
    required Map<String, Topic> topicsById,
    required Map<String, Subject> subjectsById,
  }) {
    final topic = topicsById[review.topicId];
    if (topic == null) return null;

    final subject = subjectsById[topic.subjectId];
    if (subject == null) return null;

    return ReviewOverviewItem(review: review, topic: topic, subject: subject);
  }
}
