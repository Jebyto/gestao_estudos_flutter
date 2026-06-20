import '../../domain/entities/study_session.dart';
import '../../domain/repositories/study_session_repository.dart';
import '../datasources/study_session_local_datasource.dart';
import '../models/study_session_model.dart';

class StudySessionRepositoryImpl implements StudySessionRepository {
  final StudySessionLocalDataSource localDataSource;

  const StudySessionRepositoryImpl(this.localDataSource);

  @override
  Future<void> createStudySession(StudySession studySession) {
    final model = StudySessionModel.fromEntity(studySession);

    return localDataSource.createStudySession(model);
  }

  @override
  Future<void> deleteStudySession(String id) {
    return localDataSource.deleteStudySession(id);
  }

  @override
  Future<List<StudySession>> getStudySessions() async {
    final models = await localDataSource.getStudySessions();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<StudySession>> getStudySessionsBySubject(String subjectId) async {
    final models = await localDataSource.getStudySessionsBySubject(subjectId);

    return models.map((model) => model.toEntity()).toList();
  }
}
