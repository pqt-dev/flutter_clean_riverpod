import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme_extension.dart';

extension BuildContextExt on BuildContext {
  Color? color(Palette key) {
    final theme = Theme.of(this).extension<AppThemeExtension>();
    return theme?.getColor(key);
  }

  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }

  Future<T?> shellPush<T extends Object?>(
    String location, {
    Object? extra,
    required String parent,
  }) => push(parent + location, extra: extra);
}
