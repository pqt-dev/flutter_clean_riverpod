import 'app_error.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure extends Result<Never> {
  const Failure(this.error);

  final AppError error;
}
