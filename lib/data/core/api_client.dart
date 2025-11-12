import 'package:dio/dio.dart';
import 'package:flutter_clean_riverpod/data/core/api_result.dart';
import 'package:flutter_clean_riverpod/data/error/api_error.dart';
import 'package:flutter_clean_riverpod/service/connectivity_service.dart';
import 'package:logger/logger.dart';

enum ApiMethod { get, post, put, patch, delete }

typedef ResponseDecoder<T> = T Function(Response response);

class ApiClient {
  final Dio dio;
  final ConnectivityService connectivityService;

  ApiClient(this.dio, this.connectivityService);

  Future<ApiResult<T>> request<T>({
    required String endpoint,
    required ApiMethod method,
    required ResponseDecoder<T> decoder,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final hasInternet = await connectivityService.hasInternet();
      if (!hasInternet) {
        return ApiResult.failed(InternetError());
      }
      final response = await _sendRequest(
        method,
        endpoint,
        queryParameters: queryParameters,
        options: options,
        data: data,
      );
      try {
        final parsedResponse = decoder(response);
        return ApiResult.success(parsedResponse);
      } catch (e, stackTrace) {
        Logger().e("Parse error: $e", stackTrace: stackTrace);
        return ApiResult.failed(ParseResponseError(e));
      }
    } on DioException catch (e, stackTrace) {
      Logger().e("Dio error: ${e.message}", stackTrace: stackTrace);
      if ([
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ].contains(e.type)) {
        return ApiResult.failed(const InternetError());
      }
      if (e.response?.statusCode == 401) {
        return ApiResult.failed(UnauthorizedError(e));
      }
      return ApiResult.failed(RequestApiError(e));
    } catch (e, stackTrace) {
      Logger().e("Unexpected error: $e", stackTrace: stackTrace);
      return ApiResult.failed(UnknownError(e));
    }
  }

  Future<Response> _sendRequest(
    ApiMethod method,
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    switch (method) {
      case ApiMethod.get:
        return dio.get(
          endpoint,
          queryParameters: queryParameters,
          options: options,
        );
      case ApiMethod.post:
        return dio.post(
          endpoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      case ApiMethod.put:
        return dio.put(
          data: data,
          endpoint,
          queryParameters: queryParameters,
          options: options,
        );
      case ApiMethod.patch:
        return dio.patch(
          data: data,
          endpoint,
          queryParameters: queryParameters,
          options: options,
        );
      case ApiMethod.delete:
        return dio.delete(
          data: data,
          endpoint,
          queryParameters: queryParameters,
          options: options,
        );
    }
  }
}
