import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/chat_message.dart';
import '../../services/service_locator.dart';
import '../../services/stt_service.dart';
import '../../widgets/voice_orb_visualizer.dart';

/// Voice Conversation Screen - the heart of the APDM voice-first memorial experience.
class VoiceConversationScreen extends StatefulWidget {
  final String? initialTopic;

  const VoiceConversationScreen({super.key, this.initialTopic});

  @override
  State<VoiceConversationScreen> createState() => _VoiceConversationScreenState();
}

class _VoiceConversationScreenState extends State<VoiceConversationScreen> {
  final ServiceLocator _services = ServiceLocator.instance;
  final ScrollController _scrollController = ScrollController();

  VoiceState _voiceState = VoiceState.ready;
  StreamSubscription<VoiceState>? _stateSubscription;
  StreamSubscription<String>? _transcriptSubscription;
  StreamSubscription<bool>? _ttsSubscription;

  String _liveTranscript = '';
  bool _showFullTranscript = false;

  final List<String> _quickPrompts = [
    'Appa, innikku enakku romba kashtama irukku...',
    'Appa, innikku eppadi irukkeenga?',
    'Appavukku entha unavu romba pidikkum?',
    'Appa, namma childhood ninaivugal sollunga...',
    'Appa, porumai pathi unga advice enna?',
  ];

