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
      Palette.mainColor: Colors.white,
      Palette.secondaryColor: Colors.black,
      Palette.primaryColor: Colors.white70,
      Palette.primaryTextColor: Colors.black,
      Palette.primaryBackground: Colors.white,
      Palette.secondaryBackground: const Color(0xffF5F5F5),
      Palette.errorColor: Colors.red,
      Palette.primaryTextFieldBackground: Colors.white54,
      Palette.secondaryButtonTitle: const Color(0xff0a9d8d),
    },
  );

  static final darkTheme = ThemeData.dark(useMaterial3: false).copyWith(
    extensions: [
      _darkThemeExtension,
    ],
    textTheme: GoogleFonts.ubuntuTextTheme(),
  );

  static final _darkThemeExtension = AppThemeExtension(
    colors: {
      Palette.mainColor: Colors.black,
      Palette.secondaryColor: Colors.white,
      Palette.primaryColor: Colors.white24,
      Palette.primaryTextColor: Colors.white,
      Palette.primaryBackground: const Color(0xff28292C),
      Palette.secondaryBackground: const Color(0xff181A20),
      Palette.errorColor: Colors.red,
      Palette.primaryTextFieldBackground: Colors.black54,
      Palette.secondaryButtonTitle: Colors.black,
    },
  );
}
