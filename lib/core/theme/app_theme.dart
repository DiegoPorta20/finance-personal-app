import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark
  static const background = Color(0xFF0E0E0F);
  static const card = Color(0xFF1C1C1E);
  static const accent = Color(0xFFA4E832);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF9A9A9A);
  static const error = Color(0xFFFF5252);
  static const divider = Color(0xFF2C2C2E);

  // Light
  static const lightBackground = Color(0xFFF5F5F7);
  static const lightCard = Colors.white;
  static const lightTextPrimary = Color(0xFF1C1C1E);
  static const lightTextSecondary = Color(0xFF8E8E93);
  static const lightDivider = Color(0xFFE5E5EA);
}

/// Colores resueltos según el tema actual (claro/oscuro).
/// Usar `context.cCard`, `context.cTextPrimary`, etc. en los widgets en vez de
/// los colores fijos oscuros de [AppColors], para que el tema claro funcione.
extension ThemeColors on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;
  Color get cBg =>
      _isDark ? AppColors.background : AppColors.lightBackground;
  Color get cCard => _isDark ? AppColors.card : AppColors.lightCard;
  Color get cTextPrimary =>
      _isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
  Color get cTextSecondary =>
      _isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get cDivider => _isDark ? AppColors.divider : AppColors.lightDivider;
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.card,
        primary: AppColors.accent,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
          color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        labelLarge: TextStyle(
          color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      dividerColor: AppColors.divider,
    );
  }

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightCard,
        primary: AppColors.accent,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightDivider),
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightCard,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.lightTextSecondary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.lightTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
          color: AppColors.lightTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
          color: AppColors.lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
          color: AppColors.lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
        labelLarge: TextStyle(
          color: AppColors.lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      dividerColor: AppColors.lightDivider,
    );
  }
}
