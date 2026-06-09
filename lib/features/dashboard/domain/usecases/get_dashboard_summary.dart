import '../../../reviews/domain/entities/review.dart';
import '../../../reviews/domain/repositories/review_repository.dart';
import '../../../study_sessions/domain/entities/study_session.dart';
import '../../../study_sessions/domain/repositories/study_session_repository.dart';
import '../../../subjects/domain/entities/subject.dart';
import '../../../subjects/domain/repositories/subject_repository.dart';
import '../../../topics/domain/entities/topic.dart';
import '../../../topics/domain/repositories/topic_repository.dart';
import '../entities/dashboard_summary.dart';

typedef DateTimeProvider = DateTime Function();

class GetDashboardSummary {
  final SubjectRepository subjectRepository;
  final TopicRepository topicRepository;
  final StudySessionRepository studySessionRepository;
  final ReviewRepository reviewRepository;
  final DateTimeProvider now;

  GetDashboardSummary({
    required this.subjectRepository,
    required this.topicRepository,
    required this.studySessionRepository,
    required this.reviewRepository,
    DateTimeProvider? now,
  }) : now = now ?? DateTime.now;

  Future<DashboardSummary> call() async {
    final subjects = await subjectRepository.getSubjects();
    final topics = await _getTopics(subjects);
    final studySessions = await studySessionRepository.getStudySessions();
    final reviews = await reviewRepository.getReviews();

    final completedTopics = _countTopicsByStatus(
      topics: topics,
      status: TopicStatus.completed,
    );
    final studyingTopics = _countTopicsByStatus(
      topics: topics,
      status: TopicStatus.studying,
    );
    final mostStudiedSubject = _getMostStudiedSubject(
      subjects: subjects,
      studySessions: studySessions,
    );
    final nextReview = _getNextReview(
      reviews: reviews,
      topics: topics,
      subjects: subjects,
    );

    return DashboardSummary(
      totalSubjects: subjects.length,
      totalTopics: topics.length,
      completedTopics: completedTopics,
      studyingTopics: studyingTopics,
      pendingTopics: topics.length - completedTopics,
      totalStudyMinutesToday: _sumStudyMinutesToday(studySessions),
      totalStudyMinutesThisWeek: _sumStudyMinutesThisWeek(studySessions),
      progressPercentage: _calculateProgress(
        completedTopics: completedTopics,
        totalTopics: topics.length,
      ),
      mostStudiedSubjectId: mostStudiedSubject?.subject.id,
      mostStudiedSubjectName: mostStudiedSubject?.subject.name,
      mostStudiedSubjectMinutes: mostStudiedSubject?.minutes ?? 0,
      reviewsDueToday: _countReviewsDueToday(reviews),
      overdueReviews: _countOverdueReviews(reviews),
      completedReviewsThisWeek: _countCompletedReviewsThisWeek(reviews),
      nextReviewId: nextReview?.review.id,
      nextReviewTopicId: nextReview?.review.topicId,
      nextReviewTopicTitle: nextReview?.topic?.title,
      nextReviewSubjectName: nextReview?.subject?.name,
      nextReviewScheduledFor: nextReview?.review.scheduledFor,
    );
  }

  Future<List<Topic>> _getTopics(List<Subject> subjects) async {
    final topics = <Topic>[];

    for (final subject in subjects) {
      final subjectTopics = await topicRepository.getTopicsBySubject(
        subject.id,
      );
      topics.addAll(subjectTopics);
    }

    return topics;
  }

  int _countTopicsByStatus({
    required List<Topic> topics,
    required TopicStatus status,
  }) {
    return topics.where((topic) => topic.status == status).length;
  }

  int _sumStudyMinutesToday(List<StudySession> studySessions) {
    final currentDate = now();

    return studySessions
        .where(
          (studySession) => _isSameDay(studySession.studiedAt, currentDate),
        )
        .fold<int>(
          0,
          (total, studySession) => total + studySession.durationInMinutes,
        );
  }

