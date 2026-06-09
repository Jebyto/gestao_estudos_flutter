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
  final int reviewsDueToday;
  final int overdueReviews;
  final int completedReviewsThisWeek;
  final String? nextReviewId;
  final String? nextReviewTopicId;
  final String? nextReviewTopicTitle;
  final String? nextReviewSubjectName;
  final DateTime? nextReviewScheduledFor;

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
    required this.reviewsDueToday,
    required this.overdueReviews,
    required this.completedReviewsThisWeek,
    this.nextReviewId,
    this.nextReviewTopicId,
    this.nextReviewTopicTitle,
    this.nextReviewSubjectName,
    this.nextReviewScheduledFor,
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
            other.mostStudiedSubjectMinutes == mostStudiedSubjectMinutes &&
            other.reviewsDueToday == reviewsDueToday &&
            other.overdueReviews == overdueReviews &&
            other.completedReviewsThisWeek == completedReviewsThisWeek &&
            other.nextReviewId == nextReviewId &&
            other.nextReviewTopicId == nextReviewTopicId &&
            other.nextReviewTopicTitle == nextReviewTopicTitle &&
            other.nextReviewSubjectName == nextReviewSubjectName &&
            other.nextReviewScheduledFor == nextReviewScheduledFor;
  }

  @override
  int get hashCode {
    return Object.hashAll([
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
      reviewsDueToday,
      overdueReviews,
      completedReviewsThisWeek,
      nextReviewId,
      nextReviewTopicId,
      nextReviewTopicTitle,
      nextReviewSubjectName,
      nextReviewScheduledFor,
    ]);
  }
}
