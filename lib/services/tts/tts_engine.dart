import 'dart:ui';
import 'tts_engine_stub.dart'
    if (dart.library.html) 'tts_engine_web.dart';

abstract class IBrowserTtsEngine {
  bool get isSupported;
  void speak(String text, {required VoidCallback onDone});
  void stop();
}

IBrowserTtsEngine createBrowserTtsEngine() => getBrowserTtsEngine();
