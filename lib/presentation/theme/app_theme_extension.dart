import 'package:flutter/material.dart';

enum Palette {
  primaryTextColor,
  errorColor,
  primaryBackground,
  secondaryBackground,
  primaryTextFieldBackground,
  primaryButtonBackground,
  primaryButtonText,
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Map<Palette, Color> colors;

  const AppThemeExtension({required this.colors});

  Color getColor(Palette key) {
    assert(colors[key] != null);
    return colors[key]!;
  }

  @override
  ThemeExtension<AppThemeExtension> copyWith({Map<Palette, Color>? colors}) {
    return AppThemeExtension(colors: colors ?? this.colors);
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;

    final mergedColors = <Palette, Color>{};
    final allKeys = {...colors.keys, ...other.colors.keys};

    for (final key in allKeys) {
      final a = colors[key];
      final b = other.colors[key];
      mergedColors[key] = Color.lerp(a, b, t) ?? a ?? b!;
    }

    return AppThemeExtension(colors: mergedColors);
  }
}
