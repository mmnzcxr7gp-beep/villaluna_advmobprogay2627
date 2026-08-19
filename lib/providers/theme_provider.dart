import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  static const Color primaryBlue = Color(0xFF354898);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color scaffoldBgLight = Color(0xFFF7F8FC);
  static const Color cardBgLight = Colors.white;

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: scaffoldBgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentGold,
          surface: cardBgLight,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryBlue,
          unselectedItemColor: Colors.grey,
          elevation: 8,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentGold,
          foregroundColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGold,
            foregroundColor: Colors.black87,
            elevation: 1,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentGold,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E2640),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: accentGold,
          unselectedItemColor: Colors.grey,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentGold,
          foregroundColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGold,
            foregroundColor: Colors.black87,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
}
