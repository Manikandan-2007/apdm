import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_message.dart';
import '../../services/service_locator.dart';
import '../../services/stt_service.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/suggested_conversations_bar.dart';
import '../../widgets/voice_input_bar.dart';
import '../../widgets/voice_state_overlay.dart';
import '../memory/add_edit_memory_dialog.dart';
import '../profile/profile_screen.dart';

/// The PRIMARY screen of APDM: A mobile-first, voice-first conversational AI companion.
class MainChatScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMemories;
  final VoidCallback? onNavigateToHistory;

  const MainChatScreen({
    super.key,
    this.onNavigateToMemories,
    this.onNavigateToHistory,
  });

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  final ServiceLocator _services = ServiceLocator.instance;
  final ScrollController _scrollController = ScrollController();

  VoiceState _voiceState = VoiceState.ready;
  String _liveTranscript = '';
  double _soundLevel = 0.3;
  String? _currentlyPlayingAudioMessageId;
  bool _isAiThinking = false;

  StreamSubscription<VoiceState>? _stateSub;
  StreamSubscription<String>? _transcriptSub;
  StreamSubscription<double>? _soundSub;
  StreamSubscription<bool>? _ttsSub;

  @override
  void initState() {
    super.initState();
    _initVoiceSubscriptions();
  }

  void _initVoiceSubscriptions() {
    _stateSub = _services.sttService.stateStream.listen((state) {
      if (mounted) setState(() => _voiceState = state);
    });

    _transcriptSub = _services.sttService.transcriptStream.listen((text) {
      if (mounted) setState(() => _liveTranscript = text);
    });

    _soundSub = _services.sttService.soundLevelStream.listen((lvl) {
      if (mounted) setState(() => _soundLevel = lvl);
    });

    _ttsSub = _services.ttsService.isSpeakingStream.listen((isSpeaking) {
      if (mounted) {
        if (!isSpeaking) {
          setState(() {
            _currentlyPlayingAudioMessageId = null;
            _voiceState = VoiceState.ready;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _transcriptSub?.cancel();
    _soundSub?.cancel();
    _ttsSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String text) async {
    final language = _services.languageService.detectLanguage(text);

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _services.conversationService.activeSession?.id,
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      detectedLanguage: language,
    );

    await _services.conversationService.addMessageToActiveSession(userMsg);
    setState(() => _isAiThinking = true);
    _scrollToBottom();

    // AI thinking & response generation with complete multi-turn conversation history
    final profile = _services.profileService.profile;
    final memories = _services.memoryService.memories;
    final history = _services.conversationService.activeSession?.messages ?? [];

    final response = await _services.aiService.generateMultilingualResponse(
      userUtterance: text,
      memories: memories,
      profile: profile,
      conversationHistory: history,
    );

    if (mounted) {
      setState(() => _isAiThinking = false);
    }

    final aiMsg = ChatMessage(
      id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _services.conversationService.activeSession?.id,
      text: response.text,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      detectedLanguage: response.language,
      audioState: AudioPlaybackState.playing,
    );

    await _services.conversationService.addMessageToActiveSession(aiMsg);
    _scrollToBottom();

    // Playback simulated or live speech
    setState(() {
      _currentlyPlayingAudioMessageId = aiMsg.id;
      _voiceState = VoiceState.speaking;
    });
    await _services.ttsService.speak(response.text);
  }

  void _startVoiceSession() {
    _services.sttService.startListening();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return StreamBuilder<VoiceState>(
              stream: _services.sttService.stateStream,
              initialData: _voiceState,
              builder: (context, snapshot) {
                final currentSttState = snapshot.data ?? VoiceState.ready;

                return VoiceStateOverlay(
                  state: currentSttState,
                  liveTranscript: _liveTranscript,
                  soundLevel: _soundLevel,
                  onStopListening: () async {
                    final transcript = await _services.sttService.stopListening();
                    if (!sheetContext.mounted) return;
                    Navigator.of(sheetContext).pop();
                    if (transcript.isNotEmpty) {
                      await _handleSendMessage(transcript);
                    }
                  },
                  onCancel: () {
                    _services.sttService.stopListening();
                    _services.sttService.setVoiceState(VoiceState.ready);
                    Navigator.of(sheetContext).pop();
                  },
                  onStopSpeaking: () {
                    _services.ttsService.stop();
                    _services.sttService.setVoiceState(VoiceState.ready);
                    Navigator.of(sheetContext).pop();
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _openQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171F2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWarm.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.note_add_outlined, color: AppColors.primaryWarm),
                ),
                title: const Text('Preserve a New Memory'),
                subtitle: const Text('Add a family story or life lesson'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final newMemory = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddEditMemoryDialog(),
                  );
                  if (newMemory != null) {
                    await _services.memoryService.addMemory(newMemory);
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Memory preserved safely.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySage.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_stories_outlined, color: AppColors.secondarySage),
                ),
                title: const Text('Browse Preserved Memories'),
                subtitle: const Text('View Eleanor / Appa\'s archive'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onNavigateToMemories?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startNewConversation() async {
    await _services.conversationService.startNewSession();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Started a new conversation. Previous history saved.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
        actions: [
          // New Conversation Button
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 26),
            tooltip: 'New Conversation',
            onPressed: _startNewConversation,
          ),
          // Person Profile Avatar Button
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 24),
            tooltip: 'Memory Profile',
            onPressed: _openProfile,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Active Conversation Messages or Clean Mobile Empty State
          Expanded(
            child: ListenableBuilder(
              listenable: _services.conversationService,
              builder: (context, _) {
                final activeSession = _services.conversationService.activeSession;
                final messages = activeSession?.messages ?? [];

                if (messages.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                final totalItems = messages.length + (_isAiThinking ? 1 : 0);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    if (index == messages.length && _isAiThinking) {
                      return _buildThinkingBubble(isDark);
                    }
                    final msg = messages[index];
                    return ChatBubble(
                      message: msg,
                      isAudioPlaying: _currentlyPlayingAudioMessageId == msg.id,
                      onPlayAudio: msg.isFromAi
                          ? () async {
                              if (_currentlyPlayingAudioMessageId == msg.id) {
                                await _services.ttsService.stop();
                                setState(() {
                                  _currentlyPlayingAudioMessageId = null;
                                  _voiceState = VoiceState.ready;
                                });
                              } else {
                                setState(() {
                                  _currentlyPlayingAudioMessageId = msg.id;
                                  _voiceState = VoiceState.speaking;
                                });
                                await _services.ttsService.speak(msg.text);
                              }
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),

          // Voice-First Bottom Bar: [ + ] Message APDM... [ 🎤 ]
          VoiceInputBar(
            onSendMessage: _handleSendMessage,
            onMicTap: _startVoiceSession,
            onPlusTap: _openQuickActions,
            isVoiceActive: _voiceState == VoiceState.listening,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // Gentle Welcoming Emblem with Soft Aura Glow
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryWarm.withAlpha(isDark ? 35 : 22),
                border: Border.all(
                  color: AppColors.primaryWarm.withAlpha(90),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryWarm.withAlpha(isDark ? 40 : 25),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  size: 36,
                  color: AppColors.primaryWarm,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Unique High-Quality Categorized Suggestions & "Innum paaru"
          SuggestedConversationsBar(
            onSelectSuggestion: (prompt) => _handleSendMessage(prompt),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble(bool isDark) {
    final palette = _services.themeProvider.currentPalette;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2837) : const Color(0xFFF2ECE1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: palette.primary.withAlpha(80),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: palette.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Pesitu irukku...',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
