import 'package:flutter/material.dart';

class AppColors {
  // Special Coffee
  static const Color velvetMerlot = Color(0xFF481009);
  static const Color velvetBourbon = Color(0xFF45242D);

  // Neutral
  static const Color carbon = Color(0xFF1D1D1B);
  static const Color grayScale1 = Color(0xFF595959);
  static const Color grayScale2 = Color(0xFFA0A0A0);
  static const Color whiteWhite = Color(0xFFFFFFFF);
  static const Color moonAsh = Color(0xFFF4F4F4);
  static const Color roseClay = Color(0xFFBAA69E);
  static const Color oatWhite = Color(0xFFE7E4DE);

  // Contrast Color
  static const Color forestInk = Color(0xFF00503A);
  static const Color eletricBlue = Color(0xFF00F2FF);
  static const Color cyberLime = Color(0xFF00FF87);
  static const Color pear = Color(0xFFC2F530);
  static const Color spiced = Color(0xFFFF3A2A);
  static const Color sunsetBlaze = Color(0xFFFF583C);
  static const Color papayaSensorial = Color(0xFFEB8052);
  static const Color softRose = Color(0xFFF7B8B3);

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
  static const Color coffeeBean = velvetBourbon;
  static const Color coffeeLight = roseClay;
  static const Color coffeeDark = velvetMerlot;

  // Gradientes
  static const LinearGradient coffeeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [velvetMerlot, velvetBourbon],
  );

  static const LinearGradient neutralGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [moonAsh, oatWhite],
  );
}

// Tema Material 3 personalizado para o Kafex
class AppTheme {
  
  // LIGHT THEME - Material 3
  static ThemeData get lightTheme {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.velvetMerlot,
      brightness: Brightness.light,
      // Personalizações específicas do Kafex
      primary: AppColors.velvetMerlot,
      onPrimary: AppColors.whiteWhite,
      secondary: AppColors.papayaSensorial,
      onSecondary: AppColors.whiteWhite,
      tertiary: AppColors.roseClay,
      onTertiary: AppColors.carbon,
      surface: AppColors.whiteWhite,
      onSurface: AppColors.carbon,
      background: AppColors.oatWhite,
      onBackground: AppColors.carbon,
      error: AppColors.spiced,
      onError: AppColors.whiteWhite,
      outline: AppColors.grayScale2,
      shadow: AppColors.carbon.withOpacity(0.1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      
      // TIPOGRAFIA - Material 3 com fontes do Kafex
      textTheme: const TextTheme(
        // Display (títulos grandes)
        displayLarge: TextStyle(
          fontFamily: 'Monigue',
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Monigue',
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Monigue',
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        
        // Headlines (títulos)
        headlineLarge: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        
        // Títulos (seções)
        titleLarge: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        
        // Corpo de texto
        bodyLarge: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        
        // Labels (botões, campos)
        labelLarge: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // APP BAR - Material 3
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Albert Sans',
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.carbon,
        ),
      ),

      // BOTÕES - Material 3
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          elevation: 1,
          shadowColor: lightColorScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // M3 usa bordas mais arredondadas
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Albert Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          side: BorderSide(color: lightColorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // CARDS - Material 3
      cardTheme: CardThemeData(
        color: lightColorScheme.surface,
        shadowColor: lightColorScheme.shadow,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // M3 usa bordas mais arredondadas
        ),
      ),

      // INPUT FIELDS - Material 3
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightColorScheme.error, width: 1),
        ),
        labelStyle: TextStyle(
          color: lightColorScheme.onSurfaceVariant,
          fontFamily: 'Albert Sans',
        ),
        hintStyle: TextStyle(
          color: lightColorScheme.onSurfaceVariant.withOpacity(0.6),
          fontFamily: 'Albert Sans',
        ),
      ),

      // BOTTOM NAVIGATION - Material 3
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightColorScheme.surface,
        selectedItemColor: lightColorScheme.primary,
        unselectedItemColor: lightColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 3,
      ),

      // FAB - Material 3
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primaryContainer,
        foregroundColor: lightColorScheme.onPrimaryContainer,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // DIVIDER
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outlineVariant,
        thickness: 1,
      ),
    );
  }

  // DARK THEME - Material 3 (para futuro)
  static ThemeData get darkTheme {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.velvetMerlot,
      brightness: Brightness.dark,
      primary: AppColors.papayaSensorial,
      onPrimary: AppColors.carbon,
      secondary: AppColors.roseClay,
      surface: AppColors.carbon,
      onSurface: AppColors.whiteWhite,
      background: const Color(0xFF121212),
      onBackground: AppColors.whiteWhite,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
    );
  }
}

// Extensões úteis para usar com Material 3
extension AppColorsExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  
  // Helpers para acessar cores do Kafex
  Color get kafexPrimary => AppColors.velvetMerlot;
  Color get kafexSecondary => AppColors.papayaSensorial;
  Color get kafexBackground => AppColors.oatWhite;
}