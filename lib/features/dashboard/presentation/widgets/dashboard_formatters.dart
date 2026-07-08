String formatDashboardMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) return '$minutes min';
  if (remainingMinutes == 0) return '${hours}h';

  return '${hours}h ${remainingMinutes}min';
}

String formatDashboardPercentage(double value) {
  return '${value.round()}%';
}

String formatDashboardDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day/$month/$year';
}
