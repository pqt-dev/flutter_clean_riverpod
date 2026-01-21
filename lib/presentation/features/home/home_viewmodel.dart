import 'package:flutter_clean_riverpod/presentation/features/home/home_state.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasource/remote/api_result.dart';
import '../../../data/models/response/country/country_response.dart';
import '../../../data/repositories/country/country_repository.dart';

part 'home_viewmodel.g.dart';

@riverpod
class HomeViewmodel extends _$HomeViewmodel {
  final repository = GetIt.instance.get<CountryRepository>();

  @override
  Future<HomeState> build() async {
    return _initialize();
  }

  Future<HomeState> _initialize() async {
    final result = await repository.fetchAllCountries();
    switch (result) {
      case Success<List<CountryResponse>>(:final value):
        return HomeState(
          countries: value,
        );
      case Failure(:final error):
        throw error;
    }
  }
}