  int _sumStudyMinutesThisWeek(List<StudySession> studySessions) {
    final currentDate = now();
    final startOfWeek = _startOfWeek(currentDate);
    final startOfNextWeek = startOfWeek.add(const Duration(days: 7));

    return studySessions
        .where((studySession) {
          final studiedAt = studySession.studiedAt;

          return !studiedAt.isBefore(startOfWeek) &&
              studiedAt.isBefore(startOfNextWeek);
        })
        .fold<int>(
          0,
          (total, studySession) => total + studySession.durationInMinutes,
        );
  }

  double _calculateProgress({
    required int completedTopics,
    required int totalTopics,
  }) {
    if (totalTopics == 0) return 0;

    return completedTopics / totalTopics * 100;
  }

  _MostStudiedSubject? _getMostStudiedSubject({
    required List<Subject> subjects,
    required List<StudySession> studySessions,
  }) {
    final minutesBySubjectId = <String, int>{};

    for (final studySession in studySessions) {
      minutesBySubjectId.update(
        studySession.subjectId,
        (minutes) => minutes + studySession.durationInMinutes,
        ifAbsent: () => studySession.durationInMinutes,
      );
    }

    _MostStudiedSubject? mostStudiedSubject;

    for (final subject in subjects) {
      final minutes = minutesBySubjectId[subject.id] ?? 0;

      if (minutes == 0) continue;

      if (mostStudiedSubject == null || minutes > mostStudiedSubject.minutes) {
        mostStudiedSubject = _MostStudiedSubject(
          subject: subject,
          minutes: minutes,
        );
      }
    }

    return mostStudiedSubject;
  }

  int _countReviewsDueToday(List<Review> reviews) {
    final currentDate = now();

    return reviews.where((review) {
      return review.isPending && _isSameDay(review.scheduledFor, currentDate);
    }).length;
  }

  int _countOverdueReviews(List<Review> reviews) {
    final startOfToday = _dateOnly(now());

    return reviews.where((review) {
      return review.isPending && review.scheduledFor.isBefore(startOfToday);
    }).length;
  }

  int _countCompletedReviewsThisWeek(List<Review> reviews) {
    final currentDate = now();
    final startOfWeek = _startOfWeek(currentDate);
    final startOfNextWeek = startOfWeek.add(const Duration(days: 7));

    return reviews.where((review) {
      final reviewedAt = review.reviewedAt;

      return reviewedAt != null &&
          !reviewedAt.isBefore(startOfWeek) &&
          reviewedAt.isBefore(startOfNextWeek);
    }).length;
  }

  _NextReview? _getNextReview({
    required List<Review> reviews,
    required List<Topic> topics,
    required List<Subject> subjects,
  }) {
    final pendingReviews = reviews.where((review) => review.isPending).toList()
      ..sort((firstReview, secondReview) {
        return firstReview.scheduledFor.compareTo(secondReview.scheduledFor);
      });

    if (pendingReviews.isEmpty) return null;

    final review = pendingReviews.first;
    final topic = _getTopicById(topics: topics, topicId: review.topicId);
    final subject = topic == null
        ? null
        : _getSubjectById(subjects: subjects, subjectId: topic.subjectId);

    return _NextReview(review: review, topic: topic, subject: subject);
  }

  Topic? _getTopicById({required List<Topic> topics, required String topicId}) {
    for (final topic in topics) {
      if (topic.id == topicId) return topic;
    }

    return null;
  }

  Subject? _getSubjectById({
    required List<Subject> subjects,
    required String subjectId,
  }) {
    for (final subject in subjects) {
      if (subject.id == subjectId) return subject;
    }

    return null;
  }

  bool _isSameDay(DateTime firstDate, DateTime secondDate) {
    return firstDate.year == secondDate.year &&
        firstDate.month == secondDate.month &&
        firstDate.day == secondDate.day;
  }

  DateTime _startOfWeek(DateTime date) {
    final dateOnly = _dateOnly(date);

    return dateOnly.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _MostStudiedSubject {
  final Subject subject;
  final int minutes;

  const _MostStudiedSubject({required this.subject, required this.minutes});
}

class _NextReview {
  final Review review;
  final Topic? topic;
  final Subject? subject;

  const _NextReview({
    required this.review,
    required this.topic,
    required this.subject,
  });
}
