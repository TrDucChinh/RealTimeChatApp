import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.black54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        labelStyle: TextStyle(color: Colors.white70),
      ),
    );
  }
}
