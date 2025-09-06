// lib/ui/themes/app_themes.dart
import 'package:flutter/material.dart';

class AppThemes {
  // Teenage Engineering-inspired color palette
  static const Color teBlue = Color(0xFF1270B8);
  static const Color teTeal = Color(0xFF1AA167);
  static const Color teRed = Color(0xFFDC3545);
  static const Color teWhite = Color(0xFFFFFFFF);
  static const Color teLightGray = Color(0xFFF8F8F8);
  static const Color tePanelGray = Color(0xFFEFEFF4);
  static const Color teDark = Color(0xFF1C1C1E);
  static const Color teDarkPanel = Color(0xFF23232A);
  static const Color teTextDark = Color(0xFF333333);
  static const Color teTextLight = Color(0xFFE0E0E0);

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: teBlue,
      onPrimary: teWhite,
      secondary: teTeal,
      onSecondary: teWhite,
      error: teRed,
      onError: teWhite,
      background: teLightGray,
      onBackground: teTextDark,
      surface: tePanelGray,
      onSurface: teTextDark,
    ),
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: teLightGray,
    cardTheme: CardTheme(
      color: tePanelGray,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: teBlue.withOpacity(0.08)),
      ),
      surfaceTintColor: tePanelGray,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: teWhite,
      foregroundColor: teTextDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: teTextDark,
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 22,
        letterSpacing: 1.2,
      ),
      iconTheme: const IconThemeData(color: teBlue),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 28),
      displaySmall: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 24),
      headlineLarge: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 22),
      headlineMedium: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 20),
      headlineSmall: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18),
      titleLarge: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18),
      titleMedium: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16),
      titleSmall: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
      bodyLarge: TextStyle(color: teTextDark, fontFamily: 'Inter', fontSize: 16),
      bodyMedium: TextStyle(color: teTextDark, fontFamily: 'Inter', fontSize: 14),
      bodySmall: TextStyle(color: teTextDark, fontFamily: 'Inter', fontSize: 12),
      labelLarge: TextStyle(color: teTextDark, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
      labelMedium: TextStyle(color: teTextDark, fontFamily: 'Inter', fontSize: 12),
      labelSmall: TextStyle(color: teTextDark, fontFamily: 'Inter', fontSize: 10),
      // Data/code displays:
      // Use Space Mono for code/data, override in widgets as needed
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: teBlue.withOpacity(0.2), width: 1.2),
      ),
      filled: true,
      fillColor: tePanelGray,
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
      labelStyle: TextStyle(color: teTextDark, fontFamily: 'Inter'),
      hintStyle: TextStyle(color: teTextDark.withOpacity(0.5), fontFamily: 'Inter'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: teBlue,
        foregroundColor: teWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        elevation: 2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: teBlue,
        foregroundColor: teWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: teBlue,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
      ),
    ),
    iconTheme: const IconThemeData(color: teBlue),
    dividerColor: teBlue.withOpacity(0.08),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: teBlue),
    chipTheme: ChipThemeData(
      backgroundColor: tePanelGray,
      labelStyle: const TextStyle(color: teTextDark, fontFamily: 'Inter'),
      selectedColor: teTeal.withOpacity(0.2),
      secondarySelectedColor: teTeal.withOpacity(0.3),
      disabledColor: tePanelGray.withOpacity(0.5),
      side: const BorderSide(color: teBlue, width: 1.2),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: teBlue,
      onPrimary: teDark,
      secondary: teTeal,
      onSecondary: teDark,
      error: teRed,
      onError: teWhite,
      background: teDark,
      onBackground: teTextLight,
      surface: teDarkPanel,
      onSurface: teTextLight,
    ),
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: teDark,
    cardTheme: CardTheme(
      color: teDarkPanel,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: teBlue.withOpacity(0.08)),
      ),
      surfaceTintColor: teDarkPanel,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: teDarkPanel,
      foregroundColor: teTextLight,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: teTextLight,
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 22,
        letterSpacing: 1.2,
      ),
      iconTheme: const IconThemeData(color: teBlue),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 28),
      displaySmall: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 24),
      headlineLarge: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 22),
      headlineMedium: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 20),
      headlineSmall: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18),
      titleLarge: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18),
      titleMedium: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16),
      titleSmall: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
      bodyLarge: TextStyle(color: teTextLight, fontFamily: 'Inter', fontSize: 16),
      bodyMedium: TextStyle(color: teTextLight, fontFamily: 'Inter', fontSize: 14),
      bodySmall: TextStyle(color: teTextLight, fontFamily: 'Inter', fontSize: 12),
      labelLarge: TextStyle(color: teTextLight, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
      labelMedium: TextStyle(color: teTextLight, fontFamily: 'Inter', fontSize: 12),
      labelSmall: TextStyle(color: teTextLight, fontFamily: 'Inter', fontSize: 10),
      // Data/code displays:
      // Use Space Mono for code/data, override in widgets as needed
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: teBlue.withOpacity(0.2), width: 1.2),
      ),
      filled: true,
      fillColor: teDarkPanel,
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
      labelStyle: TextStyle(color: teTextLight, fontFamily: 'Inter'),
      hintStyle: TextStyle(color: teTextLight.withOpacity(0.5), fontFamily: 'Inter'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: teBlue,
        foregroundColor: teDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        elevation: 2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: teBlue,
        foregroundColor: teDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: teBlue,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
      ),
    ),
    iconTheme: const IconThemeData(color: teBlue),
    dividerColor: teBlue.withOpacity(0.08),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: teBlue),
    chipTheme: ChipThemeData(
      backgroundColor: teDarkPanel,
      labelStyle: const TextStyle(color: teTextLight, fontFamily: 'Inter'),
      selectedColor: teTeal.withOpacity(0.2),
      secondarySelectedColor: teTeal.withOpacity(0.3),
      disabledColor: teDarkPanel.withOpacity(0.5),
      side: const BorderSide(color: teBlue, width: 1.2),
    ),
  );
}