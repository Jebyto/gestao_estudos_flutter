import '../errors/subject_exceptions.dart';
import '../repositories/subject_repository.dart';

class DeleteSubject {
  final SubjectRepository repository;

  const DeleteSubject(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw const EmptySubjectIdException();
    }

    await repository.deleteSubject(id);
  }
}
