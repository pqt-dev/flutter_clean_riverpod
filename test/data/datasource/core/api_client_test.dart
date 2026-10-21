import 'package:dio/dio.dart';
import 'package:flutter_clean_riverpod/data/datasource/core/api_client.dart';
import 'package:flutter_clean_riverpod/data/failures/exception_mapper.dart';
import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/infrastructure/services/logger_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'api_client_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Dio>(), MockSpec<LoggerService>()])
void main() {
  late MockDio dio;
  late MockLoggerService loggerService;
  late ApiClient apiClient;

  setUp(() {
    dio = MockDio();
    loggerService = MockLoggerService();
    apiClient = ApiClient(dio, const ExceptionMapper(), loggerService);
  });

  test('request returns Success and does not log when Dio succeeds', () async {
    when(
      dio.request<dynamic>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
        options: anyNamed('options'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: 'abc',
        requestOptions: RequestOptions(path: '/test'),
      ),
    );

    final result = await apiClient.request<String>(
      endpoint: '/test',
      method: ApiMethod.get,
      decoder: (data) => 'decoded:$data',
    );

    expect(result, isA<Success<String>>());
    expect((result as Success<String>).value, 'decoded:abc');
    verifyNever(
      loggerService.error(
        any,
        error: anyNamed('error'),
        stackTrace: anyNamed('stackTrace'),
      ),
    );
  });

  test('request returns Failure and logs once when Dio throws', () async {
    when(
      dio.request<dynamic>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
        options: anyNamed('options'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      ),
    ).thenThrow(
      DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      ),
    );

    final result = await apiClient.request<String>(
      endpoint: '/test',
      method: ApiMethod.get,
      decoder: (data) => data as String,
    );

    expect(result, isA<Failure>());
    expect((result as Failure).error, isA<NetworkError>());
    verify(
      loggerService.error(
        any,
        error: anyNamed('error'),
        stackTrace: anyNamed('stackTrace'),
      ),
    ).called(1);
  });
}
