import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/core/di/app_dependencies.dart';
import 'package:gestao_estudos_flutter/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDependencies dependencies;

  setUp(() {
    sqfliteFfiInit();

    dependencies = AppDependencies(
      appDatabase: AppDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
        singleInstance: false,
      ),
    );
  });

  tearDown(() async {
    await dependencies.close();
  });

  testWidgets('deve abrir a tela de dashboard', (tester) async {
    await tester.pumpWidget(StudyFlowApp(dependencies: dependencies));
    await tester.pump();
    await _waitForDashboard(tester);

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Dashboard'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('deve navegar entre dashboard e matérias', (tester) async {
    await tester.pumpWidget(StudyFlowApp(dependencies: dependencies));
    await tester.pump();
    await _waitForDashboard(tester);

    await tester.tap(_navigationDestination('Matérias'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await tester.pump();

    expect(find.text('Nenhuma matéria cadastrada'), findsOneWidget);

    await tester.tap(_navigationDestination('Dashboard'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await tester.pump();

    expect(find.text('Progresso geral'), findsOneWidget);
  });

  testWidgets('deve abrir revisões globais pelo dashboard', (tester) async {
    await tester.pumpWidget(StudyFlowApp(dependencies: dependencies));
    await tester.pump();
    await _waitForDashboard(tester);

    final reviewsMetric = find.byWidgetPredicate((widget) {
      return widget is DashboardMetricCard && widget.label == 'Para hoje';
    });
    await tester.scrollUntilVisible(
      reviewsMetric,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.runAsync(() async {
      tester.widget<DashboardMetricCard>(reviewsMetric).onTap!();
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Revisões')),
      findsOneWidget,
    );
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
  });

  testWidgets('cancelar revisão atualiza dashboard ao voltar', (tester) async {
    final today = DateTime.now();
    await tester.runAsync(() async {
      await dependencies.createSubject(
        Subject(id: 'subject', name: 'Matematica', createdAt: today),
      );
      await dependencies.createTopic(
        Topic(
          id: 'topic',
          subjectId: 'subject',
          title: 'Funcoes',
          status: TopicStatus.review,
          priority: TopicPriority.medium,
          createdAt: today,
        ),
      );
      await dependencies.createReview(
        Review(
          id: 'review',
          topicId: 'topic',
          scheduledFor: today,
          createdAt: today,
        ),
      );
    });
    await tester.pumpWidget(StudyFlowApp(dependencies: dependencies));
    await _waitForDashboard(tester);
    final metric = find.byWidgetPredicate(
      (widget) => widget is DashboardMetricCard && widget.label == 'Para hoje',
    );
    await tester.scrollUntilVisible(
      metric,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.widget<DashboardMetricCard>(metric).value, '1');
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(metric), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(metric);
    await _waitUntil(
      tester,
      () => find.byTooltip('Cancelar revisão').evaluate().isNotEmpty,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cancelar revisão'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancelar revisão'));
    await _waitUntil(
      tester,
      () => find.byTooltip('Cancelar revisão').evaluate().isEmpty,
    );
    await tester.pumpAndSettle();
    final reviews = await tester.runAsync(
      () => dependencies.getReviewsByTopic('topic'),
    );
    expect(reviews, isEmpty);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _waitUntil(
      tester,
      () =>
          metric.evaluate().isNotEmpty &&
          tester.widget<DashboardMetricCard>(metric).value == '0',
    );
    expect(tester.widget<DashboardMetricCard>(metric).value, '0');
  });

  testWidgets('deve alterar o tema pelas configurações', (tester) async {
    await tester.pumpWidget(StudyFlowApp(dependencies: dependencies));
    await tester.pump();
    await _waitForDashboard(tester);

    await tester.tap(_navigationDestination('Configurações'));
    await tester.pump();
    await tester.tap(find.text('Escuro'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}

Finder _navigationDestination(String label) {
  return find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
}

Future<void> _waitForDashboard(WidgetTester tester) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump();

    if (find.byType(ListView).evaluate().isNotEmpty) return;

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  }

  fail('O Dashboard não terminou de carregar.');
}

Future<void> _waitUntil(WidgetTester tester, bool Function() ready) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump();
    if (ready()) return;
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  }
  fail('A operação com SQLite não terminou.');
}
