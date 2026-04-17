import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkElite() {
    const bg = Color(0xFF0B0F14);
    const surface = Color(0xFF141C26);
    const surfaceAlt = Color(0xFF1B2531);
    const accent = Color(0xFF7C5CFF);
    const accentTwo = Color(0xFF22D3EE);
    const text = Color(0xFFF2F5F8);
    const muted = Color(0xFF9BA9B8);

    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentTwo,
        surface: surface,
        onSurface: text,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          color: text,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        headlineSmall: const TextStyle(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(
          color: text,
          fontSize: 16,
          height: 1.35,
        ),
        bodyMedium: const TextStyle(
          color: muted,
          fontSize: 14,
          height: 1.35,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: const TextStyle(color: muted),
        labelStyle: const TextStyle(color: muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A3848)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentTwo, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF253447)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: text,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
