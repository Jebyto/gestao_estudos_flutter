import '../entities/study_session.dart';
import '../repositories/study_session_repository.dart';

class GetStudySessions {
  final StudySessionRepository repository;

  const GetStudySessions(this.repository);

  Future<List<StudySession>> call() {
    return repository.getStudySessions();
  }
}
