import 'package:flutter/material.dart';

abstract class ThemeRepository {
  Future<void> save(ThemeMode theme);

  Future<ThemeMode> fetch();
}
