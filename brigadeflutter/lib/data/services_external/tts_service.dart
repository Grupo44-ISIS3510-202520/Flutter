import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsService {
  Future<void> init({String lang});
  Future<void> speak(String text);
  Future<void> stop();
}

class TtsServiceImpl implements TtsService {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> init({String lang = 'en-US'}) async {
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.75);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  @override
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();
}
