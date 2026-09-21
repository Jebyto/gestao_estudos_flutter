import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_local_datasource.dart';
import '../models/subject_model.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource localDataSource;
  final Future<void> Function()? onDeleted;

  const SubjectRepositoryImpl(this.localDataSource, {this.onDeleted});

  @override
  Future<void> createSubject(Subject subject) {
    final model = SubjectModel.fromEntity(subject);

    return localDataSource.createSubject(model);
  }

  @override
  Future<void> deleteSubject(String id) async {
    await localDataSource.deleteSubject(id);
    await onDeleted?.call();
  }

  @override
  Future<List<Subject>> getSubjects() async {
    final models = await localDataSource.getSubjects();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateSubject(Subject subject) {
    final model = SubjectModel.fromEntity(subject);

    return localDataSource.updateSubject(model);
  }
}
