import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_local_datasource.dart';
import '../models/subject_model.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource localDataSource;

  const SubjectRepositoryImpl(this.localDataSource);

  @override
  Future<void> createSubject(Subject subject) {
    final model = SubjectModel.fromEntity(subject);

    return localDataSource.createSubject(model);
  }

  @override
  Future<void> deleteSubject(String id) {
    return localDataSource.deleteSubject(id);
  }

  @override
  Future<List<Subject>> getSubjects() async {
    final models = await localDataSource.getSubjects();

    return models.map((model) => model.toEntity()).toList();
  }
}
