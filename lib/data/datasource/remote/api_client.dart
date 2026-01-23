import 'package:dio/dio.dart';
import 'package:flutter_clean_riverpod/data/datasource/remote/api_result.dart';
import 'package:flutter_clean_riverpod/data/error/api_error_mapper.dart';
import 'package:injectable/injectable.dart';

enum ApiMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE')
  ;

  final String value;

  const ApiMethod(this.value);
}

typedef ResponseDecoder<T> = T Function(dynamic data);

@injectable
class ApiClient {
  final Dio dio;
  final ApiErrorMapper apiErrorMapper;

  ApiClient(this.dio, this.apiErrorMapper);

  Future<ApiResult<T>> request<T>({
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
      final decoded = decoder(response.data);
      return ApiResult.success(decoded);
    } catch (e, stackTrace) {
      return ApiResult.failed(apiErrorMapper.map(e, stackTrace));
    }
  }
}
