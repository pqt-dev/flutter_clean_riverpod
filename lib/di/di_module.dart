import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_clean_riverpod/data/core/api_client.dart';
import 'package:flutter_clean_riverpod/data/repository/country/country_repository.dart';
import 'package:flutter_clean_riverpod/data/repository/country/country_repository_impl.dart';
import 'package:flutter_clean_riverpod/data/repository/theme/theme_repository_impl.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/core/api_endpoint.dart';
import '../data/core/auth_interceptor.dart';
import '../data/repository/theme/theme_repository.dart';

@module
abstract class NetworkModule {
  @injectable
  Dio dio(
    AuthInterceptor authInterceptor,
    PrettyDioLogger logger,
    @Named('BaseUrl') String baseUrl,
  ) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(authInterceptor);
    if (kDebugMode) {
      dio.interceptors.add(logger);
    }
    return dio;
  }

  @lazySingleton
  PrettyDioLogger get prettyDioLogger => PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
  );
}

@module
abstract class RepositoryModule {
  @lazySingleton
  ThemeRepository themeRepository(SharedPreferences prefs) {
    return ThemeRepositoryImpl(prefs);
  }

  @lazySingleton
  CountryRepository countryRepository(ApiClient client) {
    return CountryRepositoryImpl(client);
  }
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
