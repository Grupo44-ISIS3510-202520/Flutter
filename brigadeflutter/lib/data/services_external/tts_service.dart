import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final _tts = FlutterTts();

  Future<void> init({String lang = 'en-US'}) async {
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.75);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (_) {
      await _tts.stop();
    }
  }
}
