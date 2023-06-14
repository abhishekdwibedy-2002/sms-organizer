import 'package:flutter/material.dart';

class TAppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 103, 58, 183)),
    useMaterial3: true,
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    appBarTheme:
        const AppBarTheme(foregroundColor: Color.fromARGB(255, 58, 173, 181)),
  );
}
