// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'stt_engine.dart';

class WebSpeechEngine implements IBrowserSpeechEngine {
  html.SpeechRecognition? _recognition;

  @override
  bool get isSupported => html.SpeechRecognition.supported;

  @override
  void startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(double level) onSoundLevel,
    required Function(String error) onError,
  }) {
    if (!isSupported) {
      onError('Web Speech API is not supported in this browser.');
      return;
    }

    try {
      _recognition?.stop();
      _recognition = html.SpeechRecognition();
      _recognition!.continuous = true;
      _recognition!.interimResults = true;
      _recognition!.lang = 'ta-IN';

      _recognition!.onResult.listen((html.SpeechRecognitionEvent event) {
        final results = event.results;
        if (results == null || results.isEmpty) return;

        final buffer = StringBuffer();
        var isFinal = false;

        for (final res in results) {
          if (res.length != null && res.length! > 0) {
            final item = res.item(0);
            if (item.transcript != null) {
              buffer.write(item.transcript);
              buffer.write(' ');
            }
          }
          if (res.isFinal == true) {
            isFinal = true;
          }
        }

        final text = buffer.toString().trim();
        if (text.isNotEmpty) {
          onResult(text, isFinal);
        }
      });

      _recognition!.onError.listen((event) {
        debugPrint('[WebSpeech] Recognition error: ');
      });

      _recognition!.start();
    } catch (e) {
      debugPrint('[WebSpeech] Failed to start recognition: ');
      onError(e.toString());
    }
  }

  @override
  void stopListening() {
    try {
      _recognition?.stop();
    } catch (e) {
      debugPrint('[WebSpeech] Error stopping recognition: ');
    }
  }
}

IBrowserSpeechEngine getBrowserSpeechEngine() => WebSpeechEngine();
