import 'app_exception.dart';

abstract class ValidationException extends AppException {
  const ValidationException(super.message, {required super.code});
}
