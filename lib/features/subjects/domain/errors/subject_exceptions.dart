import '../../../../core/errors/validation_exception.dart';

abstract class SubjectException extends ValidationException {
  const SubjectException(super.message, {required super.code});
}

class EmptySubjectNameException extends SubjectException {
  const EmptySubjectNameException()
    : super('Subject name is required.', code: 'empty_subject_name');
}

class EmptySubjectIdException extends SubjectException {
  const EmptySubjectIdException()
    : super('Subject id is required.', code: 'empty_subject_id');
}