  @override
  void initState() {
    super.initState();
    _initServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSession();
    });
  }

  void _initServices() {
    _stateSubscription = _services.sttService.stateStream.listen((state) {
      if (mounted) setState(() => _voiceState = state);
    });

    _transcriptSubscription = _services.sttService.transcriptStream.listen((text) {
      if (mounted) {
        setState(() => _liveTranscript = text);
        _scrollToBottom();
      }
    });

    _ttsSubscription = _services.ttsService.isSpeakingStream.listen((isSpeaking) {
      if (mounted) {
        setState(() {
          _voiceState = isSpeaking ? VoiceState.speaking : VoiceState.ready;
        });
      }
    });
  }

  Future<void> _startSession() async {
    final profileName = _services.profileService.profile.lovedOneName;
    await _services.conversationService.startNewSession(
      customTitle: widget.initialTopic != null
          ? 'Reflection: ${widget.initialTopic}'
          : 'Conversation with $profileName\'s Companion',
    );
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _transcriptSubscription?.cancel();
    _ttsSubscription?.cancel();
    _services.sttService.setVoiceState(VoiceState.ready);
    _services.ttsService.stop();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleMicOrbTap() async {
    if (_voiceState == VoiceState.ready) {
      await _services.sttService.startListening();
    } else if (_voiceState == VoiceState.listening) {
      final userUtterance = _liveTranscript.trim().isNotEmpty
          ? _liveTranscript.trim()
          : 'Appa, namma kudumba ninaivugal pathi pesunga.';
      await _services.sttService.stopListening();
      await _processUserUtterance(userUtterance);
    } else if (_voiceState == VoiceState.speaking) {
      await _services.ttsService.stop();
      _services.sttService.setVoiceState(VoiceState.ready);
    }
  }

  Future<void> _processUserUtterance(String utterance) async {
    setState(() {
      _voiceState = VoiceState.processing;
      _liveTranscript = '';
    });

    final detectedLang = _services.languageService.detectLanguage(utterance);

    // 1. Add user message to session
    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _services.conversationService.activeSession?.id,
      text: utterance,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      detectedLanguage: detectedLang,
    );
    await _services.conversationService.addMessageToActiveSession(userMessage);
    _scrollToBottom();

    // 2. Generate multilingual AI response based on memories, profile & complete history
    final memories = _services.memoryService.memories;
    final profile = _services.profileService.profile;
    final history = _services.conversationService.activeSession?.messages ?? [];
    final aiResult = await _services.aiService.generateMultilingualResponse(
      userUtterance: utterance,
      memories: memories,
      profile: profile,
      conversationHistory: history,
    );

    // 3. Add AI message to session
    final aiMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
      conversationId: _services.conversationService.activeSession?.id,
      text: aiResult.text,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      detectedLanguage: aiResult.language,
      audioState: AudioPlaybackState.playing,
    );
    await _services.conversationService.addMessageToActiveSession(aiMessage);
    _scrollToBottom();

    // 4. Begin TTS playback simulation
    if (mounted) {
      setState(() => _voiceState = VoiceState.speaking);
      await _services.ttsService.speak(aiResult.text);
    }
  }

  String _getStateStatusLabel() {
    switch (_voiceState) {
      case VoiceState.ready:
        return AppStrings.stateReady;
      case VoiceState.listening:
        return AppStrings.stateListening;
      case VoiceState.processing:
        return AppStrings.stateProcessing;
      case VoiceState.speaking:
        return AppStrings.stateSpeaking;
    }
  }

  String _getStateHint() {
    switch (_voiceState) {
      case VoiceState.ready:
        return AppStrings.readyHint;
      case VoiceState.listening:
        return AppStrings.listeningHint;
      case VoiceState.processing:
        return AppStrings.processingHint;
      case VoiceState.speaking:
        return AppStrings.speakingHint;
    }
  }

  Color _getStateColor() {
    switch (_voiceState) {
      case VoiceState.ready:
        return AppColors.voiceReady;
      case VoiceState.listening:
        return AppColors.voiceListening;
      case VoiceState.processing:
        return AppColors.voiceProcessing;
      case VoiceState.speaking:
        return AppColors.voiceSpeaking;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeSession = _services.conversationService.activeSession;
    final messages = activeSession?.messages ?? [];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _services.conversationService.endActiveSession();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () async {
              await _services.conversationService.endActiveSession();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Kural Ninaivugal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _showFullTranscript ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
                size: 22,
                color: _showFullTranscript ? theme.colorScheme.primary : null,
              ),
              tooltip: _showFullTranscript ? 'Hide transcript' : 'Show transcript',
              onPressed: () {
                setState(() => _showFullTranscript = !_showFullTranscript);
              },
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'End Reflection Session',
              onPressed: () async {
                await _services.conversationService.endActiveSession();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Ethical Banner Notice
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF3ECE0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C394E) : const Color(0xFFE2D7C3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kudumba Ninaivugal • Preserved family stories',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Transcript Area or Central Visualizer
              Expanded(
                child: _showFullTranscript
                    ? _buildFullTranscriptView(messages, isDark)
                    : _buildVoiceFocusedView(messages, isDark),
              ),

              // Quick prompts for simple voice simulation testing
              if (_voiceState == VoiceState.ready)
                _buildQuickPromptsSection(isDark),

              // Bottom Control Bar
              _buildBottomControls(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceFocusedView(List<ChatMessage> messages, bool isDark) {
    final latestAiMessage = messages.lastWhere(
      (m) => m.isFromAi,
      orElse: () => ChatMessage(
        id: 'initial_prompt',
        text: 'Vanakkam. Namma kudumba ninaivugal pathi pesalaam ❤️. Enna vishayam pesa virumbureenga?',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Large Animated Visualizer Orb
            VoiceOrbVisualizer(
              state: _voiceState,
              size: 210,
              onTap: _handleMicOrbTap,
            ),
            const SizedBox(height: 24),

            // Current State Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStateColor().withAlpha(isDark ? 45 : 30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStateColor().withAlpha(120),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStateColor(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStateStatusLabel(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getStateColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Dynamic Hint Text
            Text(
              _getStateHint(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 24),

            // Live Speech Transcript or Recent Dialogue
            if (_voiceState == VoiceState.listening && _liveTranscript.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.voiceListening.withAlpha(isDark ? 25 : 18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.voiceListening.withAlpha(80),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.graphic_eq_rounded, size: 16, color: AppColors.voiceListening),
                        const SizedBox(width: 6),
                        Text(
                          'Transcribing your voice...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$_liveTranscript"',
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Recent Companion Spoken Response Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 15,
                          color: AppColors.primaryWarm,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Companion Response',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryWarm,
                          ),
                        ),
                        const Spacer(),
                        if (_voiceState == VoiceState.speaking)
                          const Text(
                            'Speaking audio...',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.voiceSpeaking,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      latestAiMessage.text,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullTranscriptView(List<ChatMessage> messages, bool isDark) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Tap the microphone to start speaking.',
          style: TextStyle(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isUser = msg.isFromUser;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primaryWarm
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: isUser
                  ? null
                  : Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Companion',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUser
                        ? Colors.black87
                        : (isDark ? AppColors.primaryWarm : AppColors.primaryDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: isUser
                        ? Colors.black
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickPromptsSection(bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _quickPrompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return ActionChip(
            label: Text(
              prompt,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            backgroundColor: isDark ? const Color(0xFF1B2332) : const Color(0xFFEEE8DC),
            side: BorderSide(
              color: isDark ? const Color(0xFF2C394E) : const Color(0xFFDFD7C7),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onPressed: () => _processUserUtterance(prompt),
          );
        },
      ),
    );
  }

  Widget _buildBottomControls(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Cancel / End Session
          OutlinedButton.icon(
            onPressed: () async {
              await _services.conversationService.endActiveSession();
              if (mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.stop_circle_outlined, size: 18),
            label: const Text('End Session'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),

          // Primary Mic Toggle CTA
          ElevatedButton.icon(
            onPressed: _handleMicOrbTap,
            icon: Icon(
              _voiceState == VoiceState.listening
                  ? Icons.stop_rounded
                  : (_voiceState == VoiceState.speaking
                      ? Icons.volume_off_rounded
                      : Icons.mic_rounded),
              size: 20,
            ),
            label: Text(
              _voiceState == VoiceState.listening
                  ? 'Done Speaking'
                  : (_voiceState == VoiceState.speaking ? 'Stop Voice' : 'Tap to Speak'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _voiceState == VoiceState.listening
                  ? AppColors.voiceListening
                  : (_voiceState == VoiceState.speaking
                      ? AppColors.voiceSpeaking
                      : Theme.of(context).colorScheme.primary),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
