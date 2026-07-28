import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/navigation/study_flow_home.dart';

void main() {
  testWidgets('deve alternar entre dashboard e matérias', (tester) async {
    var dashboardSelections = 0;
    var subjectSelections = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StudyFlowHome(
          dashboard: const Center(child: Text('Resumo do dashboard')),
          subjects: const Center(child: Text('Lista de matérias')),
          onDashboardSelected: () {
            dashboardSelections++;
          },
          onSubjectsSelected: () {
            subjectSelections++;
          },
        ),
      ),
    );

    expect(find.text('Resumo do dashboard'), findsOneWidget);
    expect(find.text('Lista de matérias'), findsNothing);

    await tester.tap(find.text('Matérias'));
    await tester.pumpAndSettle();

    expect(find.text('Lista de matérias'), findsOneWidget);
    expect(find.text('Resumo do dashboard'), findsNothing);
    expect(subjectSelections, 1);

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Resumo do dashboard'), findsOneWidget);
    expect(find.text('Lista de matérias'), findsNothing);
    expect(dashboardSelections, 1);
  });

  testWidgets('não deve recarregar o destino já selecionado', (tester) async {
    var dashboardSelections = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StudyFlowHome(
          dashboard: const SizedBox(),
          subjects: const SizedBox(),
          onDashboardSelected: () {
            dashboardSelections++;
          },
          onSubjectsSelected: () {},
        ),
      ),
    );

    await tester.tap(find.text('Dashboard'));
    await tester.pump();

    expect(dashboardSelections, 0);
  });
}
