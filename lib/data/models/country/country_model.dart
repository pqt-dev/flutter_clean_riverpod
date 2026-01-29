import 'package:flutter_clean_riverpod/data/models/country/country_flag_model.dart';
import 'package:flutter_clean_riverpod/data/models/country/country_name_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_model.freezed.dart';
part 'country_model.g.dart';

@freezed
abstract class CountryModel with _$CountryModel {
  const factory CountryModel({
    List<String>? capital,
    String? region,
    String? subregion,
    double? area,
    int? population,
    CountryNameModel? name,
    CountryFlagModel? flags,
  }) = _CountryModel;

  factory CountryModel.fromJson(Map<String, dynamic> json) => _$CountryModelFromJson(json);
}
