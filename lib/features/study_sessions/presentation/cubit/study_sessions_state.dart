import 'package:equatable/equatable.dart';

import '../../domain/entities/study_session.dart';

enum StudySessionsStatus { initial, loading, success, failure, submitting }

class StudySessionsState extends Equatable {
  final StudySessionsStatus status;
  final List<StudySession> studySessions;
  final String? errorMessage;

  const StudySessionsState({
    this.status = StudySessionsStatus.initial,
    this.studySessions = const [],
    this.errorMessage,
  });

  bool get isLoading => status == StudySessionsStatus.loading;

  bool get isSubmitting => status == StudySessionsStatus.submitting;

  StudySessionsState copyWith({
    StudySessionsStatus? status,
    List<StudySession>? studySessions,
    Object? errorMessage = _errorMessageNotProvided,
  }) {
    return StudySessionsState(
      status: status ?? this.status,
      studySessions: studySessions ?? this.studySessions,
      errorMessage: errorMessage == _errorMessageNotProvided
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, studySessions, errorMessage];
}

const Object _errorMessageNotProvided = Object();
