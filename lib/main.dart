import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_dependencies.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/reviews/presentation/cubit/reviews_cubit.dart';
import 'features/reviews/presentation/pages/reviews_page.dart';
import 'features/study_sessions/presentation/cubit/study_sessions_cubit.dart';
import 'features/study_sessions/presentation/pages/study_sessions_page.dart';
import 'features/subjects/domain/entities/subject.dart';
import 'features/subjects/presentation/cubit/subjects_cubit.dart';
import 'features/subjects/presentation/pages/subjects_page.dart';
import 'features/topics/domain/entities/topic.dart';
import 'features/topics/presentation/cubit/topics_cubit.dart';
import 'features/topics/presentation/pages/topics_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(StudyFlowApp(dependencies: AppDependencies()));
}

class StudyFlowApp extends StatelessWidget {
  final AppDependencies dependencies;

  const StudyFlowApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
      home: BlocProvider(
        create: (_) => DashboardCubit(
          getDashboardSummary: dependencies.getDashboardSummary.call,
        )..loadSummary(),
        child: Builder(
          builder: (context) {
            return DashboardPage(onOpenSubjects: () => _openSubjects(context));
          },
        ),
      ),
    );
  }

  void _openSubjects(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return BlocProvider(
            create: (_) => SubjectsCubit(
              getSubjects: dependencies.getSubjects,
              createSubjectUseCase: dependencies.createSubject,
              deleteSubjectUseCase: dependencies.deleteSubject,
            )..loadSubjects(),
            child: SubjectsPage(onSubjectSelected: _openTopics),
          );
        },
      ),
    );
  }

  void _openTopics(BuildContext context, Subject subject) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return BlocProvider(
            create: (_) => TopicsCubit(
              subjectId: subject.id,
              getTopicsBySubject: dependencies.getTopicsBySubject,
              createTopicUseCase: dependencies.createTopic,
              updateTopicStatusUseCase: dependencies.updateTopicStatus,
              deleteTopicUseCase: dependencies.deleteTopic,
            )..loadTopics(),
            child: TopicsPage(
              subject: subject,
              onReviewsSelected: _openReviews,
              onStudySessionsSelected: _openStudySessions,
            ),
          );
        },
      ),
    );
  }

  void _openStudySessions(
    BuildContext context,
    Subject subject,
    List<Topic> topics,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return BlocProvider(
            create: (_) => StudySessionsCubit(
              subjectId: subject.id,
              getStudySessionsBySubject: dependencies.getStudySessionsBySubject,
              createStudySessionUseCase: dependencies.createStudySession,
              deleteStudySessionUseCase: dependencies.deleteStudySession,
            )..loadStudySessions(),
            child: StudySessionsPage(subject: subject, topics: topics),
          );
        },
      ),
    );
  }

  void _openReviews(BuildContext context, Subject subject, List<Topic> topics) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return BlocProvider(
            create: (_) => ReviewsCubit(
              topicIds: topics.map((topic) => topic.id).toList(),
              getPendingReviews: dependencies.getPendingReviews,
              createReviewUseCase: dependencies.createReview,
              completeReviewUseCase: dependencies.completeReview,
            )..loadPendingReviews(),
            child: ReviewsPage(subject: subject, topics: topics),
          );
        },
      ),
    );
  }
}
