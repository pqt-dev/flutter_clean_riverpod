import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_clean_riverpod/data/failures/exception_mapper.dart';
import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExceptionMapper mapper;

  setUp(() {
    mapper = const ExceptionMapper();
  });

  group('DioException mapping', () {
    test('connectionError → NetworkError', () {
      final error = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapper.map(error);
      expect(result, isA<NetworkError>());
    });

    test('connectionTimeout → NetworkError', () {
      final error = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapper.map(error);
      expect(result, isA<NetworkError>());
    });

    test('receiveTimeout → NetworkError', () {
      final error = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapper.map(error);
      expect(result, isA<NetworkError>());
    });

    test('sendTimeout → NetworkError', () {
      final error = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapper.map(error);
      expect(result, isA<NetworkError>());
    });

    test('401 response → AuthError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      final result = mapper.map(error);
      expect(result, isA<AuthError>());
    });

    test('403 response → AuthError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      final result = mapper.map(error);
      expect(result, isA<AuthError>());
    });

    test('500 response → ServerError with statusCode', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      final result = mapper.map(error);
      expect(result, isA<ServerError>());
      expect((result as ServerError).statusCode, equals(500));
    });

    test('404 response → ServerError with statusCode', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      final result = mapper.map(error);
      expect(result, isA<ServerError>());
      expect((result as ServerError).statusCode, equals(404));
    });

    test('DioException with no response → ServerError', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = mapper.map(error);
      expect(result, isA<ServerError>());
      expect((result as ServerError).statusCode, isNull);
    });
  });

  group('Non-Dio exception mapping', () {
    test('FormatException → ParsingError', () {
      final error = const FormatException('Invalid JSON');
      final result = mapper.map(error);
      expect(result, isA<ParsingError>());
      expect(result.cause, equals(error));
    });

    test('SocketException → UnexpectedError', () {
      final error = const SocketException('Connection refused');
      final result = mapper.map(error);
      expect(result, isA<UnexpectedError>());
    });

    test('Generic exception → UnexpectedError', () {
      final error = Exception('Something went wrong');
      final result = mapper.map(error);
      expect(result, isA<UnexpectedError>());
      expect(result.cause, equals(error));
    });

    test('String error → UnexpectedError', () {
      final result = mapper.map('raw string error');
      expect(result, isA<UnexpectedError>());
    });
  });

  group('StackTrace preservation', () {
    test('maps with stackTrace when provided', () {
      final stackTrace = StackTrace.current;
      final error = Exception('test');
      final result = mapper.map(error, stackTrace);
      expect(result.stackTrace, equals(stackTrace));
    });

    test('maps without stackTrace when not provided', () {
      final error = Exception('test');
      final result = mapper.map(error);
      expect(result.stackTrace, isNull);
    });
  });
}
