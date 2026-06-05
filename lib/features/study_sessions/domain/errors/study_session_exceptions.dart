import '../../../../core/errors/validation_exception.dart';

abstract class StudySessionException extends ValidationException {
  const StudySessionException(super.message, {required super.code});
}

class EmptyStudySessionIdException extends StudySessionException {
  const EmptyStudySessionIdException()
    : super('Study session id is required.', code: 'empty_study_session_id');
}

class EmptyStudySessionSubjectIdException extends StudySessionException {
  const EmptyStudySessionSubjectIdException()
    : super('Subject id is required.', code: 'empty_study_session_subject_id');
}

class InvalidStudySessionDurationException extends StudySessionException {
  const InvalidStudySessionDurationException()
    : super(
        'Study session duration must be greater than zero.',
        code: 'invalid_study_session_duration',
      );
}
