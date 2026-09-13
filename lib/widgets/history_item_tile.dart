import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/conversation_session.dart';

/// Presentation card for a conversation in the History list.
class HistoryItemTile extends StatelessWidget {
  final ConversationSession session;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const HistoryItemTile({
    super.key,
    required this.session,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(dt)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dt)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: isDark ? const Color(0xFF171F2C) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF243042) : const Color(0xFFE8DFD3),
          ),
        ),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryWarm.withAlpha(isDark ? 35 : 20),
          ),
          child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryWarm, size: 20),
        ),
        title: Text(
          session.title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              session.summaryPreview,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  _formatDateTime(session.startedAt),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  ${session.messages.length} messages',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (val) {
            if (val == 'open') onTap();
            if (val == 'rename') onRename();
            if (val == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.chat_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Open Chat'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Rename'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text('Delete', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
