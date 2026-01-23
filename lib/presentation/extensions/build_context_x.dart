import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

extension ThemeX on BuildContext {
  Color? color(Palette key) {
    final theme = Theme.of(this).extension<AppThemeExtension>();
    return theme?.getColor(key);
  }

  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}
