import '../services/openai_service.dart';
import '../services/tts_service.dart';

class AIVoiceInstructions {
  final OpenAIService openai;
  final TtsService tts;

  AIVoiceInstructions({required this.openai, required this.tts});

  Future<String> run(String emergencyType) async {
    final text = await openai.getInstructionText(emergencyType: emergencyType);
    await tts.init();
    await tts.speak(text);
    return text;
  }
}
