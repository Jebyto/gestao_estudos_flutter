import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_dependencies.dart';
import 'features/subjects/presentation/cubit/subjects_cubit.dart';
import 'features/subjects/presentation/pages/subjects_page.dart';

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
        create: (_) => SubjectsCubit(
          getSubjects: dependencies.getSubjects,
          createSubjectUseCase: dependencies.createSubject,
          deleteSubjectUseCase: dependencies.deleteSubject,
        )..loadSubjects(),
        child: const SubjectsPage(),
      ),
    );
  }
}
