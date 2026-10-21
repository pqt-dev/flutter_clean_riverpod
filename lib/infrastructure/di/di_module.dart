import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_clean_riverpod/data/datasource/core/api_endpoint.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    PrettyDioLogger logger,
    @Named('BaseUrl') String baseUrl,
  ) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    if (kDebugMode) {
      dio.interceptors.add(logger);
    }
    return dio;
  }

  @lazySingleton
  PrettyDioLogger get prettyDioLogger => PrettyDioLogger(
    requestHeader: false,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: false,
    compact: true,
    maxWidth: 90,
  );
}

@module
abstract class ConfigModule {
  @Named('BaseUrl')
  String get baseUrl => APIEndpoint.baseUrl;
}

@module
abstract class StorageModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
