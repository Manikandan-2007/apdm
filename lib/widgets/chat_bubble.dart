import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/theme_provider.dart';
import '../models/chat_message.dart';
import '../services/service_locator.dart';

/// Modern mobile chat bubble dynamically styled according to active theme preset and bubble style.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onPlayAudio;
  final bool isAudioPlaying;

  const ChatBubble({
    super.key,
    required this.message,
    this.onPlayAudio,
    this.isAudioPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = ServiceLocator.instance.themeProvider;
    final palette = themeProvider.currentPalette;
    final isDark = themeProvider.isDarkMode;
    final isUser = message.isFromUser;
    final bubbleStyle = themeProvider.bubbleStyle;

    // Resolve bubble background and borders based on selected style
    Color bubbleColor;
    BoxBorder? bubbleBorder;
    List<BoxShadow>? bubbleShadows;

    if (isUser) {
      bubbleColor = palette.primary;
      bubbleBorder = null;
      bubbleShadows = [
        BoxShadow(
          color: palette.primary.withAlpha(isDark ? 50 : 35),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      switch (bubbleStyle) {
        case BubbleStyle.frostedGlass:
        case BubbleStyle.glassmorphic:
          bubbleColor = palette.card.withAlpha(isDark ? 210 : 230);
          bubbleBorder = Border.all(
            color: palette.primary.withAlpha(60),
            width: 1.2,
          );
          bubbleShadows = [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 35 : 12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ];
          break;
        case BubbleStyle.gentleGlow:
          bubbleColor = palette.card;
          bubbleBorder = Border.all(
            color: palette.primary.withAlpha(80),
            width: 1,
          );
          bubbleShadows = themeProvider.ambientGlow
              ? [
                  BoxShadow(
                    color: palette.accentGlow.withAlpha(50),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null;
          break;
        case BubbleStyle.classicSolid:
        case BubbleStyle.modernCard:
        case BubbleStyle.classicPill:
          bubbleColor = palette.card;
          bubbleBorder = Border.all(color: palette.border, width: 1);
          bubbleShadows = [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 25 : 8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ];
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [palette.primaryLight, palette.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: themeProvider.ambientGlow
                    ? [
                        BoxShadow(
                          color: palette.primary.withAlpha(80),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: const Icon(Icons.graphic_eq_rounded, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 20),
                ),
                border: bubbleBorder,
                boxShadow: bubbleShadows,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Content
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15.0,
                      height: 1.45,
                      color: isUser ? Colors.black : palette.textPrimary,
                      letterSpacing: 0.1,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata Row: Language pill + Audio icon + Timestamp
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Detected Language Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.black.withAlpha(25)
                              : palette.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                          border: isUser
                              ? null
                              : Border.all(color: palette.primary.withAlpha(70), width: 0.8),
                        ),
                        child: Text(
                          message.detectedLanguage.code,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isUser ? Colors.black87 : palette.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Timestamp
                      Text(
                        DateFormat('h:mm a').format(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isUser ? Colors.black54 : palette.textMuted,
                        ),
                      ),

                      if (!isUser && onPlayAudio != null) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onPlayAudio,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              isAudioPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                              size: 16,
                              color: isAudioPlaying ? palette.primary : palette.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
