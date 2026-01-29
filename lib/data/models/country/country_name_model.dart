import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_name_model.freezed.dart';
part 'country_name_model.g.dart';

@freezed
abstract class CountryNameModel with _$CountryNameModel {
  const factory CountryNameModel({
    String? common,
    String? official,
  }) = _CountryNameModel;

  factory CountryNameModel.fromJson(Map<String, dynamic> json) => _$CountryNameModelFromJson(json);
}
