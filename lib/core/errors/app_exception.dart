abstract class AppException implements Exception {
  final String message;
  final String code;

  const AppException(this.message, {required this.code});

  @override
  String toString() => '$runtimeType($code): $message';
}
