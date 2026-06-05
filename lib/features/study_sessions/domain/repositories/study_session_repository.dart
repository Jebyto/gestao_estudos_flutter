import '../entities/study_session.dart';

abstract class StudySessionRepository {
  Future<void> createStudySession(StudySession studySession);
  Future<List<StudySession>> getStudySessions();
  Future<List<StudySession>> getStudySessionsBySubject(String subjectId);
  Future<void> deleteStudySession(String id);
}
