import 'package:flutter/material.dart';
import '../services/service_locator.dart';

/// Modern mobile Voice-First bottom input area.
/// Format: [ + ]  Message APDM...  [ 🎤 ]
class VoiceInputBar extends StatefulWidget {
  final ValueChanged<String> onSendMessage;
  final VoidCallback onMicTap;
  final VoidCallback onPlusTap;
  final bool isVoiceActive;

  const VoiceInputBar({
    super.key,
    required this.onSendMessage,
    required this.onMicTap,
    required this.onPlusTap,
    this.isVoiceActive = false,
  });

  @override
  State<VoiceInputBar> createState() => _VoiceInputBarState();
}

class _VoiceInputBarState extends State<VoiceInputBar> {
  final TextEditingController _textController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasNow = _textController.text.trim().isNotEmpty;
      if (hasNow != _hasText) {
        setState(() => _hasText = hasNow);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ServiceLocator.instance.themeProvider;
    final palette = themeProvider.currentPalette;
    final isDark = themeProvider.isDarkMode;

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 16,
      ),
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
        child: Row(
          children: [
            // [ + ] Shortcut Button
            IconButton(
              icon: Icon(Icons.add_circle_outline_rounded, size: 26, color: palette.primary),
              tooltip: 'Preserve Memory or Topics',
              onPressed: widget.onPlusTap,
            ),
            const SizedBox(width: 4),

            // Text Input Pill
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? palette.card : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: palette.border,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: TextStyle(fontSize: 15, color: palette.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Message APDM in Tanglish / English...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: palette.textMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Prominent Voice Button or Send Button
            if (_hasText)
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.primary,
                  boxShadow: themeProvider.ambientGlow
                      ? [
                          BoxShadow(
                            color: palette.accentGlow.withAlpha(80),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded, color: Colors.black, size: 24),
                  onPressed: _send,
                ),
              )
            else
              GestureDetector(
                onTap: widget.onMicTap,
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
                        blurRadius: themeProvider.ambientGlow ? 16 : 10,
                        spreadRadius: themeProvider.ambientGlow ? 2 : 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.isVoiceActive ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
