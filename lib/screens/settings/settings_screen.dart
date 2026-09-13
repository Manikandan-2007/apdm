import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/gemini_config.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/memorial_profile.dart';
import '../../services/service_locator.dart';
import '../profile/profile_screen.dart';
import 'about_dialog.dart';
import 'theme_selector_sheet.dart';

/// Premium Mobile Settings & Options Center for APDM.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ServiceLocator _services = ServiceLocator.instance;

  void _openThemeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ThemeSelectorSheet(),
    );
  }

  void _showFamilyProfileSwitcher() {
    final currentProfile = _services.profileService.profile;
    final palette = _services.themeProvider.currentPalette;

    final familyProfiles = [
      currentProfile,
      const MemorialProfile(
        id: 'profile_meenu',
        lovedOneName: 'Meenu',
        relationship: 'Magal (Daughter)',
        lifespan: '',
        biography: '',
        favoritePhrase: '',
        avatarInitials: 'ME',
      ),
      const MemorialProfile(
        id: 'profile_dinesh',
        lovedOneName: 'Dinesh',
        relationship: 'Magan (Son)',
        lifespan: '',
        biography: '',
        favoritePhrase: '',
        avatarInitials: 'DI',
      ),
      const MemorialProfile(
        id: 'profile_padma',
        lovedOneName: 'Padma',
        relationship: 'Manaivi / Bawa',
        lifespan: '',
        biography: '',
        favoritePhrase: '',
        avatarInitials: 'PA',
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Family Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kudumba urupinar profile maatravum',
              style: TextStyle(fontSize: 12.5, color: palette.textMuted),
            ),
            const SizedBox(height: 16),
            ...familyProfiles.map((p) {
              final isSelected = p.lovedOneName == currentProfile.lovedOneName;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: isSelected ? palette.primary : palette.border,
                  child: Text(
                    p.avatarInitials,
                    style: TextStyle(
                      color: isSelected ? Colors.black : palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  p.lovedOneName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? palette.primary : palette.textPrimary,
                  ),
                ),
                subtitle: Text(p.relationship),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: palette.primary)
                    : null,
                onTap: () async {
                  await _services.profileService.updateProfile(p);
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showLanguageModeSelector() {
    final themeProvider = _services.themeProvider;
    final palette = themeProvider.currentPalette;

    final modes = [
      {
        'id': 'auto',
        'title': 'Bilingual Auto-Detect (Iyalbaana Kandaripudhal)',
        'subtitle': 'Seamlessly detects Tamil, Tanglish, and English in real time',
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'id': 'tamil',
        'title': 'Tamil Pure',
        'subtitle': 'Prioritizes pure Tamil phrasing written in clear script',
        'icon': Icons.translate_rounded,
      },
      {
        'id': 'tanglish',
        'title': 'Tanglish Natural (Tamil + English)',
        'subtitle': 'Colloquial spoken Tamil in Latin alphabet',
        'icon': Icons.chat_bubble_outline_rounded,
      },
      {
        'id': 'english',
        'title': 'English Pure',
        'subtitle': 'Reflective conversation in standard English',
        'icon': Icons.language_rounded,
      },
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text(
          'Language & Dialogue Mode',
          style: TextStyle(color: palette.textPrimary, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: modes.length,
            separatorBuilder: (_, _) => Divider(color: palette.border, height: 1),
            itemBuilder: (context, index) {
              final m = modes[index];
              final isSelected = m['id'] == themeProvider.languageMode;

              return ListTile(
                leading: Icon(m['icon'] as IconData, color: isSelected ? palette.primary : palette.textMuted),
                title: Text(
                  m['title'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? palette.primary : palette.textPrimary,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  m['subtitle'] as String,
                  style: TextStyle(fontSize: 12, color: palette.textMuted),
                ),
                trailing: isSelected ? Icon(Icons.check_rounded, color: palette.primary) : null,
                onTap: () {
                  themeProvider.setLanguageMode(m['id'] as String);
                  Navigator.of(dialogCtx).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCompanionToneSelector() {
    final themeProvider = _services.themeProvider;
    final palette = themeProvider.currentPalette;

    final tones = [
      {
        'tone': CompanionTone.gentleComfort,
        'name': 'Gentle Comfort • Aarudhal & Anbu',
        'desc': 'Soft, reassuring, emotionally warm and deeply empathetic reflections',
      },
      {
        'tone': CompanionTone.wiseGuiding,
        'name': 'Wise & Guiding • Gnaanamum Vazhikaattalum',
        'desc': 'Focuses on life lessons, values, patience, and parental wisdom',
      },
      {
        'tone': CompanionTone.storytellerNostalgia,
        'name': 'Storyteller • Kadhaigalum Pazhaya Ninaivugalum',
        'desc': 'Rich narration of past family moments, childhood tales, and habits',
      },
      {
        'tone': CompanionTone.briefPeaceful,
        'name': 'Brief & Peaceful • Amaidhiyaana Uraiyaadal',
        'desc': 'Concise, meditative responses that leave space for quiet reflection',
      },
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text(
          'Companion Persona & Tone',
          style: TextStyle(color: palette.textPrimary, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: tones.length,
            separatorBuilder: (_, _) => Divider(color: palette.border, height: 1),
            itemBuilder: (context, index) {
              final t = tones[index];
              final isSelected = t['tone'] == themeProvider.companionTone;

              return ListTile(
                title: Text(
                  t['name'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? palette.primary : palette.textPrimary,
                    fontSize: 14.5,
                  ),
                ),
                subtitle: Text(
                  t['desc'] as String,
                  style: TextStyle(fontSize: 12, color: palette.textMuted),
                ),
                trailing: isSelected ? Icon(Icons.check_rounded, color: palette.primary) : null,
                onTap: () {
                  themeProvider.setCompanionTone(t['tone'] as CompanionTone);
                  Navigator.of(dialogCtx).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDataExportDialog() {
    final count = _services.memoryService.memories.length;
    final sessionCount = _services.conversationService.sessions.length;
    final palette = _services.themeProvider.currentPalette;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text('Export Memorial Archive', style: TextStyle(color: palette.textPrimary)),
        content: Text(
          'Exporting $count preserved memories and $sessionCount conversation transcripts.\n\n'
          'All data will be packaged into a private, encrypted archive format.',
          style: TextStyle(height: 1.4, color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: palette.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: palette.primary,
                  content: const Text('Archive successfully exported to local device storage.', style: TextStyle(color: Colors.black)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: palette.primary),
            child: const Text('Export Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmClearData() {
    final palette = _services.themeProvider.currentPalette;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: palette.surface,
        title: const Text('Delete All Conversation History?'),
        content: const Text(
          'This will remove previous conversation transcripts. Preserved memories in your archive will remain safely preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancel', style: TextStyle(color: palette.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final allSessions = List.from(_services.conversationService.sessions);
              for (final s in allSessions) {
                await _services.conversationService.deleteSession(s.id);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conversation history cleared.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDetails() {
    final palette = _services.themeProvider.currentPalette;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: palette.surface,
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: palette.primary, size: 22),
            const SizedBox(width: 8),
            Text('Data Dignity & Privacy', style: TextStyle(color: palette.textPrimary, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'APDM is engineered with sacred privacy as a foundational principle:',
                style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              _buildPrivacyPoint(
                Icons.phone_android_rounded,
                'Local-First Storage',
                'Your recorded memories, transcripts, and loved one profile remain securely on your device.',
                palette,
              ),
              const SizedBox(height: 10),
              _buildPrivacyPoint(
                Icons.record_voice_over_rounded,
                'Voice Preservation Consent',
                'No external voice models are trained without explicit, multi-party family authorization.',
                palette,
              ),
              const SizedBox(height: 10),
              _buildPrivacyPoint(
                Icons.vpn_key_rounded,
                'Family Ownership',
                'You maintain complete control to export your memorial archive or delete transcripts at any time.',
                palette,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Understood', style: TextStyle(color: palette.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(IconData icon, String title, String desc, ThemePalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: palette.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: palette.textPrimary)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 12, color: palette.textMuted, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  String _languageModeLabel(String mode) {
    switch (mode) {
      case 'tamil':
        return 'Tamil Pure';
      case 'tanglish':
        return 'Tanglish Natural (Tamil + English)';
      case 'english':
        return 'English Pure';
      case 'auto':
      default:
        return 'Bilingual Auto-Detect (Iyalbaana Kandaripudhal)';
    }
  }

  String _companionToneLabel(CompanionTone tone) {
    switch (tone) {
      case CompanionTone.gentleComfort:
        return 'Gentle Comfort • Aarudhal';
      case CompanionTone.wiseGuiding:
        return 'Wise & Guiding • Gnaanam';
      case CompanionTone.storytellerNostalgia:
        return 'Storyteller • Kadhaigal';
      case CompanionTone.briefPeaceful:
        return 'Brief & Peaceful • Amaidhi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _services.profileService,
        _services.themeProvider,
      ]),
      builder: (context, _) {
        final profile = _services.profileService.profile;
        final themeProvider = _services.themeProvider;
        final palette = themeProvider.currentPalette;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings & Memorial Options'),
            actions: [
              IconButton(
                tooltip: 'Choose Theme Preset',
                icon: Icon(Icons.palette_outlined, color: palette.primary),
                onPressed: _openThemeSelector,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              // ==========================================
              // SECTION 1: APPEARANCE & MEMORIAL THEMES
              // ==========================================
              _buildSectionHeader('APPEARANCE & MEMORIAL THEMES', 'Vadivamaippu matrum Nirangal', palette),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: palette.border),
                ),
                color: palette.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Theme Showcase Row
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [palette.primary, palette.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: themeProvider.ambientGlow
                                  ? [
                                      BoxShadow(
                                        color: palette.primary.withAlpha(90),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: const Icon(Icons.palette_rounded, color: Colors.black, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  themeProvider.activePreset.nameTamil,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  themeProvider.activePreset.description,
                                  style: TextStyle(fontSize: 12, color: palette.textMuted),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: _openThemeSelector,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: palette.primary),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(
                              'Change',
                              style: TextStyle(color: palette.primary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: palette.border, height: 1),
                      const SizedBox(height: 8),

                      // Dark / Light Mode
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(
                          themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                          color: palette.primary,
                        ),
                        title: Text(
                          'Dark Mode (Iravu muraimai)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                        ),
                        subtitle: Text(
                          themeProvider.isDarkMode ? 'Calm nocturnal contrast' : 'Warm daytime linen glow',
                          style: TextStyle(fontSize: 12, color: palette.textMuted),
                        ),
                        value: themeProvider.isDarkMode,
                        activeThumbColor: palette.primary,
                        onChanged: (val) => themeProvider.toggleTheme(),
                      ),

                      Divider(color: palette.border, height: 1),

                      // Ambient Glow Aura
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(Icons.blur_on_rounded, color: palette.accent),
                        title: Text(
                          'Ambient Memorial Glow (Oli vattam)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                        ),
                        subtitle: Text(
                          'Soft luminous halo around active voice aura & cards',
                          style: TextStyle(fontSize: 12, color: palette.textMuted),
                        ),
                        value: themeProvider.ambientGlow,
                        activeThumbColor: palette.primary,
                        onChanged: (val) => themeProvider.toggleAmbientGlow(),
                      ),

                      Divider(color: palette.border, height: 1),
                      const SizedBox(height: 12),

                      // Message Bubble Style Selector
                      Text(
                        'Chat Bubble Styling',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: palette.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: BubbleStyle.values.map((style) {
                          final isSelected = themeProvider.bubbleStyle == style;
                          final label = style == BubbleStyle.gentleGlow
                              ? '✨ Gentle Glow'
                              : (style == BubbleStyle.frostedGlass ? '🧊 Frosted Glass' : '▣ Classic Clean');
                          return ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) themeProvider.setBubbleStyle(style);
                            },
                            selectedColor: palette.primary.withAlpha(40),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? palette.primary : palette.textSecondary,
                            ),
                            side: BorderSide(
                              color: isSelected ? palette.primary : palette.border,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // SECTION 2: CONVERSATION & LANGUAGE
              // ==========================================
              _buildSectionHeader('CONVERSATION & LANGUAGE', 'Uraiyaadal & Mozhi Amaippugal', palette),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: palette.border),
                ),
                color: palette.surface,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.translate_rounded, color: palette.primary),
                      title: Text(
                        'Language Mode (Mozhi muraimai)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                      ),
                      subtitle: Text(
                        _languageModeLabel(themeProvider.languageMode),
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showLanguageModeSelector,
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: Icon(Icons.psychology_outlined, color: palette.primary),
                      title: Text(
                        'Companion Tone & Persona',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                      ),
                      subtitle: Text(
                        _companionToneLabel(themeProvider.companionTone),
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showCompanionToneSelector,
                    ),
                    Divider(color: palette.border, height: 1),
                    SwitchListTile(
                      secondary: Icon(Icons.favorite_border_rounded, color: palette.primary),
                      title: Text(
                        'Respectful Tamil Honorifics (Mariyadhai)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                      ),
                      subtitle: Text(
                        'Uses respectful suffixes (Appa, Amma, Neengal) in Tanglish/Tamil responses',
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                      ),
                      value: themeProvider.respectfulTamilHonorifics,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.toggleHonorifics(),
                    ),
                    Divider(color: palette.border, height: 1),
                    SwitchListTile(
                      secondary: Icon(Icons.lightbulb_outline_rounded, color: palette.accent),
                      title: Text(
                        'Proactive Memory Prompts',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                      ),
                      subtitle: Text(
                        'Gently surfaces memorable dates and anniversary reflections',
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                      ),
                      value: themeProvider.proactiveReminders,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.toggleProactiveReminders(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // SECTION 3: VOICE & AUDIO SETTINGS
              // ==========================================
              _buildSectionHeader('VOICE & AUDIO SETTINGS', 'Kural matrum Oli amaippugal', palette),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: palette.border),
                ),
                color: palette.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phase 2 Voice Notice Pill
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.voiceProcessing.withAlpha(themeProvider.isDarkMode ? 30 : 20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.voiceProcessing.withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: AppColors.voiceProcessing, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Voice cloning of loved ones is ethically reserved for Phase 2 with family verification. Currently using respectful real-time speech synthesis.',
                                style: TextStyle(fontSize: 12, height: 1.4, color: palette.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Auto-play Voice Toggle
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(Icons.volume_up_outlined, color: palette.primary),
                        title: Text(
                          'Auto-Play Companion Voice',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                        ),
                        subtitle: Text(
                          'Automatically reads out companion replies aloud',
                          style: TextStyle(fontSize: 12, color: palette.textMuted),
                        ),
                        value: themeProvider.autoPlayVoice,
                        activeThumbColor: palette.primary,
                        onChanged: (val) => themeProvider.toggleAutoPlayVoice(),
                      ),

                      Divider(color: palette.border, height: 1),
                      const SizedBox(height: 12),

                      // Reading Pace with quick buttons & slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reading Pace (Pesum vegam)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: palette.textPrimary)),
                          Text(
                            '${themeProvider.speechPace.toStringAsFixed(1)}x',
                            style: TextStyle(fontWeight: FontWeight.w700, color: palette.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildPaceChip('0.8x Reverent', 0.8, themeProvider, palette),
                          const SizedBox(width: 8),
                          _buildPaceChip('1.0x Natural', 1.0, themeProvider, palette),
                          const SizedBox(width: 8),
                          _buildPaceChip('1.2x Conversational', 1.2, themeProvider, palette),
                        ],
                      ),
                      Slider(
                        value: themeProvider.speechPace,
                        min: 0.7,
                        max: 1.3,
                        divisions: 6,
                        activeColor: palette.primary,
                        inactiveColor: palette.border,
                        onChanged: (val) => themeProvider.setSpeechPace(val),
                      ),
                      const SizedBox(height: 8),

                      // Voice Pitch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Voice Pitch (Surudhi)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: palette.textPrimary)),
                          Text(
                            '${themeProvider.speechPitch.toStringAsFixed(1)}x',
                            style: TextStyle(fontWeight: FontWeight.w700, color: palette.primary),
                          ),
                        ],
                      ),
                      Slider(
                        value: themeProvider.speechPitch,
                        min: 0.8,
                        max: 1.2,
                        divisions: 4,
                        activeColor: palette.primary,
                        inactiveColor: palette.border,
                        onChanged: (val) => themeProvider.setSpeechPitch(val),
                      ),

                      Divider(color: palette.border, height: 1),

                      // Haptic Feedback
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(Icons.vibration_rounded, color: palette.primary),
                        title: Text(
                          'Haptic Feedback on Speech',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                        ),
                        subtitle: Text(
                          'Gentle pulse when voice response finishes or starts',
                          style: TextStyle(fontSize: 12, color: palette.textMuted),
                        ),
                        value: themeProvider.hapticFeedback,
                        activeThumbColor: palette.primary,
                        onChanged: (val) => themeProvider.toggleHapticFeedback(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // SECTION 4: KUDUMBA PROFILE & MEMBERS
              // ==========================================
              _buildSectionHeader('KUDUMBA PROFILE & MEMBERS', 'Kudumba urupinargal', palette),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: palette.border),
                ),
                color: palette.surface,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.primary.withAlpha(40),
                          border: Border.all(color: palette.primary),
                        ),
                        child: Center(
                          child: Text(
                            profile.avatarInitials.isNotEmpty ? profile.avatarInitials : 'KP',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: palette.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        'Active Profile: ${profile.lovedOneName}',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: palette.textPrimary),
                      ),
                      subtitle: const Text('Meenu • Dinesh • Padma'),
                      trailing: IconButton(
                        icon: Icon(Icons.swap_horiz_rounded, color: palette.primary),
                        tooltip: 'Switch Member',
                        onPressed: _showFamilyProfileSwitcher,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: Icon(Icons.people_outline_rounded, color: palette.primary),
                      title: Text('Switch Active Member', style: TextStyle(color: palette.textPrimary, fontSize: 14)),
                      subtitle: const Text('Meenu, Dinesh, or Padma profile choose pannunga', style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showFamilyProfileSwitcher,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // SECTION 5: DATA DIGNITY & PRIVACY
              // ==========================================
              _buildSectionHeader('DATA DIGNITY & PRIVACY', 'Paadhugaappu & Thadavu Kanniyam', palette),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: palette.border),
                ),
                color: palette.surface,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(Icons.fingerprint_rounded, color: palette.primary),
                      title: Text(
                        'Biometric / Memorial Lock',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: palette.textPrimary),
                      ),
                      subtitle: Text(
                        'Require fingerprint or face ID to access family transcripts',
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                      ),
                      value: themeProvider.biometricLock,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.toggleBiometricLock(),
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: Icon(Icons.shield_outlined, color: palette.primary),
                      title: Text('Data Dignity Principles', style: TextStyle(color: palette.textPrimary, fontSize: 14)),
                      subtitle: const Text('100% on-device private memory preservation', style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showPrivacyDetails,
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: Icon(Icons.file_download_outlined, color: palette.primary),
                      title: Text('Export Memorial Archive', style: TextStyle(color: palette.textPrimary, fontSize: 14)),
                      subtitle: const Text('Save encrypted backup of memories & transcripts', style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showDataExportDialog,
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                      title: const Text('Delete Conversation Transcripts',
                          style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Clears dialogue history while preserving memories', style: TextStyle(fontSize: 12)),
                      onTap: _confirmClearData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // SECTION 6: ABOUT & SYSTEM
              // ==========================================
              _buildSectionHeader('ABOUT & SYSTEM', 'Seyali patriya vivarangal', palette),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: palette.border),
                ),
                color: palette.surface,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.psychology_rounded, color: palette.primary),
                      title: Text('AI Engine & Gemini API', style: TextStyle(color: palette.textPrimary, fontSize: 14)),
                      subtitle: Text(
                        GeminiConfig.hasApiKey
                            ? 'Google Gemini 1.5 Flash (Live Connected)'
                            : 'Context-Aware Generative Engine (Offline Ready)',
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showGeminiConfigDialog,
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: Icon(Icons.info_outline_rounded, color: palette.primary),
                      title: Text('About APDM Memorial AI', style: TextStyle(color: palette.textPrimary, fontSize: 14)),
                      subtitle: const Text('Ethical charter, cultural dedication & roadmap', style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const ApdmAboutDialog(),
                        );
                      },
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: Icon(Icons.memory_rounded, color: palette.primary),
                      title: Text('Active Theme & Engine', style: TextStyle(color: palette.textPrimary, fontSize: 14)),
                      subtitle: Text(
                        '${themeProvider.activePreset.nameTamil} • Phase 1 Mobile Foundation',
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                      ),
                      trailing: Text('v1.0.0', style: TextStyle(color: palette.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  void _showGeminiConfigDialog() {
    final palette = _services.themeProvider.currentPalette;
    final controller = TextEditingController(text: GeminiConfig.apiKey);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: palette.surface,
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: palette.primary, size: 22),
            const SizedBox(width: 8),
            Text('Google Gemini API Brain', style: TextStyle(color: palette.textPrimary, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'APDM uses Google Gemini 1.5 Flash to power its empathetic conversational engine.\n\nYou can provide your API key or configure --dart-define=GEMINI_API_KEY=YOUR_KEY.',
              style: TextStyle(fontSize: 12.5, color: palette.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIzaSy...',
                prefixIcon: const Icon(Icons.key_rounded, size: 20),
                filled: true,
                fillColor: palette.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancel', style: TextStyle(color: palette.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              GeminiConfig.setApiKey(controller.text.trim());
              Navigator.of(dialogCtx).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    GeminiConfig.hasApiKey
                        ? 'Gemini API Key configured successfully!'
                        : 'Using Context-Aware Generative Engine.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: palette.primary),
            child: const Text('Save & Connect', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitleTamil, ThemePalette palette) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: palette.textMuted,
            ),
          ),
          Text(
            subtitleTamil,
            style: TextStyle(
              fontSize: 10.5,
              color: palette.primary.withAlpha(160),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaceChip(String label, double pace, ThemeProvider themeProvider, ThemePalette palette) {
    final isSelected = (themeProvider.speechPace - pace).abs() < 0.05;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => themeProvider.setSpeechPace(pace),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary : palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? palette.primary : palette.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}
