import '../entities/study_session.dart';
import '../errors/study_session_exceptions.dart';
import '../repositories/study_session_repository.dart';

class GetStudySessionsBySubject {
  final StudySessionRepository repository;

  const GetStudySessionsBySubject(this.repository);

  Future<List<StudySession>> call(String subjectId) async {
    if (subjectId.trim().isEmpty) {
      throw const EmptyStudySessionSubjectIdException();
    }

    return repository.getStudySessionsBySubject(subjectId);
  }
}
