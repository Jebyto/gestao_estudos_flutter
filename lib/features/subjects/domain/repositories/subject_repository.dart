import '../entities/subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> getSubjects();
  Future<void> createSubject(Subject subject);
  Future<void> deleteSubject(String id);
}
