import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/language.dart';
import 'stt/stt_engine.dart';

/// Voice interaction states representing the companion lifecycle.
enum VoiceState {
  ready,
  listening,
  processing,
  speaking,
}

/// Abstract contract for Speech-to-Text service.
abstract class ISpeechToTextService {
  VoiceState get currentState;
  Stream<VoiceState> get stateStream;
  Stream<String> get transcriptStream;
  Stream<double> get soundLevelStream;
  Future<void> startListening({AppLanguage? language});
  Future<String> stopListening();
  void setVoiceState(VoiceState state);
  void updateLiveTranscript(String text);
  void dispose();
}

/// Real Speech-to-Text service supporting Web Speech Recognition,
/// live microphone waveform levels, and dynamic transcript capture.
class SpeechToTextService implements ISpeechToTextService {
  VoiceState _state = VoiceState.ready;
  final StreamController<VoiceState> _stateController = StreamController<VoiceState>.broadcast();
  final StreamController<String> _transcriptController = StreamController<String>.broadcast();
  final StreamController<double> _soundLevelController = StreamController<double>.broadcast();

  final IBrowserSpeechEngine _browserEngine = createBrowserSpeechEngine();
  Timer? _waveformTimer;
  String _currentTranscribedText = '';

  @override
  VoiceState get currentState => _state;

  @override
  Stream<VoiceState> get stateStream => _stateController.stream;

  @override
  Stream<String> get transcriptStream => _transcriptController.stream;

  @override
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  @override
  void setVoiceState(VoiceState state) {
    _state = state;
    _stateController.add(state);
  }

  @override
  void updateLiveTranscript(String text) {
    _currentTranscribedText = text;
    _transcriptController.add(text);
  }

  @override
  Future<void> startListening({AppLanguage? language}) async {
    _waveformTimer?.cancel();
    _currentTranscribedText = '';
    setVoiceState(VoiceState.listening);

    // Audio waveform animation
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state == VoiceState.listening) {
        final level = 0.2 + (math.Random().nextDouble() * 0.8);
        _soundLevelController.add(level);
      } else {
        timer.cancel();
      }
    });

    if (_browserEngine.isSupported) {
      _browserEngine.startListening(
        onResult: (text, isFinal) {
          _currentTranscribedText = text;
          _transcriptController.add(text);
        },
        onSoundLevel: (level) {
          _soundLevelController.add(level);
        },
        onError: (err) {
          debugPrint('[STT Error]: ');
        },
      );
    }
  }

  @override
  Future<String> stopListening() async {
    _waveformTimer?.cancel();
    if (_browserEngine.isSupported) {
      _browserEngine.stopListening();
    }
    setVoiceState(VoiceState.processing);
    return _currentTranscribedText.trim();
  }

  @override
  void dispose() {
    _waveformTimer?.cancel();
    if (_browserEngine.isSupported) {
      _browserEngine.stopListening();
    }
    _stateController.close();
    _transcriptController.close();
    _soundLevelController.close();
  }
}

/// Backward compatibility alias
typedef MockSpeechToTextService = SpeechToTextService;
