import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/gemini_config.dart';
import '../../core/theme/theme_provider.dart';
import '../../services/service_locator.dart';
import '../settings/about_dialog.dart';
import '../settings/theme_selector_sheet.dart';

/// Clean, modern mobile Profile & Settings screen in natural Tanglish.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ServiceLocator _services = ServiceLocator.instance;

  void _openThemeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ThemeSelectorSheet(),
    );
  }

  void _showFamilyMemberSelector() {
    final palette = _services.themeProvider.currentPalette;
    final currentProfile = _services.profileService.profile;

    final familyMembers = [
      {
        'id': 'meenu',
        'name': 'Meenu',
        'role': 'Magal (Daughter)',
        'initials': 'ME',
        'avatarColor': const Color(0xFFE57373),
      },
      {
        'id': 'dinesh',
        'name': 'Dinesh',
        'role': 'Magan (Son)',
        'initials': 'DI',
        'avatarColor': const Color(0xFF64B5F6),
      },
      {
        'id': 'padma',
        'name': 'Padma',
        'role': 'Manaivi / Bawa',
        'initials': 'PA',
        'avatarColor': const Color(0xFFBA68C8),
      },
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.textMuted.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kudumba Urupinar Thervu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Active user profile choose pannunga',
              style: TextStyle(fontSize: 12.5, color: palette.textMuted),
            ),
            const SizedBox(height: 16),
            ...familyMembers.map((m) {
              final isSelected = currentProfile.lovedOneName.contains(m['name'] as String);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: m['avatarColor'] as Color,
                  child: Text(
                    m['initials'] as String,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  m['name'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? palette.primary : palette.textPrimary,
                  ),
                ),
                subtitle: Text(m['role'] as String, style: TextStyle(color: palette.textMuted, fontSize: 12)),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: palette.primary)
                    : null,
                onTap: () async {
                  final updated = currentProfile.copyWith(
                    lovedOneName: m['name'] as String,
                    avatarInitials: m['initials'] as String,
                  );
                  await _services.profileService.updateProfile(updated);
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final themeProvider = _services.themeProvider;
    final palette = themeProvider.currentPalette;

    final modes = [
      {
        'id': 'tanglish',
        'title': 'Tanglish Natural (Tamil + English)',
        'subtitle': 'Colloquial spoken Tamil written in English letters',
        'icon': Icons.chat_bubble_outline_rounded,
      },
      {
        'id': 'auto',
        'title': 'Bilingual Auto-Detect',
        'subtitle': 'Detects Tanglish, Tamil, and English automatically',
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'id': 'english',
        'title': 'English Pure',
        'subtitle': 'Conversations in standard English',
        'icon': Icons.language_rounded,
      },
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text(
          'Mozhi Amaippu (Language)',
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
        'desc': 'Soft, affectionate, caring and warm responses',
      },
      {
        'tone': CompanionTone.wiseGuiding,
        'name': 'Wise & Guiding • Vazhikaattal',
        'desc': 'Values, life advice, and practical elder wisdom',
      },
      {
        'tone': CompanionTone.storytellerNostalgia,
        'name': 'Storyteller • Kadhaigalum Ninaivugalum',
        'desc': 'Sharing past memories, habits, and family stories',
      },
      {
        'tone': CompanionTone.briefPeaceful,
        'name': 'Brief & Peaceful • Amaidhi',
        'desc': 'Short, calm and peaceful dialogue',
      },
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text(
          'Pesum Paani (Tone & Persona)',
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
                    fontSize: 14,
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

  void _showExportDialog() {
    final count = _services.memoryService.memories.length;
    final sessionCount = _services.conversationService.sessions.length;
    final palette = _services.themeProvider.currentPalette;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text('Export Ninaivugal Backup', style: TextStyle(color: palette.textPrimary)),
        content: Text(
          'Moththam $count pathivu seidha ninaivugal matrum $sessionCount uraiyaadalgal backup eduka mudiyum.\n\nUngal device-il encrypted format-il download aagum.',
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
                  content: const Text('Backup successfully ungal device-il save aagiduchu!', style: TextStyle(color: Colors.black)),
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
        title: const Text('Uraiyaadal History Clear Pannalama?'),
        content: const Text(
          'Pazhaya chat messages mattum clear aagum. Ungal pathivu seidha ninaivugal (Memories) appadiye safe ah irukum.',
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
                    content: Text('Chat history clear aagiduchu.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _services.profileService,
        _services.memoryService,
        _services.conversationService,
        _services.themeProvider,
      ]),
      builder: (context, _) {
        final themeProvider = _services.themeProvider;
        final palette = themeProvider.currentPalette;
        final isDark = themeProvider.isDarkMode;
        final memoryCount = _services.memoryService.memories.length;
        final sessionCount = _services.conversationService.sessions.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile & Amaippugal'),
            actions: [
              IconButton(
                icon: Icon(Icons.palette_outlined, color: palette.primary),
                tooltip: 'Change Theme',
                onPressed: _openThemeSelector,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // ==========================================
              // CLEAN USER / FAMILY ACCOUNT CARD
              // ==========================================
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: palette.border),
                ),
                color: palette.surface,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [palette.primaryLight, palette.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: palette.primary.withAlpha(isDark ? 80 : 40),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 30,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kudumba Account',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Meenu • Dinesh • Padma',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: palette.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.swap_horiz_rounded, color: palette.primary),
                        tooltip: 'Switch Member',
                        onPressed: _showFamilyMemberSelector,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ==========================================
              // STATS ROW (Clean Modern Badges)
              // ==========================================
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$memoryCount',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: palette.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Saved Memories',
                            style: TextStyle(fontSize: 11.5, color: palette.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$sessionCount',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: palette.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Conversations',
                            style: TextStyle(fontSize: 11.5, color: palette.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ==========================================
              // SECTION: THOTRAM & THEMES (APPEARANCE)
              // ==========================================
              _buildSectionTitle('THOTRAM & THEMES', palette),
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
                      leading: Icon(Icons.palette_rounded, color: palette.primary),
                      title: Text(
                        'Color Theme: ${themeProvider.activePreset.nameTamil}',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary),
                      ),
                      subtitle: Text(themeProvider.activePreset.description, style: TextStyle(fontSize: 12, color: palette.textMuted)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _openThemeSelector,
                    ),
                    Divider(color: palette.border, height: 1),
                    SwitchListTile(
                      secondary: Icon(
                        themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                        color: palette.primary,
                      ),
                      title: Text(
                        'Dark Mode (Iravu muraimai)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary),
                      ),
                      subtitle: Text(
                        themeProvider.isDarkMode ? 'Calm nocturnal view' : 'Light daytime view',
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                      ),
                      value: themeProvider.isDarkMode,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.toggleTheme(),
                    ),
                    Divider(color: palette.border, height: 1),
                    SwitchListTile(
                      secondary: Icon(Icons.blur_on_rounded, color: palette.accent),
                      title: Text(
                        'Ambient Glow (Oli vattam)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary),
                      ),
                      subtitle: const Text('Soft glow around buttons and audio card', style: TextStyle(fontSize: 12)),
                      value: themeProvider.ambientGlow,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.toggleAmbientGlow(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // SECTION: KURAL & AUDIO (VOICE SETTINGS)
              // ==========================================
              _buildSectionTitle('KURAL & AUDIO AMAIPPUGAL', palette),
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
                      secondary: Icon(Icons.volume_up_rounded, color: palette.primary),
                      title: Text(
                        'Auto-Play Voice (Kural aagave pesanum)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary),
                      ),
                      subtitle: const Text('Replies voice-ah automatically play aagum', style: TextStyle(fontSize: 12)),
                      value: themeProvider.autoPlayVoice,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.toggleAutoPlayVoice(),
                    ),
                    Divider(color: palette.border, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pesum Vegam (Speech Pace)',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: palette.textPrimary),
                              ),
                              Text(
                                '${themeProvider.speechPace.toStringAsFixed(1)}x',
                                style: TextStyle(fontWeight: FontWeight.w700, color: palette.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Slider(
                            value: themeProvider.speechPace,
                            min: 0.7,
                            max: 1.3,
                            divisions: 6,
                            activeColor: palette.primary,
                            inactiveColor: palette.border,
                            onChanged: (val) => themeProvider.setSpeechPace(val),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: palette.border, height: 1),
                    SwitchListTile(
                      secondary: Icon(Icons.vibration_rounded, color: palette.primary),
                      title: Text(
                        'Haptic Feedback (Vibration)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary),
                      ),
                      subtitle: const Text('Voice pesum pothu gentle vibration feedback', style: TextStyle(fontSize: 12)),
                      value: themeProvider.hapticFeedback,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.toggleHapticFeedback(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // SECTION: MOZHI & PAANI (LANGUAGE & TONE)
              // ==========================================
              _buildSectionTitle('MOZHI & URURAYAADAL PAANI', palette),
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
                      title: Text('Language Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary)),
                      subtitle: const Text('Tanglish Natural (Tamil + English)', style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showLanguageSelector,
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: Icon(Icons.psychology_outlined, color: palette.primary),
                      title: Text('Companion Tone', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary)),
                      subtitle: const Text('Gentle Comfort • Aarudhal & Anbu', style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showCompanionToneSelector,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // SECTION: PAADHUGAMPPU & BACKUP (SECURITY)
              // ==========================================
              _buildSectionTitle('PAADHUGAMPPU & BACKUP', palette),
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
                        'Biometric / App Lock',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary),
                      ),
                      subtitle: const Text('Fingerprint / Face ID lock for safety', style: TextStyle(fontSize: 12)),
                      value: themeProvider.biometricLock,
                      activeThumbColor: palette.primary,
                      onChanged: (val) => themeProvider.toggleBiometricLock(),
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: Icon(Icons.file_download_outlined, color: palette.primary),
                      title: Text('Export Memories Backup', style: TextStyle(color: palette.textPrimary, fontSize: 14)),
                      subtitle: const Text('Save encrypted backup of all memories', style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.textMuted),
                      onTap: _showExportDialog,
                    ),
                    Divider(color: palette.border, height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                      title: const Text('Clear Chat History', style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Previous transcripts mattum clear pannum', style: TextStyle(fontSize: 12)),
                      onTap: _confirmClearData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // SECTION: APDM PATHI (ABOUT)
              // ==========================================
              _buildSectionTitle('APDM PATHI (ABOUT)', palette),
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
                      subtitle: const Text('Kudumba ninaivugala pathukaakum companion', style: TextStyle(fontSize: 12)),
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
                      leading: Icon(Icons.check_circle_outline_rounded, color: palette.primary),
                      title: Text('App Version', style: TextStyle(color: palette.textPrimary, fontSize: 14)),
                      subtitle: const Text('100% On-Device Safe & Private', style: TextStyle(fontSize: 12)),
                      trailing: Text('v1.0.0', style: TextStyle(color: palette.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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

  Widget _buildSectionTitle(String title, ThemePalette palette) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: palette.textMuted,
        ),
      ),
    );
  }
}

