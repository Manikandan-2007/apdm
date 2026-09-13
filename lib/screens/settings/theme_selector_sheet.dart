import 'package:flutter/material.dart';
import '../../core/theme/theme_provider.dart';
import '../../services/service_locator.dart';

/// Modal bottom sheet for selecting memorial theme presets and aesthetic options.
class ThemeSelectorSheet extends StatelessWidget {
  const ThemeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ServiceLocator.instance.themeProvider;
    final palette = themeProvider.currentPalette;
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: palette.border, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title and Subtitle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memorial Atmosphere',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vadivamaippu & Vanna Themegal',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: palette.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. Dark / Light / System Segmented Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? palette.background : const Color(0xFFF0EAE1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    _buildModeButton(
                      context: context,
                      title: 'Dark',
                      icon: Icons.dark_mode_rounded,
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                    _buildModeButton(
                      context: context,
                      title: 'Light',
                      icon: Icons.light_mode_rounded,
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    _buildModeButton(
                      context: context,
                      title: 'System',
                      icon: Icons.settings_brightness_rounded,
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'CURATED COLOR PALETTES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // 2. Preset Cards
              ...AppThemePreset.values.map((preset) {
                final itemPalette = themeProvider.getPaletteForPreset(preset);
                final isSelected = themeProvider.activePreset == preset;

                return GestureDetector(
                  onTap: () => themeProvider.setActivePreset(preset),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? itemPalette.primary.withAlpha(isDark ? 30 : 20)
                          : (isDark ? itemPalette.card : Colors.white),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? itemPalette.primary : palette.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected && themeProvider.enableAmbientGlow
                          ? [
                              BoxShadow(
                                color: itemPalette.accentGlow,
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Swatch circle preview
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: itemPalette.background,
                            border: Border.all(color: itemPalette.primary, width: 2),
                          ),
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: itemPalette.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & descriptions
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    itemPalette.englishName,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? itemPalette.primary : palette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    itemPalette.tamilName,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: palette.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                itemPalette.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: palette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Radio checkmark indicator
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? itemPalette.primary : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? itemPalette.primary : palette.border,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.black)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // 3. Additional Aesthetic Options
              Text(
                'VISUAL ACCENTS & BUBBLES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Ambient Accent Glow Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? palette.card : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: palette.primary, size: 22),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ambient Glow Aura',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: palette.textPrimary,
                              ),
                            ),
                            Text(
                              'Olirum menmaiyaana aura',
                              style: TextStyle(fontSize: 11.5, color: palette.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: themeProvider.enableAmbientGlow,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.setAmbientGlow(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Chat Bubble Presentation Selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? palette.card : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message Bubble Style',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildBubbleChip(
                          context: context,
                          label: 'Modern Card',
                          style: BubbleStyle.modernCard,
                          isSelected: themeProvider.bubbleStyle == BubbleStyle.modernCard,
                          onTap: () => themeProvider.setBubbleStyle(BubbleStyle.modernCard),
                        ),
                        const SizedBox(width: 8),
                        _buildBubbleChip(
                          context: context,
                          label: 'Glassmorphic',
                          style: BubbleStyle.glassmorphic,
                          isSelected: themeProvider.bubbleStyle == BubbleStyle.glassmorphic,
                          onTap: () => themeProvider.setBubbleStyle(BubbleStyle.glassmorphic),
                        ),
                        const SizedBox(width: 8),
                        _buildBubbleChip(
                          context: context,
                          label: 'Classic Pill',
                          style: BubbleStyle.classicPill,
                          isSelected: themeProvider.bubbleStyle == BubbleStyle.classicPill,
                          onTap: () => themeProvider.setBubbleStyle(BubbleStyle.classicPill),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save & Apply • Mudindhadhu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeProvider = ServiceLocator.instance.themeProvider;
    final palette = themeProvider.currentPalette;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? palette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.black : palette.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.black : palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleChip({
    required BuildContext context,
    required String label,
    required BubbleStyle style,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeProvider = ServiceLocator.instance.themeProvider;
    final palette = themeProvider.currentPalette;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? palette.primary.withAlpha(40)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? palette.primary : palette.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? palette.primary : palette.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
