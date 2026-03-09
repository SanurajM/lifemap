import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF080A0F);
  static const surface = Color(0xFF0E1117);
  static const card = Color(0xFF13181F);
  static const border = Color(0xFF1C2230);
  static const accent = Color(0xFFF5A623);
  static const accentDark = Color(0xFFC8841A);
  static const teal = Color(0xFF00D4AA);
  static const blue = Color(0xFF4A9EFF);
  static const rose = Color(0xFFFF6B8A);
  static const violet = Color(0xFFA78BFA);
  static const textPrimary = Color(0xFFEEF0F6);
  static const textSub = Color(0xFF9CA3B0);
  static const textMuted = Color(0xFF4B5563);
  static const success = Color(0xFF22D3A0);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFF87171);

  static Color accentSoft = accent.withOpacity(0.12);
  static Color tealSoft = teal.withOpacity(0.12);
  static Color blueSoft = blue.withOpacity(0.12);
  static Color roseSoft = rose.withOpacity(0.12);
  static Color violetSoft = violet.withOpacity(0.12);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.teal,
        surface: AppColors.surface,
        background: AppColors.bg,
      ),
      textTheme: GoogleFonts.soraTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.sora(fontSize: 36, fontWeight: FontWeight.w300, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSub),
        bodySmall: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textMuted),
        labelLarge: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 1.0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
      dividerColor: AppColors.border,
    );
  }
}
