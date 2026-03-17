import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/core/app_error.dart';

@lazySingleton
class ExceptionMapper {
  const ExceptionMapper();

  AppError map(Object error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      return _fromDioException(error, stackTrace);
    }

    if (error is FormatException) {
      return ParsingError(cause: error, stackTrace: stackTrace);
    }
    return UnexpectedError(cause: error, stackTrace: stackTrace);
  }

  AppError _fromDioException(DioException e, [StackTrace? stackTrace]) {
    final hasConnectionError =
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
    if (hasConnectionError) {
      return NetworkError(cause: e, stackTrace: stackTrace);
    }
    final statusCode = e.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return AuthError(cause: e, stackTrace: stackTrace);
    }
    return ServerError(cause: e, stackTrace: stackTrace, statusCode: e.response?.statusCode);
  }
}
