import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/core/di/app_dependencies.dart';
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
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await tester.pump();

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
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await tester.pump();

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
}

Finder _navigationDestination(String label) {
  return find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
}
