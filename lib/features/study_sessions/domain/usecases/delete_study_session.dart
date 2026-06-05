import '../errors/study_session_exceptions.dart';
import '../repositories/study_session_repository.dart';

class DeleteStudySession {
  final StudySessionRepository repository;

  const DeleteStudySession(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw const EmptyStudySessionIdException();
    }

    await repository.deleteStudySession(id);
  }
}
