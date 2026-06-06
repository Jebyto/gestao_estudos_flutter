import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/dashboard/domain/entities/dashboard_summary.dart';

void main() {
  group('DashboardSummary', () {
    test('should support value equality', () {
      // Arrange
      const firstSummary = DashboardSummary(
        totalSubjects: 2,
        totalTopics: 4,
        completedTopics: 2,
        studyingTopics: 1,
        pendingTopics: 2,
        totalStudyMinutesToday: 45,
        totalStudyMinutesThisWeek: 180,
        progressPercentage: 50,
        mostStudiedSubjectId: 'subject-1',
        mostStudiedSubjectName: 'Programming',
        mostStudiedSubjectMinutes: 120,
      );
      const secondSummary = DashboardSummary(
        totalSubjects: 2,
        totalTopics: 4,
        completedTopics: 2,
        studyingTopics: 1,
        pendingTopics: 2,
        totalStudyMinutesToday: 45,
        totalStudyMinutesThisWeek: 180,
        progressPercentage: 50,
        mostStudiedSubjectId: 'subject-1',
        mostStudiedSubjectName: 'Programming',
        mostStudiedSubjectMinutes: 120,
      );

      // Act

      // Assert
      expect(firstSummary, secondSummary);
    });
  });
}
