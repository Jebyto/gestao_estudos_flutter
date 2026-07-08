import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:gestao_estudos_flutter/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:gestao_estudos_flutter/features/dashboard/presentation/cubit/dashboard_state.dart';

void main() {
  late DashboardSummary summary;

  setUp(() {
    summary = const DashboardSummary(
      totalSubjects: 2,
      totalTopics: 5,
      completedTopics: 3,
      studyingTopics: 1,
      pendingTopics: 2,
      totalStudyMinutesToday: 45,
      totalStudyMinutesThisWeek: 320,
      progressPercentage: 60,
      mostStudiedSubjectId: 'subject-1',
      mostStudiedSubjectName: 'Banco de Dados',
      mostStudiedSubjectMinutes: 180,
      reviewsDueToday: 2,
      overdueReviews: 1,
      completedReviewsThisWeek: 4,
      nextReviewId: 'review-1',
      nextReviewTopicId: 'topic-1',
      nextReviewTopicTitle: 'Normalização',
      nextReviewSubjectName: 'Banco de Dados',
    );
  });

  test('deve iniciar com estado initial', () {
    final cubit = DashboardCubit(getDashboardSummary: () async => summary);

    expect(cubit.state.status, DashboardStatus.initial);
    expect(cubit.state.summary, isNull);

    cubit.close();
  });

  test('deve carregar resumo do dashboard', () async {
    final cubit = DashboardCubit(getDashboardSummary: () async => summary);

    await cubit.loadSummary();

    expect(cubit.state.status, DashboardStatus.success);
    expect(cubit.state.summary, summary);

    await cubit.close();
  });

  test('deve emitir failure quando carregamento falhar', () async {
    final cubit = DashboardCubit(
      getDashboardSummary: () {
        throw Exception('erro');
      },
    );

    await cubit.loadSummary();

    expect(cubit.state.status, DashboardStatus.failure);
    expect(cubit.state.errorMessage, 'Não foi possível carregar o dashboard.');

    await cubit.close();
  });
}
