import '../entities/study_session.dart';
import '../errors/study_session_exceptions.dart';
import '../repositories/study_session_repository.dart';

class CreateStudySession {
  final StudySessionRepository repository;

  const CreateStudySession(this.repository);

  Future<void> call(StudySession studySession) async {
    if (studySession.subjectId.trim().isEmpty) {
      throw const EmptyStudySessionSubjectIdException();
    }

    if (studySession.durationInMinutes <= 0) {
      throw const InvalidStudySessionDurationException();
    }

    await repository.createStudySession(studySession);
  }
}
