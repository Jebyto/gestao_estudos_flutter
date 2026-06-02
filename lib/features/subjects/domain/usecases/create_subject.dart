import '../entities/subject.dart';
import '../repositories/subject_repository.dart';

class CreateSubject {
  final SubjectRepository repository;

  const CreateSubject(this.repository);

  Future<void> call(Subject subject) async {
    if (subject.name.trim().isEmpty) {
      throw ArgumentError('O nome da matéria é obrigatório.');
    }

    await repository.createSubject(subject);
  }
}
