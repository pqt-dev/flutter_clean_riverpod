import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/theme/app_theme_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme =
      ThemeData.light(
        useMaterial3: false,
      ).copyWith(
        extensions: [
          _lightThemeExtension,
        ],
        textTheme: GoogleFonts.ubuntuTextTheme(),
      );

  static final _lightThemeExtension = AppThemeExtension(
    colors: {
      Palette.primaryTextColor: Colors.black,
      Palette.primaryBackground: Colors.white,
      Palette.secondaryBackground: Colors.white70,
      Palette.errorColor: Colors.red,
      Palette.primaryTextFieldBackground: Colors.white12,
      Palette.primaryButtonBackground: Colors.black87,
      Palette.primaryButtonText: Colors.white,
    },
  );

  static final darkTheme =
      ThemeData.dark(
        useMaterial3: false,
      ).copyWith(
        extensions: [
          _darkThemeExtension,
        ],
        textTheme: GoogleFonts.ubuntuTextTheme(),
      );

  static final _darkThemeExtension = AppThemeExtension(
    colors: {
      Palette.primaryTextColor: Colors.white,
      Palette.primaryBackground: Colors.black,
      Palette.secondaryBackground: Colors.black54,
      Palette.errorColor: Colors.red,
      Palette.primaryTextFieldBackground: Colors.black12,
      Palette.primaryButtonBackground: Colors.white70,
      Palette.primaryButtonText: Colors.black87,
    },
  );
}
