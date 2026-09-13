import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'theme_provider.dart';

/// Defines Dynamic Dark and Light ThemeData for APDM based on presets.
class AppTheme {
  AppTheme._();

  static ThemePalette _paletteFor(AppThemePreset preset, bool isDark) {
    if (!isDark) return AppColors.lightPalette;
    switch (preset) {
      case AppThemePreset.midnightAmber:
        return AppColors.midnightAmber;
      case AppThemePreset.templeGold:
        return AppColors.templeGold;
      case AppThemePreset.sandalwoodRose:
        return AppColors.sandalwoodRose;
      case AppThemePreset.forestSage:
        return AppColors.forestSage;
      case AppThemePreset.royalAmethyst:
        return AppColors.royalAmethyst;
      case AppThemePreset.amoledOnyx:
        return AppColors.amoledOnyx;
    }
  }

  /// Builds a complete Material 3 ThemeData customized to the selected memorial preset.
  static ThemeData getTheme({
    required AppThemePreset preset,
    required bool isDark,
  }) {
    final palette = _paletteFor(preset, isDark);

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: palette.primary,
            onPrimary: Colors.black,
            primaryContainer: palette.primaryDark,
            onPrimaryContainer: Colors.white,
            secondary: palette.secondary,
            onSecondary: Colors.black,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            error: const Color(0xFFCF6679),
            onError: Colors.black,
          )
        : ColorScheme.light(
            primary: palette.primary,
            onPrimary: Colors.white,
            primaryContainer: const Color(0xFFFDE8D0),
            onPrimaryContainer: palette.primaryDark,
            secondary: palette.secondary,
            onSecondary: Colors.white,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            error: const Color(0xFFB00020),
            onError: Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      cardColor: palette.card,
      dividerColor: palette.border,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: palette.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : Colors.black.withAlpha(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? palette.surface : const Color(0xFFF2ECE1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 1.8),
        ),
        hintStyle: TextStyle(color: palette.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: palette.textSecondary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.primary,
        thumbColor: palette.primary,
        inactiveTrackColor: palette.border,
        overlayColor: palette.accentGlow,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return palette.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary.withAlpha(90);
          }
          return isDark ? const Color(0xFF2C394E) : const Color(0xFFE5DDD0);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // Legacy fallback getters
  static ThemeData get darkTheme => getTheme(
        preset: AppThemePreset.midnightAmber,
        isDark: true,
      );

  static ThemeData get lightTheme => getTheme(
        preset: AppThemePreset.midnightAmber,
        isDark: false,
      );
}

