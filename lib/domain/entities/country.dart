import 'package:freezed_annotation/freezed_annotation.dart';

part 'country.freezed.dart';

@freezed
abstract class Country with _$Country {
  const factory Country({
    List<String>? capital,
    String? region,
    String? subregion,
    double? area,
    int? population,
    CountryName? name,
    CountryFlag? flags,
  }) = _Country;
}

@freezed
abstract class CountryName with _$CountryName {
  const factory CountryName({
    String? common,
    String? official,
  }) = _CountryName;
}

@freezed
abstract class CountryFlag with _$CountryFlag {
  const factory CountryFlag({
    String? png,
    String? svg,
    String? alt,
  }) = _CountryFlag;
}
