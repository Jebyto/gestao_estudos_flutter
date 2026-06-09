import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/subject_model.dart';

abstract class SubjectLocalDataSource {
  Future<List<SubjectModel>> getSubjects();
  Future<void> createSubject(SubjectModel subject);
  Future<void> deleteSubject(String id);
}

class SubjectLocalDataSourceImpl implements SubjectLocalDataSource {
  final AppDatabase appDatabase;

  const SubjectLocalDataSourceImpl(this.appDatabase);

  @override
  Future<List<SubjectModel>> getSubjects() async {
    final database = await appDatabase.database;
    final result = await database.query('subjects', orderBy: 'created_at DESC');

    return result.map(SubjectModel.fromMap).toList();
  }

  @override
  Future<void> createSubject(SubjectModel subject) async {
    final database = await appDatabase.database;

    await database.insert(
      'subjects',
      subject.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteSubject(String id) async {
    final database = await appDatabase.database;

    await database.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }
}
