import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color palette. Keep every screen pulling from here so the
/// "premium" look stays consistent — this mirrors the colors used in
/// the HTML UI mockup we designed first.
class AppColors {
  AppColors._();

  static const violet1 = Color(0xFF2A0F6E);
  static const violet2 = Color(0xFF5B2BD9);
  static const violet3 = Color(0xFF7C3AED);

  static const gold1 = Color(0xFFFFD873);
  static const gold2 = Color(0xFFF5B942);

  static const bg = Color(0xFFF6F4FC);
  static const line = Color(0xFFECECF3);
  static const ink = Color(0xFF141026);
  static const muted = Color(0xFF6D6A85);

  static const cardShadow = Color(0x1A1E1450);

  // Card accent themes, one per earning option — matches the mockup's
  // t-violet / t-gold / t-teal / t-rose / t-blue / t-green tiles.
  static const tileThemes = <String, List<Color>>{
    'violet': [Color(0xFF9D6BFF), Color(0xFF5B21B6)],
    'gold': [Color(0xFFFFCF4D), Color(0xFFD97706)],
    'teal': [Color(0xFF3EE0C8), Color(0xFF0F766E)],
    'rose': [Color(0xFFFF8098), Color(0xFFBE123C)],
    'blue': [Color(0xFF6FB1FF), Color(0xFF1D4ED8)],
    'green': [Color(0xFF3FDC9C), Color(0xFF047857)],
  };

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet1, violet2, violet3],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold1, gold2],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violet2,
        primary: AppColors.violet2,
        background: AppColors.bg,
      ),
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet3,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
        ),
      ),
    );
  }
}
