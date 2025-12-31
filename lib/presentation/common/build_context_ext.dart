import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/data/error/api_error.dart';

import '../../generated/locale_keys.g.dart';
import '../theme/app_theme_extension.dart';

extension BuildContextExt on BuildContext {
  Color color(AppPalette key) {
    final theme = Theme.of(this).extension<AppThemeExtension>();
    if (theme == null) {
      return Colors.orange;
    }
    return theme.getColor(key);
  }

  bool get isDarkTheme {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }

  Future<T?> showError<T>(Object? error) async {
    if (error is RequestApiError) {
      return showAlertDialog(
        context: this,
        message: LocaleKeys.api_error.tr(),
        title: LocaleKeys.oops.tr(),
      );
    }
    if (error is InternetError) {
      return showAlertDialog(
        context: this,
        title: LocaleKeys.oops.tr(),
        message: LocaleKeys.internet_error.tr(),
      );
    }
    return showAlertDialog(
      context: this,
      title: LocaleKeys.oops.tr(),
      message: LocaleKeys.unknown_error.tr(),
    );
  }
}
