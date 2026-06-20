import '../../domain/entities/study_session.dart';

class StudySessionModel {
  final String id;
  final String subjectId;
  final String? topicId;
  final int durationInMinutes;
  final DateTime studiedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StudySessionModel({
    required this.id,
    required this.subjectId,
    this.topicId,
    required this.durationInMinutes,
    required this.studiedAt,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory StudySessionModel.fromEntity(StudySession studySession) {
    return StudySessionModel(
      id: studySession.id,
      subjectId: studySession.subjectId,
      topicId: studySession.topicId,
      durationInMinutes: studySession.durationInMinutes,
      studiedAt: studySession.studiedAt,
      notes: studySession.notes,
      createdAt: studySession.createdAt,
      updatedAt: studySession.updatedAt,
    );
  }

  factory StudySessionModel.fromMap(Map<String, dynamic> map) {
    return StudySessionModel(
      id: map['id'] as String,
      subjectId: map['subject_id'] as String,
      topicId: map['topic_id'] as String?,
      durationInMinutes: map['duration_in_minutes'] as int,
      studiedAt: DateTime.parse(map['studied_at'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
    );
  }

  StudySession toEntity() {
    return StudySession(
      id: id,
      subjectId: subjectId,
      topicId: topicId,
      durationInMinutes: durationInMinutes,
      studiedAt: studiedAt,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'topic_id': topicId,
      'duration_in_minutes': durationInMinutes,
      'studied_at': studiedAt.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
