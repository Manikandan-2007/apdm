import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Available memorial theme presets.
enum AppThemePreset {
  midnightAmber,
  templeGold,
  sandalwoodRose,
  forestSage,
  royalAmethyst,
  amoledOnyx,
}

/// Extension to provide localized names and descriptions for presets.
extension AppThemePresetX on AppThemePreset {
  String get nameEnglish {
    switch (this) {
      case AppThemePreset.midnightAmber:
        return 'Midnight Amber';
      case AppThemePreset.templeGold:
        return 'Sacred Temple Gold';
      case AppThemePreset.sandalwoodRose:
        return 'Sandalwood & Rose';
      case AppThemePreset.forestSage:
        return 'Serene Forest Sage';
      case AppThemePreset.royalAmethyst:
        return 'Royal Amethyst';
      case AppThemePreset.amoledOnyx:
        return 'True AMOLED Onyx';
    }
  }

  String get nameTamil {
    switch (this) {
      case AppThemePreset.midnightAmber:
        return 'Pon Andhi (Midnight Amber)';
      case AppThemePreset.templeGold:
        return 'Kovil Thangam (Temple Gold)';
      case AppThemePreset.sandalwoodRose:
        return 'Sandhanam & Roja (Sandalwood)';
      case AppThemePreset.forestSage:
        return 'Amaidhi Vanam (Forest Sage)';
      case AppThemePreset.royalAmethyst:
        return 'Aranmanai Oodha (Amethyst)';
      case AppThemePreset.amoledOnyx:
        return 'Muzhu Karuppu (AMOLED Onyx)';
    }
  }

  String get description {
    switch (this) {
      case AppThemePreset.midnightAmber:
        return 'Deep warm nocturnal obsidian with glowing earthen amber accents';
      case AppThemePreset.templeGold:
        return 'Reverent sanctum brass and temple lamp warm radiance';
      case AppThemePreset.sandalwoodRose:
        return 'Aromatic sandalwood base with rose petal compassion hues';
      case AppThemePreset.forestSage:
        return 'Meditative woodland moss and cedar mist for peaceful contemplation';
      case AppThemePreset.royalAmethyst:
        return 'Majestic twilight purple honoring wisdom and sacred memories';
      case AppThemePreset.amoledOnyx:
        return 'Deep pitch-black zero battery drain with glowing gold rim';
    }
  }
}

/// Chat bubble visual presentation styles.
enum BubbleStyle {
  gentleGlow,
  frostedGlass,
  classicSolid,
  modernCard,
  glassmorphic,
  classicPill,
}

/// Nuanced conversation personas for the remembrance companion.
enum CompanionTone {
  gentleComfort,
  wiseGuiding,
  storytellerNostalgia,
  briefPeaceful,
}

/// Voice waveform visualization styles.
enum WaveformStyle {
  pulsingWaves,
  harmonicBars,
  orbRipple,
}

/// Reactive State Manager for APDM theme, aesthetics, and user options.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppThemePreset _activePreset = AppThemePreset.midnightAmber;
  bool _enableAmbientGlow = true;
  BubbleStyle _bubbleStyle = BubbleStyle.modernCard;
  CompanionTone _companionTone = CompanionTone.gentleComfort;
  String _languageMode = 'auto'; // 'auto', 'tamil', 'tanglish', 'english'
  double _speechPace = 1.0;
  double _speechPitch = 1.0;
  bool _autoPlayAudio = true;
  bool _hapticFeedback = true;
  bool _respectfulHonorifics = true;
  bool _proactiveReminders = true;
  WaveformStyle _waveformStyle = WaveformStyle.pulsingWaves;
  bool _biometricLock = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppThemePreset get activePreset => _activePreset;
  bool get enableAmbientGlow => _enableAmbientGlow;
  bool get ambientGlow => _enableAmbientGlow;
  BubbleStyle get bubbleStyle => _bubbleStyle;
  CompanionTone get companionTone => _companionTone;
  String get languageMode => _languageMode;
  double get speechPace => _speechPace;
  double get speechPitch => _speechPitch;
  bool get autoPlayAudio => _autoPlayAudio;
  bool get autoPlayVoice => _autoPlayAudio;
  bool get hapticFeedback => _hapticFeedback;
  bool get respectfulHonorifics => _respectfulHonorifics;
  bool get respectfulTamilHonorifics => _respectfulHonorifics;
  bool get proactiveReminders => _proactiveReminders;
  WaveformStyle get waveformStyle => _waveformStyle;
  bool get biometricLock => _biometricLock;

  /// Returns the current active ThemePalette based on preset and dark/light mode.
  ThemePalette get currentPalette {
    if (!isDarkMode) {
      return AppColors.lightPalette;
    }
    switch (_activePreset) {
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

  /// Get palette for a specific preset (for swatches)
  ThemePalette getPaletteForPreset(AppThemePreset preset) {
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

  // Setters with notifyListeners
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleAmbientGlow() {
    _enableAmbientGlow = !_enableAmbientGlow;
    notifyListeners();
  }

  void toggleAutoPlayVoice() {
    _autoPlayAudio = !_autoPlayAudio;
    notifyListeners();
  }

  void toggleHonorifics() {
    _respectfulHonorifics = !_respectfulHonorifics;
    notifyListeners();
  }

  void toggleProactiveReminders() {
    _proactiveReminders = !_proactiveReminders;
    notifyListeners();
  }

  void toggleHapticFeedback() {
    _hapticFeedback = !_hapticFeedback;
    notifyListeners();
  }

  void toggleBiometricLock() {
    _biometricLock = !_biometricLock;
    notifyListeners();
  }

  void setActivePreset(AppThemePreset preset) {
    if (_activePreset != preset) {
      _activePreset = preset;
      notifyListeners();
    }
  }

  void setAmbientGlow(bool value) {
    if (_enableAmbientGlow != value) {
      _enableAmbientGlow = value;
      notifyListeners();
    }
  }

  void setBubbleStyle(BubbleStyle style) {
    if (_bubbleStyle != style) {
      _bubbleStyle = style;
      notifyListeners();
    }
  }

  void setCompanionTone(CompanionTone tone) {
    if (_companionTone != tone) {
      _companionTone = tone;
      notifyListeners();
    }
  }

  void setLanguageMode(String mode) {
    if (_languageMode != mode) {
      _languageMode = mode;
      notifyListeners();
    }
  }

  void setSpeechPace(double pace) {
    if (_speechPace != pace) {
      _speechPace = pace;
      notifyListeners();
    }
  }

  void setSpeechPitch(double pitch) {
    if (_speechPitch != pitch) {
      _speechPitch = pitch;
      notifyListeners();
    }
  }

  void setAutoPlayAudio(bool value) {
    if (_autoPlayAudio != value) {
      _autoPlayAudio = value;
      notifyListeners();
    }
  }

  void setHapticFeedback(bool value) {
    if (_hapticFeedback != value) {
      _hapticFeedback = value;
      notifyListeners();
    }
  }

  void setRespectfulHonorifics(bool value) {
    if (_respectfulHonorifics != value) {
      _respectfulHonorifics = value;
      notifyListeners();
    }
  }

  void setProactiveReminders(bool value) {
    if (_proactiveReminders != value) {
      _proactiveReminders = value;
      notifyListeners();
    }
  }

  void setWaveformStyle(WaveformStyle style) {
    if (_waveformStyle != style) {
      _waveformStyle = style;
      notifyListeners();
    }
  }

  void setBiometricLock(bool value) {
    if (_biometricLock != value) {
      _biometricLock = value;
      notifyListeners();
    }
  }
}

