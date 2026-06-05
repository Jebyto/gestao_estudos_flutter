class StudySession {
  final String id;
  final String subjectId;
  final String? topicId;
  final int durationInMinutes;
  final DateTime studiedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StudySession({
    required this.id,
    required this.subjectId,
    this.topicId,
    required this.durationInMinutes,
    required this.studiedAt,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StudySession &&
            other.id == id &&
            other.subjectId == subjectId &&
            other.topicId == topicId &&
            other.durationInMinutes == durationInMinutes &&
            other.studiedAt == studiedAt &&
            other.notes == notes &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      subjectId,
      topicId,
      durationInMinutes,
      studiedAt,
      notes,
      createdAt,
      updatedAt,
    );
  }
}
