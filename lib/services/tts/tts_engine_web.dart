// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'tts_engine.dart';

class WebTtsEngine implements IBrowserTtsEngine {
  @override
  bool get isSupported => html.window.speechSynthesis != null;

  @override
  void speak(String text, {required VoidCallback onDone}) {
    if (!isSupported) {
      onDone();
      return;
    }
    try {
      html.window.speechSynthesis?.cancel();
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.rate = 0.95;
      utterance.pitch = 1.0;
      utterance.onEnd.listen((_) => onDone());
      utterance.onError.listen((_) => onDone());
      html.window.speechSynthesis?.speak(utterance);
    } catch (e) {
      debugPrint('[WebTTS] Speak error: ');
      onDone();
    }
  }

  @override
  void stop() {
    try {
      html.window.speechSynthesis?.cancel();
    } catch (e) {
      debugPrint('[WebTTS] Stop error: ');
    }
  }
}

IBrowserTtsEngine getBrowserTtsEngine() => WebTtsEngine();
