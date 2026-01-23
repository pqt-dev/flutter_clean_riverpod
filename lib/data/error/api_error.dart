import 'package:dio/dio.dart';

sealed class ApiError {
  final StackTrace? stackTrace;

  const ApiError({this.stackTrace});
}

class InternetError extends ApiError {
  const InternetError({super.stackTrace});
}

class RequestApiError extends ApiError {
  final DioException exception;

  const RequestApiError(this.exception, {super.stackTrace});
}

class UnauthorizedError extends ApiError {
  final DioException exception;

  const UnauthorizedError(this.exception, {super.stackTrace});
}

class ParseResponseError extends ApiError {
  final Exception exception;

  const ParseResponseError(this.exception, {super.stackTrace});
}

class UnknownError extends ApiError {
  final Object? obj;

  const UnknownError(this.obj, {super.stackTrace});
}
