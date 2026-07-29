import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/core/di/app_dependencies.dart';
import 'package:gestao_estudos_flutter/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
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
