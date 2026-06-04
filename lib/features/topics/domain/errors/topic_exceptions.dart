import '../../../../core/errors/validation_exception.dart';

abstract class TopicException extends ValidationException {
  const TopicException(super.message, {required super.code});
}

class EmptyTopicIdException extends TopicException {
  const EmptyTopicIdException()
    : super('Topic id is required.', code: 'empty_topic_id');
}

class EmptyTopicSubjectIdException extends TopicException {
  const EmptyTopicSubjectIdException()
    : super('Subject id is required.', code: 'empty_topic_subject_id');
}

class EmptyTopicTitleException extends TopicException {
  const EmptyTopicTitleException()
    : super('Topic title is required.', code: 'empty_topic_title');
}
