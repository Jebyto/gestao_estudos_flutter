import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:gestao_estudos_flutter/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:gestao_estudos_flutter/features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  late DashboardSummary summary;
  late DashboardCubit cubit;

  setUp(() {
    summary = DashboardSummary(
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
      nextReviewScheduledFor: DateTime(2026, 7, 3),
    );
    cubit = DashboardCubit(getDashboardSummary: () async => summary);
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('deve exibir o resumo do dashboard', (tester) async {
    await cubit.loadSummary();
    await tester.pumpDashboardPage(cubit);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Progresso geral'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Matérias'), findsOneWidget);
    expect(find.text('Tópicos'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();

    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('5h 20min'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();

    expect(find.text('Normalização'), findsOneWidget);
  });

  testWidgets('deve chamar callback para abrir matérias', (tester) async {
    var openedSubjects = false;

    await cubit.loadSummary();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: DashboardPage(
            onOpenSubjects: () {
              openedSubjects = true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Matérias'));
    await tester.pump();

    expect(openedSubjects, isTrue);
  });
}

extension on WidgetTester {
  Future<void> pumpDashboardPage(DashboardCubit cubit) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: DashboardPage(onOpenSubjects: () {}),
        ),
      ),
    );
  }
}
