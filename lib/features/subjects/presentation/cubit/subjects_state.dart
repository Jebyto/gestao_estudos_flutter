import 'package:equatable/equatable.dart';

import '../../domain/entities/subject.dart';

enum SubjectsStatus { initial, loading, success, failure, submitting }

class SubjectsState extends Equatable {
  final SubjectsStatus status;
  final List<Subject> subjects;
  final String? errorMessage;

  const SubjectsState({
    this.status = SubjectsStatus.initial,
    this.subjects = const [],
    this.errorMessage,
  });

  bool get isLoading => status == SubjectsStatus.loading;

  bool get isSubmitting => status == SubjectsStatus.submitting;

  SubjectsState copyWith({
    SubjectsStatus? status,
    List<Subject>? subjects,
    Object? errorMessage = _errorMessageNotProvided,
  }) {
    return SubjectsState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage == _errorMessageNotProvided
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, subjects, errorMessage];
}

const Object _errorMessageNotProvided = Object();
