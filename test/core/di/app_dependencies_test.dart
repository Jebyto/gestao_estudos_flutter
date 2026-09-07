import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/core/di/app_dependencies.dart';
import 'package:gestao_estudos_flutter/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:gestao_estudos_flutter/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_review_overview.dart';
import 'package:gestao_estudos_flutter/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/data/repositories/study_session_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/entities/study_session.dart';
import 'package:gestao_estudos_flutter/features/study_sessions/domain/usecases/update_study_session.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/repositories/subject_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/topics/data/repositories/topic_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late AppDependencies dependencies;
  final today = DateTime(2026, 6, 29, 10);

  setUp(() {
    sqfliteFfiInit();

    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
      singleInstance: false,
    );
    dependencies = AppDependencies(
      appDatabase: appDatabase,
      now: () => today,
      generateReviewId: () => 'review-next',
    );
  });

  tearDown(() async {
    await dependencies.close();
  });

  test('deve montar repositories reais e use cases principais', () {
    expect(dependencies.subjectRepository, isA<SubjectRepositoryImpl>());
    expect(dependencies.topicRepository, isA<TopicRepositoryImpl>());
    expect(
      dependencies.studySessionRepository,
      isA<StudySessionRepositoryImpl>(),
    );
    expect(dependencies.updateStudySession, isA<UpdateStudySession>());
    expect(dependencies.reviewRepository, isA<ReviewRepositoryImpl>());
    expect(dependencies.completeReview, isA<CompleteReview>());
    expect(dependencies.getReviewOverview, isA<GetReviewOverview>());
    expect(dependencies.settingsRepository, isA<SettingsRepositoryImpl>());
    expect(dependencies.getDashboardSummary, isA<GetDashboardSummary>());
  });

  test('deve persistir preferência de tema usando repository real', () async {
    expect(await dependencies.getThemePreference(), ThemePreference.system);

    await dependencies.updateThemePreference(ThemePreference.dark);

    expect(await dependencies.getThemePreference(), ThemePreference.dark);
  });

  test(
    'reagendamento e cancelamento atualizam dashboard e preservam histórico',
    () async {
      await dependencies.createSubject(
        Subject(id: 'subject-1', name: 'Matematica', createdAt: today),
      );
      await dependencies.createTopic(
        Topic(
          id: 'topic-1',
          subjectId: 'subject-1',
          title: 'Funcoes',
          status: TopicStatus.review,
          priority: TopicPriority.high,
          createdAt: today,
        ),
      );
      final history = Review(
        id: 'history',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
        reviewedAt: today,
        quality: ReviewQuality.good,
      );
      await dependencies.createReview(history);
      await dependencies.createReview(
        Review(
          id: 'pending',
          topicId: 'topic-1',
          scheduledFor: today,
          createdAt: today,
        ),
      );
      expect((await dependencies.getDashboardSummary()).reviewsDueToday, 1);
      await dependencies.rescheduleReview(
        reviewId: 'pending',
        scheduledFor: today.add(const Duration(days: 3)),
      );
      expect((await dependencies.getDashboardSummary()).reviewsDueToday, 0);
      expect(
        (await dependencies.getReviewOverview())
            .pendingReviews
            .single
            .review
            .id,
        'pending',
      );
      await dependencies.cancelReview('pending');
      expect(await dependencies.getReviewsByTopic('topic-1'), [history]);
      expect((await dependencies.getReviewOverview()).pendingReviews, isEmpty);
      expect(
        (await dependencies.getDashboardSummary()).nextReviewTopicTitle,
        isNull,
      );
    },
  );

  test('deve atualizar sessão de estudo usando SQLite real', () async {
    final subject = Subject(
      id: 'subject-1',
      name: 'Banco de Dados',
      createdAt: today,
    );
    final studySession = StudySession(
      id: 'session-1',
      subjectId: subject.id,
      durationInMinutes: 30,
      studiedAt: DateTime(2026, 6, 28, 9),
      createdAt: DateTime(2026, 6, 28, 10),
    );
    final updatedStudySession = StudySession(
      id: studySession.id,
      subjectId: studySession.subjectId,
      durationInMinutes: 60,
      studiedAt: DateTime(2026, 6, 29, 9),
      notes: 'Conteúdo revisado',
      createdAt: studySession.createdAt,
      updatedAt: today,
    );
    await dependencies.createSubject(subject);
    await dependencies.createStudySession(studySession);

    await dependencies.updateStudySession(updatedStudySession);

    expect(await dependencies.getStudySessions(), [updatedStudySession]);
  });

  test('deve conectar use cases aos repositories SQLite reais', () async {
    final subject = Subject(
      id: 'subject-1',
      name: 'Banco de Dados',
      description: 'Modelagem e SQL',
      createdAt: today,
    );
    final topic = Topic(
      id: 'topic-1',
      subjectId: subject.id,
      title: 'Normalizacao',
      description: 'Formas normais',
      status: TopicStatus.studying,
      priority: TopicPriority.high,
      createdAt: today,
    );
    final studySession = StudySession(
      id: 'session-1',
      subjectId: subject.id,
      topicId: topic.id,
      durationInMinutes: 45,
      studiedAt: today,
      notes: 'Primeira forma normal',
      createdAt: today,
    );
    final review = Review(
      id: 'review-1',
      topicId: topic.id,
      scheduledFor: today,
      createdAt: today,
    );

    await dependencies.createSubject(subject);
    await dependencies.createTopic(topic);
    await dependencies.createStudySession(studySession);
    await dependencies.createReview(review);

    expect(await dependencies.getSubjects(), [subject]);
    expect(await dependencies.getTopicsBySubject(subject.id), [topic]);
    expect(await dependencies.getStudySessions(), [studySession]);
    expect(await dependencies.getPendingReviews(today), [review]);

    final reviewOverview = await dependencies.getReviewOverview();
    final summary = await dependencies.getDashboardSummary();

    expect(reviewOverview.pendingReviews.single.review, review);
    expect(reviewOverview.pendingReviews.single.topic, topic);
    expect(reviewOverview.pendingReviews.single.subject, subject);
    expect(summary.totalSubjects, 1);
    expect(summary.totalTopics, 1);
    expect(summary.studyingTopics, 1);
    expect(summary.totalStudyMinutesToday, 45);
    expect(summary.totalStudyMinutesThisWeek, 45);
    expect(summary.reviewsDueToday, 1);
    expect(summary.nextReviewTopicTitle, 'Normalizacao');
    expect(summary.nextReviewSubjectName, 'Banco de Dados');
  });

  test(
    'deve concluir review e criar a proxima usando repository real',
    () async {
      final subject = Subject(
        id: 'subject-1',
        name: 'Portugues',
        createdAt: today,
      );
      final topic = Topic(
        id: 'topic-1',
        subjectId: subject.id,
        title: 'Pronome relativo',
        status: TopicStatus.review,
        priority: TopicPriority.medium,
        createdAt: today,
      );
      final review = Review(
        id: 'review-1',
        topicId: topic.id,
        scheduledFor: today,
        createdAt: today,
      );

      await dependencies.createSubject(subject);
      await dependencies.createTopic(topic);
      await dependencies.createReview(review);
      await dependencies.completeReview(
        reviewId: review.id,
        quality: ReviewQuality.good,
        reviewedAt: today,
      );

      final reviews = await dependencies.getReviewsByTopic(topic.id);

      expect(reviews.length, 2);
      expect(reviews.first.id, 'review-1');
      expect(reviews.first.reviewedAt, today);
      expect(reviews.first.quality, ReviewQuality.good);
      expect(reviews.last.id, 'review-next');
      expect(reviews.last.scheduledFor, today.add(const Duration(days: 3)));
    },
  );
}
