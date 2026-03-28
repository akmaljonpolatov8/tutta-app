import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _background = Color(0xFFF7F9FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _surfaceRaised = Color(0xFFF0F4FA);
  static const _accent = Color(0xFF1A5EFF);
  static const _secondary = Color(0xFFFF8A3D);
  static const _text = Color(0xFF12203A);

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _accent,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.white,
      error: Color(0xFFD64545),
      onError: Colors.white,
      surface: _surface,
      onSurface: _text,
      surfaceContainerHighest: _surfaceRaised,
      onSurfaceVariant: Color(0xFF5D6C8A),
      outline: Color(0xFFD4DEEE),
      outlineVariant: Color(0xFFE5EBF6),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF0F1B2E),
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFF8DB0FF),
      tertiary: Color(0xFF6FD3B4),
      onTertiary: Color(0xFF0E2A21),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _text,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: _text),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: _text),
        bodyMedium: TextStyle(height: 1.35, color: _text),
        bodySmall: TextStyle(color: Color(0xFF6F7D99)),
      ),
      dividerColor: const Color(0x1F102040),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE5F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE5F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6F7D99)),
        hintStyle: const TextStyle(color: Color(0xFF8A97AF)),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0x661A5EFF);
          }
          return const Color(0x3397A6C3);
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _accent;
          }
          return const Color(0xFF97A6C3);
        }),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: _text,
        textColor: _text,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE1E8F5)),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        indicatorColor: Color(0x1A1A5EFF),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: Color(0xFF5D6C8A)),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: Color(0xFF5D6C8A), fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF2F5FC),
        selectedColor: const Color(0x261A5EFF),
        disabledColor: const Color(0xFFE7EDF8),
        side: const BorderSide(color: Color(0xFFDCE5F5)),
        labelStyle: const TextStyle(
          color: _text,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(color: _accent),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _accent),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          foregroundColor: _text,
          side: const BorderSide(color: Color(0xFFDCE5F5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        modalBackgroundColor: Color(0xFFFFFFFF),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: Color(0xFFFFFFFF)),
    );
  }

  static ThemeData get dark => light;
}
