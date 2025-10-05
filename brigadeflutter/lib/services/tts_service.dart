import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final _tts = FlutterTts();

  Future<void> init({String lang = 'es-ES'}) async {
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.95);  // ritmo claro
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    await _tts.stop();        // detén lo actual antes de hablar
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  /// Ojo: `pause` solo está soportado en algunas plataformas. Maneja el error si falla.
  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (_) {
      // Si la plataforma no soporta pause, simplemente detén
      await _tts.stop();
    }
  }
}
