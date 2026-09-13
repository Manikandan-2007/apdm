import 'package:flutter/material.dart';

/// Semantic color definition for an APDM theme preset.
class ThemePalette {
  final String id;
  final String englishName;
  final String tamilName;
  final String description;
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accentGlow;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const ThemePalette({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.description,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accentGlow,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  Color get accent => secondary;
}

/// Semantic and cohesive palette for APDM.
/// Designed for a calm, respectful, emotionally warm memorial atmosphere.
class AppColors {
  AppColors._();

  // Legacy fallback accents
  static const Color primaryWarm = Color(0xFFD99153);
  static const Color primaryLight = Color(0xFFE8AB75);
  static const Color primaryDark = Color(0xFFB57035);
  static const Color amberGlow = Color(0xFFFFBE76);

  static const Color secondarySage = Color(0xFF5A9E8F);
  static const Color secondarySageLight = Color(0xFF7CB8AB);
  static const Color secondarySageDark = Color(0xFF3F776B);

  // Voice Interaction State Tones
  static const Color voiceReady = Color(0xFF9E86C8); // Soft serene lavender
  static const Color voiceListening = Color(0xFF48CAE4); // Responsive sky cyan
  static const Color voiceProcessing = Color(0xFFF4A261); // Thoughtful warm amber
  static const Color voiceSpeaking = Color(0xFFE76F51); // Expressive gentle coral

  // Dark Theme Surfaces & Backgrounds
  static const Color darkBackground = Color(0xFF0F141C);
  static const Color darkSurface = Color(0xFF171F2C);
  static const Color darkSurfaceVariant = Color(0xFF212B3B);
  static const Color darkCard = Color(0xFF1C2535);
  static const Color darkBorder = Color(0xFF2C394E);

  // Dark Theme Typography
  static const Color darkTextPrimary = Color(0xFFF3F5F9);
  static const Color darkTextSecondary = Color(0xFFA6B2C4);
  static const Color darkTextMuted = Color(0xFF6E7D93);

  // Light Theme Surfaces & Backgrounds
  static const Color lightBackground = Color(0xFFFAF7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF2ECE1);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5DDD0);

  // Light Theme Typography
  static const Color lightTextPrimary = Color(0xFF231F1C);
  static const Color lightTextSecondary = Color(0xFF5E574E);
  static const Color lightTextMuted = Color(0xFF8F867B);

  // Category Accent Badges
  static const Color categoryPersonal = Color(0xFFD47A60);
  static const Color categoryFamily = Color(0xFF5B9E78);
  static const Color categoryStories = Color(0xFF638ECB);
  static const Color categoryEvents = Color(0xFFB8860B);
  static const Color categoryFavorites = Color(0xFF9B6BB0);
  static const Color categoryMessages = Color(0xFF4B9DA3);

  // 1. Midnight Amber Preset (Default)
  static const ThemePalette midnightAmber = ThemePalette(
    id: 'midnight_amber',
    englishName: 'Midnight Amber',
    tamilName: 'Pon Andhi',
    description: 'Serene obsidian with luminous warm amber gold glow',
    background: Color(0xFF0B0F17),
    surface: Color(0xFF141C28),
    card: Color(0xFF182232),
    border: Color(0xFF222E42),
    primary: Color(0xFFE09858),
    primaryLight: Color(0xFFF0B27A),
    primaryDark: Color(0xFFB86B28),
    accentGlow: Color(0x66E09858),
    secondary: Color(0xFF5A9E8F),
    textPrimary: Color(0xFFF3F5F9),
    textSecondary: Color(0xFFA6B2C4),
    textMuted: Color(0xFF6E7D93),
  );

  // 2. Sacred Temple Gold Preset
  static const ThemePalette templeGold = ThemePalette(
    id: 'temple_gold',
    englishName: 'Sacred Temple Gold',
    tamilName: 'Kovil Thangam',
    description: 'Sacred imperial navy with traditional gold and brass elegance',
    background: Color(0xFF0C1019),
    surface: Color(0xFF151E2E),
    card: Color(0xFF1A263B),
    border: Color(0xFF2A3A54),
    primary: Color(0xFFE5B842),
    primaryLight: Color(0xFFF5CE68),
    primaryDark: Color(0xFFC29524),
    accentGlow: Color(0x66E5B842),
    secondary: Color(0xFFE07A5F),
    textPrimary: Color(0xFFF8F6F0),
    textSecondary: Color(0xFFBAC3D6),
    textMuted: Color(0xFF7585A2),
  );

  // 3. Sandalwood & Rose Preset
  static const ThemePalette sandalwoodRose = ThemePalette(
    id: 'sandalwood_rose',
    englishName: 'Sandalwood & Rose',
    tamilName: 'Sandhanam & Roja',
    description: 'Deep warm mahogany with heartfelt rose gold warmth',
    background: Color(0xFF130E14),
    surface: Color(0xFF1E1620),
    card: Color(0xFF261C29),
    border: Color(0xFF3A2B3E),
    primary: Color(0xFFE88B9E),
    primaryLight: Color(0xFFF5A8B7),
    primaryDark: Color(0xFFC76277),
    accentGlow: Color(0x66E88B9E),
    secondary: Color(0xFFD4A373),
    textPrimary: Color(0xFFFBF4F6),
    textSecondary: Color(0xFFC7B3C0),
    textMuted: Color(0xFF867280),
  );

  // 4. Forest Sage Preset
  static const ThemePalette forestSage = ThemePalette(
    id: 'forest_sage',
    englishName: 'Serene Forest Sage',
    tamilName: 'Thulasi & Vanam',
    description: 'Peaceful spruce evergreen with healing jade and herbal sage',
    background: Color(0xFF0A1310),
    surface: Color(0xFF12201B),
    card: Color(0xFF182B24),
    border: Color(0xFF244036),
    primary: Color(0xFF5EB69D),
    primaryLight: Color(0xFF7ECEB7),
    primaryDark: Color(0xFF3E8D77),
    accentGlow: Color(0x665EB69D),
    secondary: Color(0xFF81B29A),
    textPrimary: Color(0xFFF0F7F4),
    textSecondary: Color(0xFFACBEB7),
    textMuted: Color(0xFF6B8077),
  );

  // 5. Royal Amethyst Preset
  static const ThemePalette royalAmethyst = ThemePalette(
    id: 'royal_amethyst',
    englishName: 'Royal Amethyst',
    tamilName: 'Raja Oodha',
    description: 'Celestial twilight with timeless spiritual lavender glow',
    background: Color(0xFF100D18),
    surface: Color(0xFF1C162B),
    card: Color(0xFF241C36),
    border: Color(0xFF362A52),
    primary: Color(0xFFAF88F0),
    primaryLight: Color(0xFFC8A7FC),
    primaryDark: Color(0xFF8E5EE0),
    accentGlow: Color(0x66AF88F0),
    secondary: Color(0xFF70C1B3),
    textPrimary: Color(0xFFF5F2FB),
    textSecondary: Color(0xFFBEB5D2),
    textMuted: Color(0xFF7D7296),
  );

  // 6. AMOLED Onyx Preset
  static const ThemePalette amoledOnyx = ThemePalette(
    id: 'amoled_onyx',
    englishName: 'True AMOLED Onyx',
    tamilName: 'Muzhu Karuppu',
    description: '100% pure OLED black with vivid solar amber highlights',
    background: Color(0xFF000000),
    surface: Color(0xFF0F0F0F),
    card: Color(0xFF161616),
    border: Color(0xFF262626),
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFBBF24),
    primaryDark: Color(0xFFD97706),
    accentGlow: Color(0x66F59E0B),
    secondary: Color(0xFF10B981),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA3A3A3),
    textMuted: Color(0xFF525252),
  );

  // Light Theme Palette
  static const ThemePalette lightPalette = ThemePalette(
    id: 'light_linen',
    englishName: 'Ivory Linen',
    tamilName: 'Vellai & Sandhanam',
    description: 'Warm daylight linen with antique bronze and parchment notes',
    background: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE8DFD3),
    primary: Color(0xFFB86B28),
    primaryLight: Color(0xFFD99153),
    primaryDark: Color(0xFF8F4D14),
    accentGlow: Color(0x33B86B28),
    secondary: Color(0xFF4D8578),
    textPrimary: Color(0xFF231F1C),
    textSecondary: Color(0xFF5E574E),
    textMuted: Color(0xFF8F867B),
  );
}

