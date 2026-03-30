import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Helpers for colored variants
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  static TextStyle primaryText(TextStyle style) =>
      style.copyWith(color: AppColors.primary);
}
