import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/stt_service.dart';

/// Modal bottom sheet providing a modern, real-time Voice AI interaction surface.
/// Supports Ready, Listening, Thinking, and Speaking states with reactive animations.
class VoiceStateOverlay extends StatelessWidget {
  final VoiceState state;
  final String liveTranscript;
  final double soundLevel;
  final VoidCallback onStopListening;
  final VoidCallback onCancel;
  final VoidCallback onStopSpeaking;

  const VoiceStateOverlay({
    super.key,
    required this.state,
    required this.liveTranscript,
    this.soundLevel = 0.3,
    required this.onStopListening,
    required this.onCancel,
    required this.onStopSpeaking,
  });

  Color _getStateColor() {
    switch (state) {
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

  String _getStateTitle() {
    switch (state) {
      case VoiceState.ready:
        return 'Ready to Listen';
      case VoiceState.listening:
        return 'Listening...';
      case VoiceState.processing:
        return 'Reflecting on memories...';
      case VoiceState.speaking:
        return 'Speaking response...';
    }
  }

  String _getStateSubtitle() {
    switch (state) {
      case VoiceState.ready:
        return 'Speak naturally in Tamil, English, or Tanglish';
      case VoiceState.listening:
        return 'Automatic language detection active';
      case VoiceState.processing:
        return 'Finding comforting stories & lessons';
      case VoiceState.speaking:
        return 'Tap Stop if you want to speak again';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stateColor = _getStateColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141B26) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 30),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Central Waveform / Orb
          SizedBox(
            height: 110,
            child: Center(
              child: _buildStateVisualizer(stateColor),
            ),
          ),
          const SizedBox(height: 16),

          // State Title
          Text(
            _getStateTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: stateColor,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            _getStateSubtitle(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 16),

          // Live Transcript Box
          if (state == VoiceState.listening && liveTranscript.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: stateColor.withAlpha(isDark ? 30 : 20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: stateColor.withAlpha(80)),
              ),
              child: Text(
                '"$liveTranscript"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel Button
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black87,
                  side: BorderSide(
                    color: isDark ? const Color(0xFF2C394E) : const Color(0xFFD5CCC0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),

              // Done / Action Button
              if (state == VoiceState.listening)
                ElevatedButton.icon(
                  onPressed: onStopListening,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text('Done Speaking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stateColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              else if (state == VoiceState.speaking)
                ElevatedButton.icon(
                  onPressed: onStopSpeaking,
                  icon: const Icon(Icons.stop_rounded, size: 20),
                  label: const Text('Stop Voice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stateColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateVisualizer(Color color) {
    if (state == VoiceState.listening) {
      // Dynamic multi-bar audio wave reacting to soundLevel
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(18, (i) {
          final barScale = math.sin((i / 18) * math.pi) * soundLevel;
          final barHeight = (20.0 + (barScale * 65.0)).clamp(12.0, 85.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: 4.5,
            height: barHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(80),
                  blurRadius: 8,
                ),
              ],
            ),
          );
        }),
      );
    } else if (state == VoiceState.processing) {
      return SizedBox(
        width: 64,
        height: 64,
        child: CircularProgressIndicator(
          strokeWidth: 3.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    } else {
      // Speaking pulse orb
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(40),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(90),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(Icons.volume_up_rounded, color: color, size: 36),
      );
    }
  }
}
