enum ReviewQuality { easy, good, hard }

class Review {
  final String id;
  final String topicId;
  final DateTime scheduledFor;
  final DateTime? reviewedAt;
  final ReviewQuality? quality;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.topicId,
    required this.scheduledFor,
    this.reviewedAt,
    this.quality,
    required this.createdAt,
  });

  bool get isPending => reviewedAt == null;

  bool get isCompleted => reviewedAt != null;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Review &&
            other.id == id &&
            other.topicId == topicId &&
            other.scheduledFor == scheduledFor &&
            other.reviewedAt == reviewedAt &&
            other.quality == quality &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      topicId,
      scheduledFor,
      reviewedAt,
      quality,
      createdAt,
    );
  }
}
