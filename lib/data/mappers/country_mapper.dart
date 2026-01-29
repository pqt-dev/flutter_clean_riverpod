import 'package:flutter_clean_riverpod/data/models/country/country_flag_model.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_model.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_name_model.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';

extension CountryModelMapper on CountryModel {
  Country toEntity() {
    return Country(
      capital: capital,
      region: region,
      subregion: subregion,
      area: area,
      population: population,
      name: name?.toEntity(),
      flags: flags?.toEntity(),
    );
  }
}

extension CountryNameModelMapper on CountryNameModel {
  CountryName toEntity() {
    return CountryName(
      common: common,
      official: official,
    );
  }
}

extension CountryFlagModelMapper on CountryFlagModel {
  CountryFlag toEntity() {
    return CountryFlag(
      png: png,
      svg: svg,
      alt: alt,
    );
  }
}
