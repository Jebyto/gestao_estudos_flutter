import '../errors/subject_exceptions.dart';
import '../entities/subject.dart';
import '../repositories/subject_repository.dart';

class CreateSubject {
  final SubjectRepository repository;

  const CreateSubject(this.repository);

  Future<void> call(Subject subject) async {
    if (subject.name.trim().isEmpty) {
      throw const EmptySubjectNameException();
    }

    await repository.createSubject(subject);
  }
}
