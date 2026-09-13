import 'dart:async';
import 'tts/tts_engine.dart';

/// Abstract contract for Text-to-Speech synthesis.
abstract class ITextToSpeechService {
  bool get isSpeaking;
  Stream<bool> get isSpeakingStream;
  Future<void> speak(String text);
  Future<void> stop();
  void dispose();
}

/// Text-to-Speech synthesis service supporting Web Speech Synthesis,
/// natural reading cadence, and playback state notifications.
class TextToSpeechService implements ITextToSpeechService {
  bool _isSpeaking = false;
  final StreamController<bool> _speakingController = StreamController<bool>.broadcast();
  final IBrowserTtsEngine _browserEngine = createBrowserTtsEngine();
  Timer? _speechTimer;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Stream<bool> get isSpeakingStream => _speakingController.stream;

  @override
  Future<void> speak(String text) async {
    _speechTimer?.cancel();
    _isSpeaking = true;
    _speakingController.add(true);

    if (_browserEngine.isSupported) {
      _browserEngine.speak(
        text,
        onDone: () {
          _isSpeaking = false;
          _speakingController.add(false);
        },
      );
    } else {
      // Fallback timer simulation for environments without native TTS
      final durationMs = (text.length * 50).clamp(2000, 6000);
      _speechTimer = Timer(Duration(milliseconds: durationMs), () {
        _isSpeaking = false;
        _speakingController.add(false);
      });
    }
  }

  @override
  Future<void> stop() async {
    _speechTimer?.cancel();
    if (_browserEngine.isSupported) {
      _browserEngine.stop();
    }
    if (_isSpeaking) {
      _isSpeaking = false;
      _speakingController.add(false);
    }
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    _browserEngine.stop();
    _speakingController.close();
  }
}

/// Backward compatibility alias
typedef MockTextToSpeechService = TextToSpeechService;
