// lib/ui/themes/app_themes.dart
import 'package:flutter/material.dart';

class AppThemes {
  // Light Theme configuration
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue, // Primary color for the app
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0, // No shadow for app bar
    ),
    cardColor: Colors.white, // Background color for cards
    scaffoldBackgroundColor: Colors.grey[100], // Background color for the main screen
    visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts UI density
    textTheme: const TextTheme(
      // Removed fontFamily: 'Inter' to use default font
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
      titleMedium: TextStyle(),
      bodyMedium: TextStyle(),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold), // For section titles
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none, // No border line
      ),
      filled: true, // Fill the background of the input field
      fillColor: Colors.grey[200], // Background color for input fields
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600], // Button background color
        foregroundColor: Colors.white, // Button text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners for buttons
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), // Removed fontFamily
        elevation: 3, // Button shadow
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue[600],
        textStyle: const TextStyle(), // Removed fontFamily
      ),
    ),
  );

  // Dark Theme configuration
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: Colors.grey[850],
    scaffoldBackgroundColor: Colors.grey[900],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: const TextTheme(
      // Removed fontFamily: 'Inter' and explicit color to use default dark theme colors
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
      titleMedium: TextStyle(),
      bodyMedium: TextStyle(),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold), // For section titles
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[700],
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), // Removed fontFamily
        elevation: 3,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.indigo[600],
        textStyle: const TextStyle(), // Removed fontFamily
      ),
    ),
  );
}