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

    // 🔍 Debug: Print configuration (remove in production)
    print('🔧 RAG Configuration:');
    print('   Base URL: $_baseUrl');
    print('   API Key Header: $_apiKeyHeader');
    print('   API Key: ${_apiKey.isEmpty ? "MISSING" : "${_apiKey.substring(0, 5)}..."}');

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
    print('✅ RAG Cache initialized with ${_cache.size} entries');
  }

  @override
  Future<(RagResponse, bool)> getAnswer(String query) async {
    print('🤔 RAG Query: "$query"');

    // Check cache first
    final cachedEntry = _cache.get(query);
    if (cachedEntry != null) {
      print('✅ Found in cache!');
      final response = RagResponse(
        answer: cachedEntry.answer,
        sources: cachedEntry.sources,
      );
      return (response, true);
    }

    print('📡 Making API request...');

    // Make API request
    try {
      final url = Uri.parse('$_baseUrl$_chatEndpoint');
      final request = RagRequest(query: query);
      final requestBody = json.encode(request.toJson());

      // 🔍 Debug: Log request details
      print('🌐 Request URL: $url');
      print('📦 Request Body: $requestBody');
      print('🔑 Headers: Content-Type: application/json, $_apiKeyHeader: ${_apiKey.substring(0, 5)}...');

      final response = await _httpClient
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          _apiKeyHeader: _apiKey,
        },
        body: requestBody,
      )
          .timeout(_timeout);

      // 🔍 Debug: Log response
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final ragResponse = RagResponse.fromJson(jsonResponse);

        print('✅ Success! Answer received (${ragResponse.answer.length} chars)');

        // Cache the response
        await _cache.put(query, ragResponse.answer, ragResponse.sources);

        return (ragResponse, false);
      } else {
        // 🔍 Enhanced error logging
        print('❌ API Error ${response.statusCode}');
        print('❌ Error Body: ${response.body}');

        throw Exception(
          'Failed to get answer: ${response.statusCode} ${response.reasonPhrase}\n'
              'Response: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      print('❌ Network Error: $e');
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      print('❌ JSON Parse Error: $e');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again.');
      }
      throw Exception('Error getting answer: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _cache.clear();
    print('🗑️ RAG Cache cleared');
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