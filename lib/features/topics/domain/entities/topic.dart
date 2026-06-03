enum TopicStatus { notStarted, studying, review, completed }

enum TopicPriority { low, medium, high }

class Topic {
  final String id;
  final String subjectId;
  final String title;
  final String? description;
  final TopicStatus status;
  final TopicPriority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? nextReviewAt;

  const Topic({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.nextReviewAt,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Topic &&
            other.id == id &&
            other.subjectId == subjectId &&
            other.title == title &&
            other.description == description &&
            other.status == status &&
            other.priority == priority &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt &&
            other.completedAt == completedAt &&
            other.nextReviewAt == nextReviewAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      subjectId,
      title,
      description,
      status,
      priority,
      createdAt,
      updatedAt,
      completedAt,
      nextReviewAt,
    );
  }
}
