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

  testWidgets('deve abrir a tela de matérias', (tester) async {
    await tester.pumpWidget(StudyFlowApp(dependencies: dependencies));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(find.text('Matérias'), findsOneWidget);
    expect(find.text('Nenhuma matéria cadastrada'), findsOneWidget);
  });
}
