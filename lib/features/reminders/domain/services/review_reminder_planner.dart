import '../../../reviews/domain/entities/review.dart';
import '../entities/review_reminder.dart';

class ReviewReminderPlanner {
  static const hour = 19;
  static const horizonDays = 30;

  const ReviewReminderPlanner();

  List<ReviewReminder> call(List<Review> reviews, DateTime now) {
    final local = now.toLocal();
    final dates = reviews.where((review) => review.isPending).map((review) {
      final date = review.scheduledFor.toLocal();
      return DateTime(date.year, date.month, date.day);
    }).toList();
    final reminders = <ReviewReminder>[];
    for (var offset = 0; offset < horizonDays; offset++) {
      final date = DateTime(local.year, local.month, local.day + offset, hour);
      if (!date.isAfter(local)) continue;
      final count = dates.where((due) => !due.isAfter(date)).length;
      if (count > 0) {
        reminders.add(ReviewReminder(date: date, pendingCount: count));
      }
    }
    return reminders;
  }
}
