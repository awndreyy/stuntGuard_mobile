import 'package:flutter/material.dart';

/// Warna yang digunakan layar Beranda StunGuard.
/// Class SG dipertahankan agar file screen/widget lama tidak perlu diubah.
class SG {
  static const Color primary = Color(0xFFAC3156);
  static const Color primaryDark = Color(0xFF852641);
  static const Color pale = Color(0xFFF6E3E7);
  static const Color soft = Color(0xFFFCF5F1);
  static const Color background = Color(0xFFFFFDFA);
  static const Color ink = Color(0xFF352F32);
  static const Color muted = Color(0xFF6B6265);
  static const Color line = Color(0xFFEADEDB);
  static const Color surface = Colors.white;
}

class SgTheme {
  static const Color primary = SG.primary;
  static const Color background = SG.background;
  static const Color surface = SG.surface;

  static ThemeData get lightTheme {
    final base = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: base.copyWith(primary: primary, surface: surface),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: SG.ink,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: SG.pale,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? primary : SG.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected) ? primary : SG.muted,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SG.line),
        ),
      ),
    );
  }
}
