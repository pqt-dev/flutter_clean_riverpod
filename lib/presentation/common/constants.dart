import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Constants {
  static const Locale enUS = Locale('en', 'US');
  static const Locale viVN = Locale('vi', 'VN');
  static const Locale jaJP = Locale('ja', 'JP');

  static const String assetTranslationPath = "assets/translations";

  // Datetime format
  static final dmyFormat = DateFormat('dd/MM/yyyy');
  static final weekendFormat = DateFormat('EEE');
  static final eDmyFormat = DateFormat('EEEE, MMMM dd yyyy');

  static const emailSupport = "support.inc@gmail.com";
  static const themeModeKey = "theme_mode_key";
}
