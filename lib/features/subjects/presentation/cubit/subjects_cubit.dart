import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/subject.dart';
import '../../domain/usecases/create_subject.dart';
import '../../domain/usecases/delete_subject.dart';
import '../../domain/usecases/get_subjects.dart';
import 'subjects_state.dart';

typedef SubjectIdGenerator = String Function();
typedef SubjectDateTimeProvider = DateTime Function();

class SubjectsCubit extends Cubit<SubjectsState> {
  final GetSubjects getSubjects;
  final CreateSubject createSubjectUseCase;
  final DeleteSubject deleteSubjectUseCase;
  final SubjectIdGenerator generateSubjectId;
  final SubjectDateTimeProvider now;

  SubjectsCubit({
    required this.getSubjects,
    required this.createSubjectUseCase,
    required this.deleteSubjectUseCase,
    SubjectIdGenerator? generateSubjectId,
    SubjectDateTimeProvider? now,
  }) : generateSubjectId = generateSubjectId ?? _defaultGenerateSubjectId,
       now = now ?? DateTime.now,
       super(const SubjectsState());

  Future<void> loadSubjects() async {
    emit(state.copyWith(status: SubjectsStatus.loading, errorMessage: null));

    try {
      final subjects = await getSubjects();

      emit(
        state.copyWith(
          status: SubjectsStatus.success,
          subjects: subjects,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SubjectsStatus.failure,
          errorMessage: 'Não foi possível carregar as matérias.',
        ),
      );
    }
  }

  Future<bool> createSubject({
    required String name,
    String? description,
  }) async {
    final trimmedName = name.trim();
    final trimmedDescription = description?.trim();

    if (trimmedName.isEmpty) {
      emit(
        state.copyWith(
          status: SubjectsStatus.failure,
          errorMessage: 'Informe o nome da matéria.',
        ),
      );
      return false;
    }

    emit(state.copyWith(status: SubjectsStatus.submitting, errorMessage: null));

    try {
      await createSubjectUseCase(
        Subject(
          id: generateSubjectId(),
          name: trimmedName,
          description: trimmedDescription == null || trimmedDescription.isEmpty
              ? null
              : trimmedDescription,
          createdAt: now(),
        ),
      );
      await loadSubjects();

      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: SubjectsStatus.failure,
          errorMessage: 'Não foi possível salvar a matéria.',
        ),
      );
      return false;
    }
  }

  Future<void> deleteSubject(String id) async {
    emit(state.copyWith(status: SubjectsStatus.submitting, errorMessage: null));

    try {
      await deleteSubjectUseCase(id);
      await loadSubjects();
    } catch (_) {
      emit(
        state.copyWith(
          status: SubjectsStatus.failure,
          errorMessage: 'Não foi possível excluir a matéria.',
        ),
      );
    }
  }
}

String _defaultGenerateSubjectId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}
