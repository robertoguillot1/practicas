import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.amber,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16.0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.white,
    ),
  );
}
