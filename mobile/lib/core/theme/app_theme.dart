import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.secondary,
          onSecondary: AppColors.white,
          error: AppColors.error,
          onError: AppColors.white,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.textPrimaryLight,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        fontFamily: 'Inter',
        textTheme: _buildTextTheme(AppColors.textPrimaryLight),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.labelLarge,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondaryLight),
        ),
        cardTheme: CardTheme(
          color: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.grey200),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerLight,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.grey100,
          selectedColor: AppColors.primary,
          labelStyle: AppTextStyles.labelMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondary,
          onSecondary: AppColors.white,
          error: AppColors.error,
          onError: AppColors.white,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        fontFamily: 'Inter',
        textTheme: _buildTextTheme(AppColors.textPrimaryDark),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.labelLarge,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.primaryLight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.grey800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondaryDark),
        ),
        cardTheme: CardTheme(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.grey700),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.grey500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 1,
        ),
      );

  static TextTheme _buildTextTheme(Color color) => TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: color),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: color),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: color),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: color),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: color),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: color),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: color),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: color),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: color),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: color),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: color),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: color),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: color),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: color),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: color),
      );
}
