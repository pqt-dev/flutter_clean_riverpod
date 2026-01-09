// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_clean_riverpod/data/core/api_client.dart' as _i139;
import 'package:flutter_clean_riverpod/data/core/auth_interceptor.dart'
    as _i793;
import 'package:flutter_clean_riverpod/data/repository/country/country_repository.dart'
    as _i279;
import 'package:flutter_clean_riverpod/data/repository/theme/theme_repository.dart'
    as _i29;
import 'package:flutter_clean_riverpod/di/di_module.dart' as _i166;
import 'package:flutter_clean_riverpod/service/internet_connection_service.dart'
    as _i593;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:pretty_dio_logger/pretty_dio_logger.dart' as _i528;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final networkModule = _$NetworkModule();
    final repositoryModule = _$RepositoryModule();
    final configModule = _$ConfigModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i593.InternetConnectionService>(
      () => _i593.InternetConnectionService(),
    );
    gh.lazySingleton<_i793.AuthInterceptor>(() => _i793.AuthInterceptor());
    gh.lazySingleton<_i528.PrettyDioLogger>(
      () => networkModule.prettyDioLogger,
    );
    gh.lazySingleton<_i29.ThemeRepository>(
      () => repositoryModule.themeRepository(gh<_i460.SharedPreferences>()),
    );
    gh.factory<String>(() => configModule.baseUrl, instanceName: 'BaseUrl');
    gh.factory<_i361.Dio>(
      () => networkModule.dio(
        gh<_i793.AuthInterceptor>(),
        gh<_i528.PrettyDioLogger>(),
        gh<String>(instanceName: 'BaseUrl'),
      ),
    );
    gh.factory<_i139.ApiClient>(
      () => _i139.ApiClient(
        gh<_i361.Dio>(),
        gh<_i593.InternetConnectionService>(),
      ),
    );
    gh.lazySingleton<_i279.CountryRepository>(
      () => repositoryModule.countryRepository(gh<_i139.ApiClient>()),
    );
    return this;
  }
}

class _$StorageModule extends _i166.StorageModule {}

class _$NetworkModule extends _i166.NetworkModule {}

class _$RepositoryModule extends _i166.RepositoryModule {}

class _$ConfigModule extends _i166.ConfigModule {}
