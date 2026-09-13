import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../services/service_locator.dart';
import '../../services/stt_service.dart';
import '../../widgets/conversation_tile.dart';
import '../../widgets/voice_orb_visualizer.dart';
import '../history/session_detail_screen.dart';
import '../memory/add_edit_memory_dialog.dart';
import '../voice/voice_conversation_screen.dart';

/// Home Screen - the central calm, voice-first gateway of APDM.
class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onTabSelected;

  const HomeScreen({super.key, required this.onTabSelected});

  void _openVoiceConversation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VoiceConversationScreen(),
      ),
    );
  }

  void _openAddMemory(BuildContext context) async {
    final newMemory = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditMemoryDialog(),
    );

    if (newMemory != null) {
      await ServiceLocator.instance.memoryService.addMemory(newMemory);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cherished memory preserved safely.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ServiceLocator.instance;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primaryDark],
                ),
              ),
              child: const Icon(Icons.graphic_eq_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              AppStrings.appName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => onTabSelected(3), // Navigate to Settings tab
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          services.profileService,
          services.memoryService,
          services.conversationService,
        ]),
        builder: (context, _) {
          final profile = services.profileService.profile;
          final memoriesCount = services.memoryService.memories.length;
          final sessions = services.conversationService.sessions;
          final recentSessions = sessions.take(3).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Memorial Space Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryWarm.withAlpha(isDark ? 50 : 35),
                          border: Border.all(color: AppColors.primaryWarm),
                        ),
                        child: Center(
                          child: Text(
                            profile.avatarInitials,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryWarm,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile.lovedOneName}\'s Space',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${profile.relationship} • ${profile.lifespan}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border_rounded, size: 20),
                        color: AppColors.primaryWarm,
                        onPressed: () => onTabSelected(1), // Memories
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 2. Large Central Voice Interaction Portal
                Center(
                  child: Column(
                    children: [
                      VoiceOrbVisualizer(
                        state: VoiceState.ready,
                        size: 190,
                        onTap: () => _openVoiceConversation(context),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _openVoiceConversation(context),
                        icon: const Icon(Icons.mic_rounded, size: 22),
                        label: const Text(AppStrings.startConversation),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.tapToSpeak,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Quick Stats & Preservation Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.auto_stories_outlined,
                        count: '$memoriesCount',
                        label: AppStrings.memoriesSavedCount,
                        onTap: () => onTabSelected(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.history_rounded,
                        count: '${sessions.length}',
                        label: AppStrings.conversationHoursCount,
                        onTap: () => onTabSelected(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Preserve New Memory Prompt Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E2638), const Color(0xFF171F2C)]
                          : [const Color(0xFFFBF4EA), const Color(0xFFF5ECE0)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primaryWarm.withAlpha(isDark ? 60 : 40),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryWarm.withAlpha(isDark ? 40 : 25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.note_add_outlined,
                          color: AppColors.primaryWarm,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preserve a Memory',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              AppStrings.addMemoryPrompt,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        onPressed: () => _openAddMemory(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 5. Recent Conversations Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.recentConversations,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (recentSessions.isNotEmpty)
                      TextButton(
                        onPressed: () => onTabSelected(2), // History tab
                        child: const Text(AppStrings.viewAllHistory),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (recentSessions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.mic_none_rounded,
                          size: 32,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap the microphone above to start your first remembrance reflection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: recentSessions.map((session) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ConversationTile(
                          session: session,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SessionDetailScreen(session: session),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(isDark ? 35 : 25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
