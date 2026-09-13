import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/memory.dart';
import '../voice/voice_conversation_screen.dart';

/// Modal bottom sheet detailing an individual memory with reflection shortcuts.
class MemoryDetailSheet extends StatelessWidget {
  final Memory memory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MemoryDetailSheet({
    super.key,
    required this.memory,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = memory.category.accentColor;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171F2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Category + Actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha(isDark ? 50 : 35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: categoryColor.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(memory.category.icon, size: 16, color: categoryColor),
                        const SizedBox(width: 6),
                        Text(
                          memory.category.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Memory',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    tooltip: 'Delete Memory',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                memory.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              // Date & Emotion badges
              Row(
                children: [
                  if (memory.memoryDate != null) ...[
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('MMMM d, y').format(memory.memoryDate!),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  if (memory.emotionTag != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryWarm.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '❤ ${memory.emotionTag!}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryWarm,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Story Content
              Text(
                memory.content,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.6,
                  color: isDark ? const Color(0xFFE1E7F0) : const Color(0xFF3B3734),
                ),
              ),
              const SizedBox(height: 24),

              // Tags
              if (memory.tags.isNotEmpty) ...[
                const Text(
                  'Associated Themes',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: memory.tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: isDark ? const Color(0xFF1E2638) : const Color(0xFFEDE7DC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Reflect in Voice Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VoiceConversationScreen(initialTopic: memory.title),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic_rounded, size: 20),
                  label: const Text('Reflect on this Memory in Voice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
