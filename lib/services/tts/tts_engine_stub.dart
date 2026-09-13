import 'dart:ui';
import 'tts_engine.dart';

class StubTtsEngine implements IBrowserTtsEngine {
  @override
  bool get isSupported => false;

  @override
  void speak(String text, {required VoidCallback onDone}) {
    onDone();
  }

  @override
  void stop() {}
}

IBrowserTtsEngine getBrowserTtsEngine() => StubTtsEngine();
