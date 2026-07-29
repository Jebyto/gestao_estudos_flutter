import '../../../subjects/domain/entities/subject.dart';
import '../../../topics/domain/entities/topic.dart';
import 'review.dart';

class ReviewOverviewItem {
  final Review review;
  final Topic topic;
  final Subject subject;

  const ReviewOverviewItem({
    required this.review,
    required this.topic,
    required this.subject,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReviewOverviewItem &&
            other.review == review &&
            other.topic == topic &&
            other.subject == subject;
  }

  @override
  int get hashCode => Object.hash(review, topic, subject);
}

class ReviewOverview {
  final List<ReviewOverviewItem> pendingReviews;
  final List<ReviewOverviewItem> completedReviews;

  const ReviewOverview({
    required this.pendingReviews,
    required this.completedReviews,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReviewOverview &&
            _listsAreEqual(other.pendingReviews, pendingReviews) &&
            _listsAreEqual(other.completedReviews, completedReviews);
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(pendingReviews),
    Object.hashAll(completedReviews),
  );
}

bool _listsAreEqual<T>(List<T> first, List<T> second) {
  if (first.length != second.length) return false;

  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }

  return true;
}
