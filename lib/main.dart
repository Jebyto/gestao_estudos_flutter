import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_dependencies.dart';
import 'core/navigation/study_flow_home.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/reviews/presentation/cubit/review_overview_cubit.dart';
import 'features/reviews/presentation/cubit/reviews_cubit.dart';
import 'features/reviews/presentation/pages/review_overview_page.dart';
import 'features/reviews/presentation/pages/reviews_page.dart';
import 'features/settings/domain/entities/theme_preference.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'features/settings/presentation/pages/settings_page.dart';
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
    return BlocProvider(
      create: (_) => SettingsCubit(
        getThemePreference: dependencies.getThemePreference,
        updateThemePreferenceUseCase: dependencies.updateThemePreference,
      )..loadSettings(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'StudyFlow',
            debugShowCheckedModeBanner: false,
            themeMode: _themeModeFor(settingsState.themePreference),
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home:
                settingsState.isLoading ||
                    settingsState.status == SettingsStatus.initial
                ? const _AppLoadingView()
                : _buildHome(),
          );
        },
      ),
    );
  }

  Widget _buildHome() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardCubit(
            getDashboardSummary: dependencies.getDashboardSummary.call,
          )..loadSummary(),
        ),
        BlocProvider(
          create: (_) => SubjectsCubit(
            getSubjects: dependencies.getSubjects,
            createSubjectUseCase: dependencies.createSubject,
            deleteSubjectUseCase: dependencies.deleteSubject,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return StudyFlowHome(
            dashboard: DashboardPage(onOpenReviews: _openReviewOverview),
            subjects: SubjectsPage(onSubjectSelected: _openTopics),
            settings: const SettingsPage(),
            onDashboardSelected: () {
              context.read<DashboardCubit>().loadSummary();
            },
            onSubjectsSelected: () {
              context.read<SubjectsCubit>().loadSubjects();
            },
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

  Future<void> _openReviewOverview(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return BlocProvider(
            create: (_) => ReviewOverviewCubit(
              getReviewOverview: dependencies.getReviewOverview,
              completeReviewUseCase: dependencies.completeReview,
            )..loadOverview(),
            child: const ReviewOverviewPage(),
          );
        },
      ),
    );

    if (!context.mounted) return;

    await context.read<DashboardCubit>().loadSummary();
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
              getReviewsByTopic: dependencies.getReviewsByTopic,
              createReviewUseCase: dependencies.createReview,
              completeReviewUseCase: dependencies.completeReview,
            )..loadReviews(),
            child: ReviewsPage(subject: subject, topics: topics),
          );
        },
      ),
    );
  }
}

ThemeMode _themeModeFor(ThemePreference preference) {
  return switch (preference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}

ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
  );
}

class _AppLoadingView extends StatelessWidget {
  const _AppLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
