import 'package:flutter_clean_riverpod/data/datasource/core/api_client.dart';
import 'package:flutter_clean_riverpod/data/datasource/core/api_endpoint.dart';
import 'package:flutter_clean_riverpod/data/datasource/country/country_datasource.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_model.dart';
import 'package:flutter_clean_riverpod/domain/core/result.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CountryDatasource)
class CountryDatasourceRemote implements CountryDatasource {
  final ApiClient client;

  CountryDatasourceRemote(this.client);

  @override
  Future<Result<List<CountryModel>>> fetchAllCountries() async {
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
        ],
      },
      decoder: (data) => (data as List<dynamic>)
          .map((element) => CountryModel.fromJson(element))
          .toList(),
    );
  }
}
