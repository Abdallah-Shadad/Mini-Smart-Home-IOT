import 'package:flutter/material.dart';

class AppColors {
  // Primary brand — deep space teal
  static const primary = Color(0xFF00C9A7);
  static const primaryDark = Color(0xFF00A88A);
  static const secondary = Color(0xFF4ECDC4);
  static const accent = Color(0xFFFFE66D);

  // Dark theme surfaces
  static const darkBg = Color(0xFF0D1117);
  static const darkSurface = Color(0xFF161B22);
  static const darkCard = Color(0xFF1C2128);
  static const darkBorder = Color(0xFF30363D);

  // Light theme surfaces
  static const lightBg = Color(0xFFF6F8FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE1E4E8);

  // Sensor / status colors
  static const tempColor = Color(0xFFFF6B6B);
  static const humidColor = Color(0xFF74B9FF);
  static const lightColor = Color(0xFFFFE66D);
  static const onlineColor = Color(0xFF00C9A7);
  static const offlineColor = Color(0xFFFF4757);

  // NEW: MQ2 gas sensor
  static const gasColor = Color(0xFFB8860B); // dark goldenrod / smoky amber

  // NEW: Flame sensor
  static const flameColor = Color(0xFFFF4500); // OrangeRed — fire

  // NEW: Buzzer
  static const buzzerColor = Color(0xFF9B59B6); // Purple

  // LED colors
  static const redLed = Color(0xFFFF4757);
  static const greenLed = Color(0xFF2ED573);
  static const yellowLed = Color(0xFFFFE66D);

  // Alert types
  static const alertWarning = Color(0xFFFFBE21);
  static const alertDanger = Color(0xFFFF4757);
  static const alertInfo = Color(0xFF74B9FF);
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        background: AppColors.darkBg,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        surfaceVariant: AppColors.darkCard,
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      cardColor: AppColors.darkCard,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.primary;
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.4);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primary,
        inactiveTrackColor: AppColors.primary.withOpacity(0.2),
        overlayColor: AppColors.primary.withOpacity(0.1),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(color: Color(0xFFB0BAC5)),
        bodySmall: TextStyle(color: Color(0xFF8B95A1)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        background: AppColors.lightBg,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: const Color(0xFF1A1A2E),
        onBackground: const Color(0xFF1A1A2E),
        surfaceVariant: AppColors.lightCard,
        outline: AppColors.lightBorder,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      cardColor: AppColors.lightCard,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.primary;
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.4);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primary,
        inactiveTrackColor: AppColors.primary.withOpacity(0.2),
        overlayColor: AppColors.primary.withOpacity(0.1),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: Color(0xFF1A1A2E),
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Color(0xFF1A1A2E),
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: Color(0xFF1A1A2E),
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
        bodyMedium: TextStyle(color: Color(0xFF57606A)),
        bodySmall: TextStyle(color: Color(0xFF8B949E)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
