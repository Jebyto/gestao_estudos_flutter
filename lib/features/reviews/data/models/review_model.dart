import '../../domain/entities/review.dart';

class ReviewModel {
  final String id;
  final String topicId;
  final DateTime scheduledFor;
  final DateTime? reviewedAt;
  final ReviewQuality? quality;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.topicId,
    required this.scheduledFor,
    this.reviewedAt,
    this.quality,
    required this.createdAt,
  });

  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      topicId: review.topicId,
      scheduledFor: review.scheduledFor,
      reviewedAt: review.reviewedAt,
      quality: review.quality,
      createdAt: review.createdAt,
    );
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      topicId: map['topic_id'] as String,
      scheduledFor: DateTime.parse(map['scheduled_for'] as String),
      reviewedAt: map['reviewed_at'] == null
          ? null
          : DateTime.parse(map['reviewed_at'] as String),
      quality: map['quality'] == null
          ? null
          : ReviewQuality.values.byName(map['quality'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Review toEntity() {
    return Review(
      id: id,
      topicId: topicId,
      scheduledFor: scheduledFor,
      reviewedAt: reviewedAt,
      quality: quality,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic_id': topicId,
      'scheduled_for': scheduledFor.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'quality': quality?.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
