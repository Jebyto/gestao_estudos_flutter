import '../entities/review_reminder.dart';

abstract class ReminderGateway {
  bool get isSupported;
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<void> replaceReminders(List<ReviewReminder> reminders);
}
