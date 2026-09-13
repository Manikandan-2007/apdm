import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/service_locator.dart';
import '../screens/chat/main_chat_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/memory/memory_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/voice/voice_conversation_screen.dart';

/// Modern mobile navigation scaffold organizing APDM into:
/// Chat (Default/Home), Memories, Voice (Immersive Mode), History, and Settings.
class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _openImmersiveVoiceScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VoiceConversationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ServiceLocator.instance.themeProvider;
    final palette = themeProvider.currentPalette;
    final isDark = themeProvider.isDarkMode;

    final screens = [
      MainChatScreen(
        onNavigateToMemories: () => _onTabSelected(1),
        onNavigateToHistory: () => _onTabSelected(3),
      ),
      const MemoryScreen(),
      const SizedBox.shrink(),
      HistoryScreen(
        onSwitchToChat: () => _onTabSelected(0),
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(
            top: BorderSide(
              color: palette.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  palette: palette,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  label: 'Memories',
                  palette: palette,
                ),
                // Center Voice Action
                GestureDetector(
                  onTap: _openImmersiveVoiceScreen,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [palette.primaryLight, palette.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: palette.accentGlow.withAlpha(isDark ? 90 : 60),
                          blurRadius: themeProvider.ambientGlow ? 14 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.mic_rounded, color: Colors.black, size: 24),
                    ),
                  ),
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.history_rounded,
                  activeIcon: Icons.history_rounded,
                  label: 'History',
                  palette: palette,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  palette: palette,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required ThemePalette palette,
  }) {
    final isSelected = _currentIndex == index;

    final color = isSelected ? palette.primary : palette.textMuted;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
