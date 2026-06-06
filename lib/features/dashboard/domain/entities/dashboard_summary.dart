class DashboardSummary {
  final int totalSubjects;
  final int totalTopics;
  final int completedTopics;
  final int studyingTopics;
  final int pendingTopics;
  final int totalStudyMinutesToday;
  final int totalStudyMinutesThisWeek;
  final double progressPercentage;
  final String? mostStudiedSubjectId;
  final String? mostStudiedSubjectName;
  final int mostStudiedSubjectMinutes;

  const DashboardSummary({
    required this.totalSubjects,
    required this.totalTopics,
    required this.completedTopics,
    required this.studyingTopics,
    required this.pendingTopics,
    required this.totalStudyMinutesToday,
    required this.totalStudyMinutesThisWeek,
    required this.progressPercentage,
    this.mostStudiedSubjectId,
    this.mostStudiedSubjectName,
    required this.mostStudiedSubjectMinutes,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DashboardSummary &&
            other.totalSubjects == totalSubjects &&
            other.totalTopics == totalTopics &&
            other.completedTopics == completedTopics &&
            other.studyingTopics == studyingTopics &&
            other.pendingTopics == pendingTopics &&
            other.totalStudyMinutesToday == totalStudyMinutesToday &&
            other.totalStudyMinutesThisWeek == totalStudyMinutesThisWeek &&
            other.progressPercentage == progressPercentage &&
            other.mostStudiedSubjectId == mostStudiedSubjectId &&
            other.mostStudiedSubjectName == mostStudiedSubjectName &&
            other.mostStudiedSubjectMinutes == mostStudiedSubjectMinutes;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalSubjects,
      totalTopics,
      completedTopics,
      studyingTopics,
      pendingTopics,
      totalStudyMinutesToday,
      totalStudyMinutesThisWeek,
      progressPercentage,
      mostStudiedSubjectId,
      mostStudiedSubjectName,
      mostStudiedSubjectMinutes,
    );
  }
}
