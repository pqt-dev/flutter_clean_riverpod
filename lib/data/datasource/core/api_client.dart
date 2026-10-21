import 'package:dio/dio.dart';
import 'package:flutter_clean_riverpod/data/failures/exception_mapper.dart';
import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:flutter_clean_riverpod/infrastructure/services/logger_service.dart';
import 'package:injectable/injectable.dart';

enum ApiMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  final String value;

  const ApiMethod(this.value);
}

typedef ResponseDecoder<T> = T Function(dynamic data);

@lazySingleton
class ApiClient {
  final Dio dio;
  final ExceptionMapper exceptionMapper;
  final LoggerService loggerService;

  ApiClient(this.dio, this.exceptionMapper, this.loggerService);

  Future<Result<T>> request<T>({
    required String endpoint,
    required ApiMethod method,
    required ResponseDecoder<T> decoder,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.request(
        endpoint,
        queryParameters: queryParameters,
        options: options?.copyWith(
          method: method.value,
        ),
        data: data,
        cancelToken: cancelToken,
      );
      return Success(decoder(response.data));
    } catch (e, st) {
      loggerService.error('ApiClient.request failed', error: e, stackTrace: st);
      return Failure(exceptionMapper.map(e, st));
    }
  }
}
