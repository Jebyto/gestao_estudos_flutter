String formatStudySessionDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) return '$minutes min';
  if (remainingMinutes == 0) return '${hours}h';

  return '${hours}h ${remainingMinutes}min';
}

String formatStudySessionDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/$year $hour:$minute';
}
