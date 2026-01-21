import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['x-api-key'] = 'reqres-free-v1';
    super.onRequest(options, handler);
  }
}
