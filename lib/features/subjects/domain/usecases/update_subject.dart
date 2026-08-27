import '../entities/subject.dart';
import '../errors/subject_exceptions.dart';
import '../repositories/subject_repository.dart';

class UpdateSubject {
  final SubjectRepository repository;

  const UpdateSubject(this.repository);

  Future<void> call(Subject subject) async {
    if (subject.id.trim().isEmpty) {
      throw const EmptySubjectIdException();
    }

    if (subject.name.trim().isEmpty) {
      throw const EmptySubjectNameException();
    }

    await repository.updateSubject(subject);
  }
}
