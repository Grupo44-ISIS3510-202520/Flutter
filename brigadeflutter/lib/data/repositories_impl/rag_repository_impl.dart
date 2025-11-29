// data/repositories_impl/rag_repository_impl.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../cache/rag_cache.dart';
import '../models/rag_model.dart';
import '../repositories/rag_repository.dart';

class RagRepositoryImpl implements RagRepository {
  final RagCache _cache;
  final http.Client _httpClient;

  // Load from .env
  late final String _baseUrl;
  late final String _apiKeyHeader;
  late final String _apiKey;

  static const String _chatEndpoint = '/chat';
  static const Duration _timeout = Duration(seconds: 30);

  RagRepositoryImpl({
    required RagCache cache,
    http.Client? httpClient,
  })  : _cache = cache,
        _httpClient = httpClient ?? http.Client() {
    _baseUrl = dotenv.env['RAG_BASE_URL'] ?? '';
    _apiKeyHeader = dotenv.env['RAG_API_KEY_HEADER'] ?? 'X-API-Key';
    _apiKey = dotenv.env['RAG_API_KEY'] ?? '';

    if (_baseUrl.isEmpty || _apiKey.isEmpty) {
      throw Exception(
        'RAG configuration missing in .env file. '
            'Please add RAG_BASE_URL and RAG_API_KEY',
      );
    }
  }

  @override
  Future<void> initializeCache() async {
    await _cache.init();
  }

  @override
  Future<(RagResponse, bool)> getAnswer(String query) async {
    // Check cache first
    final cachedEntry = _cache.get(query);
    if (cachedEntry != null) {
      final response = RagResponse(
        answer: cachedEntry.answer,
        sources: cachedEntry.sources,
      );
      return (response, true);
    }

    // Make API request
    try {
      final url = Uri.parse('$_baseUrl$_chatEndpoint');
      final request = RagRequest(query: query);

      final response = await _httpClient
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          _apiKeyHeader: _apiKey,
        },
        body: json.encode(request.toJson()),
      )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final ragResponse = RagResponse.fromJson(jsonResponse);

        // Cache the response
        await _cache.put(query, ragResponse.answer, ragResponse.sources);

        return (ragResponse, false);
      } else {
        throw Exception(
          'Failed to get answer: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again.');
      }
      throw Exception('Error getting answer: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _cache.clear();
  }

  @override
  Future<int> getCacheSize() async {
    return _cache.size;
  }

  @override
  Future<List<RagCacheEntry>> getCacheHistory() async {
    return _cache.getAllEntries();
  }
}