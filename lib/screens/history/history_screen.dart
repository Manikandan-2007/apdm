import 'package:flutter/material.dart';
import '../../models/conversation_session.dart';
import '../../services/service_locator.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/history_item_tile.dart';
import 'rename_session_dialog.dart';
import 'session_detail_screen.dart';

/// Conversation History Screen: Browse, search, rename, and resume previous reflections.
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onSwitchToChat;

  const HistoryScreen({super.key, this.onSwitchToChat});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ServiceLocator _services = ServiceLocator.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSession(ConversationSession session) async {
    await _services.conversationService.loadSession(session.id);
    if (!mounted) return;
    if (widget.onSwitchToChat != null) {
      widget.onSwitchToChat!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionDetailScreen(session: session),
        ),
      );
    }
  }

  void _renameSession(ConversationSession session) async {
    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => RenameSessionDialog(currentTitle: session.title),
    );

    if (newTitle != null && newTitle.trim().isNotEmpty) {
      await _services.conversationService.renameSession(session.id, newTitle.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversation renamed.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _confirmDelete(ConversationSession session) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Conversation?'),
        content: Text('Are you sure you want to delete "${session.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await _services.conversationService.deleteSession(session.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conversation deleted.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _startNewConversation() async {
    await _services.conversationService.startNewSession();
    widget.onSwitchToChat?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 26),
            tooltip: 'New Conversation',
            onPressed: _startNewConversation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _services.conversationService,
        builder: (context, _) {
          final sessions = _searchQuery.isEmpty
              ? _services.conversationService.sessions
              : _services.conversationService.searchSessions(_searchQuery);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search conversations or messages...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Conversation List
              Expanded(
                child: sessions.isEmpty
                    ? EmptyStateView(
                        icon: Icons.history_rounded,
                        title: _searchQuery.isNotEmpty
                            ? 'No conversations found'
                            : 'No conversations yet',
                        message: _searchQuery.isNotEmpty
                            ? 'Try searching with different keywords.'
                            : 'Start a voice or text reflection with APDM.',
                        actionLabel: 'Start Conversation',
                        onAction: _startNewConversation,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return HistoryItemTile(
                            session: session,
                            onTap: () => _openSession(session),
                            onRename: () => _renameSession(session),
                            onDelete: () => _confirmDelete(session),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
