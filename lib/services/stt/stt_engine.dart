import 'stt_engine_stub.dart'
    if (dart.library.html) 'stt_engine_web.dart';

abstract class IBrowserSpeechEngine {
  bool get isSupported;
  void startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(double level) onSoundLevel,
    required Function(String error) onError,
  });
  void stopListening();
}

IBrowserSpeechEngine createBrowserSpeechEngine() => getBrowserSpeechEngine();
