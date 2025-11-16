import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

abstract class OpenAIService {
  Future<String> getInstructionText({required String emergencyType});
}

class OpenAIServiceImpl implements OpenAIService {
  OpenAIServiceImpl() : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  OpenAIServiceImpl.withKey(this._apiKey);
  // final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _apiKey;
  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  @override
  Future<String> getInstructionText({required String emergencyType}) async {
    final Box<String> box = await Hive.openBox<String>('ai_cache');
    final String key = emergencyType.toLowerCase().trim();

    // check cache first
    final String? cached = box.get(key);
    if (cached != null) {
      return cached;
    }

    if (_apiKey.isEmpty) {
      throw Exception('missing OPENAI_API_KEY');
    }

    final http.Response res = await http.post(
      Uri.parse(_endpoint),
      headers: <String, String>{
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, Object>{
        'model': _model,
        'temperature': 0.2,
        'messages': <Map<String, String>>[
          <String, String>{
            'role': 'system',
            'content': 'You are a safety assistant. Give clear, short steps.',
          },
          <String, String>{
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
    final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;

    final String text = (data['choices']?[0]?['message']?['content'] ?? '')
        .toString()
        .trim();

    // cache result
    await box.put(
      key,
      jsonEncode(<String, Object>{
        'text': text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );
    return text;
  }
}
