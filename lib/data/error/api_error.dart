import 'package:dio/dio.dart';

abstract class ApiError<T> {
  final T error;

  const ApiError(this.error);
}

class InternetError extends ApiError<String> {
  const InternetError([super.error = "No Internet Connection"]);
}

class RequestApiError extends ApiError<DioException> {
  const RequestApiError(super.error);
}

class ParseResponseError extends ApiError<Object> {
  const ParseResponseError(super.error);
}

class UnauthorizedError extends ApiError<DioException> {
  const UnauthorizedError(super.error);
}

class UnknownError extends ApiError<Object?> {
  const UnknownError([super.error]);
}
