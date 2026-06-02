import '../entities/subject.dart';
import '../repositories/subject_repository.dart';

class GetSubjects {
  final SubjectRepository repository;

  const GetSubjects(this.repository);

  Future<List<Subject>> call() {
    return repository.getSubjects();
  }
}
