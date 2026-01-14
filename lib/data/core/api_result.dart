import 'package:flutter_clean_riverpod/data/error/api_error.dart';

sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T value) => Success(value);

  factory ApiResult.failed(ApiError error) => Failure(error);
}

final class Success<T> extends ApiResult<T> {
  const Success(this.value);

  final T value;
}

final class Failure extends ApiResult<Never> {
  const Failure(this.error);

  final ApiError error;
}
