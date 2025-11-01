import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class OpenAIService {
  Future<String> getInstructionText({required String emergencyType});
}

class OpenAIServiceImpl implements OpenAIService {
  // final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _apiKey;
  OpenAIServiceImpl() : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  OpenAIServiceImpl.withKey(this._apiKey);
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  @override
  Future<String> getInstructionText({required String emergencyType}) async {
    final box = await Hive.openBox<String>('ai_cache');
    final key = emergencyType.toLowerCase().trim();

    // check cache first
    final cached = box.get(key);
    if (cached != null) {
      return cached;
    }

    if (_apiKey.isEmpty) {
      throw Exception('missing OPENAI_API_KEY');
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
            'content': 'You are a safety assistant. Give clear, short steps.',
          },
          {
            'role': 'user',
            'content':
                'Give 2-4 numbered steps for emergency: "$emergencyType". Keep it concise.',
          },
        ],
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('OpenAI ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;

    final text = (data['choices']?[0]?['message']?['content'] ?? '')
        .toString()
        .trim();

    // cache result
    await box.put(
      key,
      jsonEncode({
        'text': text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );
    return text;
  }
}
