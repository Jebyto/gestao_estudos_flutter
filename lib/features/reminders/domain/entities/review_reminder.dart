class ReviewReminder {
  final DateTime date;
  final int pendingCount;

  const ReviewReminder({required this.date, required this.pendingCount});

  int get id => date.year * 10000 + date.month * 100 + date.day;
}
