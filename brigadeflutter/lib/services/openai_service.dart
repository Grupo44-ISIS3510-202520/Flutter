import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  Future<String> getInstructionText({required String emergencyType}) async {
    if (_apiKey.isEmpty) {
      throw Exception('Falta OPENAI_API_KEY en .env');
    }

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.2,
        'messages': [
          {
            'role': 'system',
            'content':
                'Eres un asistente de seguridad. Da pasos claros y breves. No inventes diagnósticos.'
          },
          {
            'role': 'user',
            'content':
                'Dame 4–6 pasos inmediatos para la emergencia: "$emergencyType". Español, frases cortas numeradas.'
          }
        ],
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('OpenAI ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return (data['choices']?[0]?['message']?['content'] ?? '').toString().trim();
  }
}
