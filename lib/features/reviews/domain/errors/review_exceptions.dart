import '../../../../core/errors/validation_exception.dart';

abstract class ReviewException extends ValidationException {
  const ReviewException(super.message, {required super.code});
}

class ReviewAlreadyCompletedException extends ReviewException {
  const ReviewAlreadyCompletedException()
    : super('Review is already completed.', code: 'review_already_completed');
}

class InvalidReviewScheduleException extends ReviewException {
  const InvalidReviewScheduleException()
    : super(
        'Review date must be today or later.',
        code: 'invalid_review_schedule',
      );
}

class EmptyReviewIdException extends ReviewException {
  const EmptyReviewIdException()
    : super('Review id is required.', code: 'empty_review_id');
}

class EmptyReviewTopicIdException extends ReviewException {
  const EmptyReviewTopicIdException()
    : super('Topic id is required.', code: 'empty_review_topic_id');
}

class ReviewNotFoundException extends ReviewException {
  const ReviewNotFoundException()
    : super('Review was not found.', code: 'review_not_found');
}
