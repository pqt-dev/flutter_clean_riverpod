import 'package:flutter_clean_riverpod/infrastructure/services/logger_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LoggerService logger;

  setUp(() {
    logger = LoggerService();
  });

  group('LoggerService', () {
    test('debug does not throw', () {
      expect(() => logger.debug('debug message'), returnsNormally);
    });

    test('info does not throw', () {
      expect(() => logger.info('info message'), returnsNormally);
    });

    test('warning does not throw', () {
      expect(() => logger.warning('warning message'), returnsNormally);
      expect(
        () => logger.warning(
          'warning message',
          error: Exception('boom'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('error does not throw', () {
      expect(() => logger.error('error message'), returnsNormally);
      expect(
        () => logger.error(
          'error message',
          error: Exception('boom'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });
}
