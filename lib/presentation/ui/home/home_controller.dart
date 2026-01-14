import 'package:flutter_clean_riverpod/data/repository/country/country_repository.dart';
import 'package:flutter_clean_riverpod/data/response/country/country_response.dart';
import 'package:flutter_clean_riverpod/presentation/ui/home/home_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../data/core/api_result.dart';

final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeState>(
  () {
    final repository = GetIt.I.get<CountryRepository>();
    return HomeController(repository);
  },
);

class HomeController extends AsyncNotifier<HomeState> {
  final CountryRepository repository;

  HomeController(this.repository);

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
