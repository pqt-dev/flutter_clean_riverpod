import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:injectable/injectable.dart';

import '../../models/country/country_model.dart';
import '../core/api_client.dart';
import '../core/api_endpoint.dart';
import 'country_datasource.dart';

@LazySingleton(as: CountryDatasource)
class CountryDatasourceRemote implements CountryDatasource {
  final ApiClient client;

  CountryDatasourceRemote(this.client);

  @override
  Future<Result<List<CountryModel>>> fetchCountries() async {
    return client.request(
      endpoint: APIEndpoint.allCountries,
      method: ApiMethod.get,
      queryParameters: {
        'fields': [
          'name',
          'flags',
          'capital',
          'area',
          'region',
          'subregion',
          'population',
          'postalCode',
          'timezones',
          'borders',
        ],
      },
      decoder: (data) =>
          (data as List<dynamic>).map((element) => CountryModel.fromJson(element)).toList(),
    );
  }
}
