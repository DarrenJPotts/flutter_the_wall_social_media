import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    colorScheme: ColorScheme.dark(
        background: Colors.black87,
        primary: Colors.grey[900]!,
        onPrimary: Colors.white,
        secondary: Colors.grey[800]!,
        onSecondary: Colors.grey[500]!));
