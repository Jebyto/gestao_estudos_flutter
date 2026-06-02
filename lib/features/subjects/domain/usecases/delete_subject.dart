import '../repositories/subject_repository.dart';

class DeleteSubject {
  final SubjectRepository repository;

  const DeleteSubject(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('O id da matéria é obrigatório.');
    }

    await repository.deleteSubject(id);
  }
}
