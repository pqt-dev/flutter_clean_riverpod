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
      AppPalette.mainColor: Colors.white,
      AppPalette.secondaryColor: Colors.black,
      AppPalette.primaryColor: Colors.white70,
      AppPalette.primaryTextColor: Colors.black,
      AppPalette.primaryBackground: Colors.white,
      AppPalette.secondaryBackground: const Color(0xffF5F5F5),
      AppPalette.errorColor: Colors.red,
      AppPalette.primaryTextFieldBackground: Colors.white54,
      AppPalette.secondaryButtonTitle: const Color(0xff0a9d8d),
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
      AppPalette.mainColor: Colors.black,
      AppPalette.secondaryColor: Colors.white,
      AppPalette.primaryColor: Colors.white24,
      AppPalette.primaryTextColor: Colors.white,
      AppPalette.primaryBackground: const Color(0xff28292C),
      AppPalette.secondaryBackground: const Color(0xff181A20),
      AppPalette.errorColor: Colors.red,
      AppPalette.primaryTextFieldBackground: Colors.black54,
      AppPalette.secondaryButtonTitle: Colors.black,
    },
  );
}
