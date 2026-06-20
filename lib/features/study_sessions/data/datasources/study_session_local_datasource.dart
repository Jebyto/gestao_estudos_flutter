import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/study_session_model.dart';

abstract class StudySessionLocalDataSource {
  Future<void> createStudySession(StudySessionModel studySession);
  Future<List<StudySessionModel>> getStudySessions();
  Future<List<StudySessionModel>> getStudySessionsBySubject(String subjectId);
  Future<void> deleteStudySession(String id);
}

class StudySessionLocalDataSourceImpl implements StudySessionLocalDataSource {
  final AppDatabase appDatabase;

  const StudySessionLocalDataSourceImpl(this.appDatabase);

  @override
  Future<void> createStudySession(StudySessionModel studySession) async {
    final database = await appDatabase.database;

    await database.insert(
      'study_sessions',
      studySession.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteStudySession(String id) async {
    final database = await appDatabase.database;

    await database.delete('study_sessions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<StudySessionModel>> getStudySessions() async {
    final database = await appDatabase.database;
    final result = await database.query(
      'study_sessions',
      orderBy: 'studied_at DESC',
    );

    return result.map(StudySessionModel.fromMap).toList();
  }

  @override
  Future<List<StudySessionModel>> getStudySessionsBySubject(
    String subjectId,
  ) async {
    final database = await appDatabase.database;
    final result = await database.query(
      'study_sessions',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'studied_at DESC',
    );

    return result.map(StudySessionModel.fromMap).toList();
  }
}
