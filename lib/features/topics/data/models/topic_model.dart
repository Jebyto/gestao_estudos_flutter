import '../../domain/entities/topic.dart';

class TopicModel {
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

  const TopicModel({
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

  factory TopicModel.fromEntity(Topic topic) {
    return TopicModel(
      id: topic.id,
      subjectId: topic.subjectId,
      title: topic.title,
      description: topic.description,
      status: topic.status,
      priority: topic.priority,
      createdAt: topic.createdAt,
      updatedAt: topic.updatedAt,
      completedAt: topic.completedAt,
      nextReviewAt: topic.nextReviewAt,
    );
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] as String,
      subjectId: map['subject_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: TopicStatus.values.byName(map['status'] as String),
      priority: TopicPriority.values.byName(map['priority'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.parse(map['completed_at'] as String),
      nextReviewAt: map['next_review_at'] == null
          ? null
          : DateTime.parse(map['next_review_at'] as String),
    );
  }

  Topic toEntity() {
    return Topic(
      id: id,
      subjectId: subjectId,
      title: title,
      description: description,
      status: status,
      priority: priority,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      nextReviewAt: nextReviewAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'next_review_at': nextReviewAt?.toIso8601String(),
    };
  }
}
