import 'package:flutter/material.dart';

class AppColors {
  // Cores Especiais de Café
  static const Color velvetMerlot = Color(0xFF6B1B3A);
  static const Color velvetBourbon = Color(0xFF7A2448);

  // Cores Neutras
  static const Color carbon = Color(0xFF1C1C1C);
  static const Color grayScale1 = Color(0xFF4A4A4A);
  static const Color grayScale2 = Color(0xFF7A7A7A);
  static const Color whiteWhite = Color(0xFFFFFFFF);
  static const Color moonAsh = Color(0xFFE8E8E8);
  static const Color roseClay = Color(0xFFD4B5A0);
  static const Color oatWhite = Color(0xFFF5F5F0);

  // Cores de Contraste
  static const Color forestInk = Color(0xFF2D5A3D);
  static const Color eletricBlue = Color(0xFF00BFFF);
  static const Color cyberLime = Color(0xFF39FF14);
  static const Color pear = Color(0xFFD1E231);
  static const Color spiced = Color(0xFFE53E3E);
  static const Color sunsetBlaze = Color(0xFFFF6B35);
  static const Color papayaSensorial = Color(0xFFFFAB40);
  static const Color softRose = Color(0xFFFFB6C1);

  // Cores principais do tema Kafex
  static const Color primary = velvetMerlot;
  static const Color secondary = roseClay;
  static const Color background = oatWhite;
  static const Color surface = whiteWhite;
  static const Color error = spiced;
  static const Color success = forestInk;
  static const Color warning = papayaSensorial;
  static const Color info = eletricBlue;

  // Cores de texto
  static const Color textPrimary = carbon;
  static const Color textSecondary = grayScale1;
  static const Color textTertiary = grayScale2;
  static const Color textOnPrimary = whiteWhite;
  static const Color textOnSecondary = carbon;

  // Cores específicas para café
  static const Color coffeeBean = Color(0xFF8B4513);
  static const Color coffeeLight = Color(0xFFD2B48C);
  static const Color coffeeDark = Color(0xFF654321);

  // Gradientes
  static const LinearGradient coffeeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [velvetMerlot, coffeeBean],
  );

  static const LinearGradient neutralGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [moonAsh, oatWhite],
  );
}

// Tema personalizado para o app
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.whiteWhite,
      ),

      // Configuração de AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.whiteWhite,
        elevation: 0,
        centerTitle: true,
      ),

      // Configuração de botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.whiteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Configuração de cards
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        shadowColor: AppColors.grayScale2,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Configuração de input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.moonAsh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // Configuração de texto com fontes personalizadas
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Albert Sans',
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Albert Sans',
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Albert Sans',
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Albert Sans',
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Albert Sans',
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Albert Sans',
          color: AppColors.textTertiary,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Extensões úteis para cores
extension AppColorsExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}