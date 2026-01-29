sealed class AppError {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.cause,
    this.stackTrace,
  });
}

final class NetworkError extends AppError {
  const NetworkError({
    super.message = 'Network error',
    super.cause,
    super.stackTrace,
  });
}

final class ServerError extends AppError {
  final int? statusCode;

  const ServerError({
    this.statusCode,
    super.message = 'Server error',
    super.cause,
    super.stackTrace,
  });
}

final class AuthError extends AppError {
  const AuthError({
    super.message = 'Authentication error',
    super.cause,
    super.stackTrace,
  });
}

final class ParsingError extends AppError {
  const ParsingError({
    super.message = 'JSON parsing error',
    super.cause,
    super.stackTrace,
  });
}

final class UnexpectedError extends AppError {
  const UnexpectedError({
    super.message = 'Unexpected error',
    super.cause,
    super.stackTrace,
  });
}
