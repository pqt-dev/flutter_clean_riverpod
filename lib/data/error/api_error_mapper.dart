import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'api_error.dart';

@injectable
class ApiErrorMapper {
  const ApiErrorMapper();

  ApiError map(Object error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      return _fromDioException(error, stackTrace);
    }

    if (error is FormatException) {
      return ParseResponseError(
        error,
        stackTrace: stackTrace,
      );
    }
    return UnknownError(error, stackTrace: stackTrace);
  }

  ApiError _fromDioException(DioException e, [StackTrace? stackTrace]) {
    if (_isConnectionError(e)) {
      return InternetError(stackTrace: stackTrace);
    }
    final statusCode = e.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedError(e, stackTrace: stackTrace);
    }
    return RequestApiError(e, stackTrace: stackTrace);
  }

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }
}
