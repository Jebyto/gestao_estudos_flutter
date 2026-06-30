import '../../features/dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../features/reviews/data/datasources/review_local_datasource.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/reviews/domain/usecases/complete_review.dart';
import '../../features/reviews/domain/usecases/create_review.dart';
import '../../features/reviews/domain/usecases/get_pending_reviews.dart';
import '../../features/reviews/domain/usecases/get_reviews_by_topic.dart';
import '../../features/study_sessions/data/datasources/study_session_local_datasource.dart';
import '../../features/study_sessions/data/repositories/study_session_repository_impl.dart';
import '../../features/study_sessions/domain/repositories/study_session_repository.dart';
import '../../features/study_sessions/domain/usecases/create_study_session.dart';
import '../../features/study_sessions/domain/usecases/delete_study_session.dart';
import '../../features/study_sessions/domain/usecases/get_study_sessions.dart';
import '../../features/study_sessions/domain/usecases/get_study_sessions_by_subject.dart';
import '../../features/subjects/data/datasources/subject_local_datasource.dart';
import '../../features/subjects/data/repositories/subject_repository_impl.dart';
import '../../features/subjects/domain/repositories/subject_repository.dart';
import '../../features/subjects/domain/usecases/create_subject.dart';
import '../../features/subjects/domain/usecases/delete_subject.dart';
import '../../features/subjects/domain/usecases/get_subjects.dart';
import '../../features/topics/data/datasources/topic_local_datasource.dart';
import '../../features/topics/data/repositories/topic_repository_impl.dart';
import '../../features/topics/domain/repositories/topic_repository.dart';
import '../../features/topics/domain/usecases/create_topic.dart';
import '../../features/topics/domain/usecases/delete_topic.dart';
import '../../features/topics/domain/usecases/get_topics_by_subject.dart';
import '../../features/topics/domain/usecases/update_topic_status.dart';
import '../database/app_database.dart';

class AppDependencies {
  final AppDatabase appDatabase;
  final DateTimeProvider? now;
  final ReviewIdGenerator? generateReviewId;

  AppDependencies({AppDatabase? appDatabase, this.now, this.generateReviewId})
    : appDatabase = appDatabase ?? AppDatabase();

  late final SubjectLocalDataSource subjectLocalDataSource =
      SubjectLocalDataSourceImpl(appDatabase);
  late final SubjectRepository subjectRepository = SubjectRepositoryImpl(
    subjectLocalDataSource,
  );
  late final CreateSubject createSubject = CreateSubject(subjectRepository);
  late final GetSubjects getSubjects = GetSubjects(subjectRepository);
  late final DeleteSubject deleteSubject = DeleteSubject(subjectRepository);

  late final TopicLocalDataSource topicLocalDataSource =
      TopicLocalDataSourceImpl(appDatabase);
  late final TopicRepository topicRepository = TopicRepositoryImpl(
    topicLocalDataSource,
  );
  late final CreateTopic createTopic = CreateTopic(topicRepository);
  late final GetTopicsBySubject getTopicsBySubject = GetTopicsBySubject(
    topicRepository,
  );
  late final UpdateTopicStatus updateTopicStatus = UpdateTopicStatus(
    topicRepository,
  );
  late final DeleteTopic deleteTopic = DeleteTopic(topicRepository);

  late final StudySessionLocalDataSource studySessionLocalDataSource =
      StudySessionLocalDataSourceImpl(appDatabase);
  late final StudySessionRepository studySessionRepository =
      StudySessionRepositoryImpl(studySessionLocalDataSource);
  late final CreateStudySession createStudySession = CreateStudySession(
    studySessionRepository,
  );
  late final GetStudySessions getStudySessions = GetStudySessions(
    studySessionRepository,
  );
  late final GetStudySessionsBySubject getStudySessionsBySubject =
      GetStudySessionsBySubject(studySessionRepository);
  late final DeleteStudySession deleteStudySession = DeleteStudySession(
    studySessionRepository,
  );

  late final ReviewLocalDataSource reviewLocalDataSource =
      ReviewLocalDataSourceImpl(appDatabase);
  late final ReviewRepository reviewRepository = ReviewRepositoryImpl(
    reviewLocalDataSource,
  );
  late final CreateReview createReview = CreateReview(reviewRepository);
  late final GetPendingReviews getPendingReviews = GetPendingReviews(
    reviewRepository,
  );
  late final CompleteReview completeReview = CompleteReview(
    reviewRepository,
    generateReviewId: generateReviewId,
  );
  late final GetReviewsByTopic getReviewsByTopic = GetReviewsByTopic(
    reviewRepository,
  );

  late final GetDashboardSummary getDashboardSummary = GetDashboardSummary(
    subjectRepository: subjectRepository,
    topicRepository: topicRepository,
    studySessionRepository: studySessionRepository,
    reviewRepository: reviewRepository,
    now: now,
  );

  Future<void> close() {
    return appDatabase.close();
  }
}
