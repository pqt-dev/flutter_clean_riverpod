import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class LoggerService {
  final Logger _logger = Logger();

  void debug(String message) {
    _logger.d(message);
  }

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
