import 'stt_engine.dart';

class StubSpeechEngine implements IBrowserSpeechEngine {
  @override
  bool get isSupported => false;

  @override
  void startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(double level) onSoundLevel,
    required Function(String error) onError,
  }) {}

  @override
  void stopListening() {}
}

IBrowserSpeechEngine getBrowserSpeechEngine() => StubSpeechEngine();
