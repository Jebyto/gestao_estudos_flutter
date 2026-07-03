import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/study_session.dart';
import '../../domain/usecases/create_study_session.dart';
import '../../domain/usecases/delete_study_session.dart';
import '../../domain/usecases/get_study_sessions_by_subject.dart';
import 'study_sessions_state.dart';

typedef StudySessionIdGenerator = String Function();
typedef StudySessionDateTimeProvider = DateTime Function();

class StudySessionsCubit extends Cubit<StudySessionsState> {
  final String subjectId;
  final GetStudySessionsBySubject getStudySessionsBySubject;
  final CreateStudySession createStudySessionUseCase;
  final DeleteStudySession deleteStudySessionUseCase;
  final StudySessionIdGenerator generateStudySessionId;
  final StudySessionDateTimeProvider now;

  StudySessionsCubit({
    required this.subjectId,
    required this.getStudySessionsBySubject,
    required this.createStudySessionUseCase,
    required this.deleteStudySessionUseCase,
    StudySessionIdGenerator? generateStudySessionId,
    StudySessionDateTimeProvider? now,
  }) : generateStudySessionId =
           generateStudySessionId ?? _defaultGenerateStudySessionId,
       now = now ?? DateTime.now,
       super(const StudySessionsState());

  Future<void> loadStudySessions() async {
    emit(
      state.copyWith(status: StudySessionsStatus.loading, errorMessage: null),
    );

    try {
      final studySessions = await getStudySessionsBySubject(subjectId);

      emit(
        state.copyWith(
          status: StudySessionsStatus.success,
          studySessions: studySessions,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: StudySessionsStatus.failure,
          errorMessage: 'Não foi possível carregar as sessões.',
        ),
      );
    }
  }

  Future<bool> createStudySession({
    required int durationInMinutes,
    String? topicId,
    DateTime? studiedAt,
    String? notes,
  }) async {
    final trimmedTopicId = topicId?.trim();
    final trimmedNotes = notes?.trim();

    if (durationInMinutes <= 0) {
      emit(
        state.copyWith(
          status: StudySessionsStatus.failure,
          errorMessage: 'Informe uma duração maior que zero.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: StudySessionsStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      final currentDate = now();

      await createStudySessionUseCase(
        StudySession(
          id: generateStudySessionId(),
          subjectId: subjectId,
          topicId: trimmedTopicId == null || trimmedTopicId.isEmpty
              ? null
              : trimmedTopicId,
          durationInMinutes: durationInMinutes,
          studiedAt: studiedAt ?? currentDate,
          notes: trimmedNotes == null || trimmedNotes.isEmpty
              ? null
              : trimmedNotes,
          createdAt: currentDate,
        ),
      );
      await loadStudySessions();

      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: StudySessionsStatus.failure,
          errorMessage: 'Não foi possível salvar a sessão.',
        ),
      );
      return false;
    }
  }

  Future<void> deleteStudySession(String id) async {
    emit(
      state.copyWith(
        status: StudySessionsStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      await deleteStudySessionUseCase(id);
      await loadStudySessions();
    } catch (_) {
      emit(
        state.copyWith(
          status: StudySessionsStatus.failure,
          errorMessage: 'Não foi possível excluir a sessão.',
        ),
      );
    }
  }
}

String _defaultGenerateStudySessionId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}
