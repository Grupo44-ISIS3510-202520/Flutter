import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../cache/rag_cache.dart';
import '../models/rag_model.dart';
import '../repositories/rag_repository.dart';

class RagRepositoryImpl implements RagRepository {
  final RagCache _cache;
  final http.Client _httpClient;

  late final String _baseUrl;
  late final String _apiKeyHeader;
  late final String _apiKey;

  static const String _chatEndpoint = '/chat';
  static const Duration _timeout = Duration(seconds: 20);
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 1);

  int _failureCount = 0;
  DateTime? _circuitOpenedAt;
  static const int _failureThreshold = 3;
  static const Duration _circuitResetDuration = Duration(minutes: 1);

  final Map<String, Future<(RagResponse, bool)>> _inFlightRequests = {};

  RagRepositoryImpl({
    required RagCache cache,
    http.Client? httpClient,
  })  : _cache = cache,
        _httpClient = httpClient ?? http.Client() {
    _baseUrl = dotenv.env['RAG_BASE_URL'] ?? '';
    _apiKeyHeader = dotenv.env['RAG_API_KEY_HEADER'] ?? 'X-API-Key';
    _apiKey = dotenv.env['RAG_API_KEY'] ?? '';

    print('🔧 RAG Configuration:');
    print('   Base URL: $_baseUrl');
    print('   Timeout: ${_timeout.inSeconds}s');
    print('   Max Retries: $_maxRetries');

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
    print('RAG Cache initialized with ${_cache.size} entries');
  }

  bool _isCircuitOpen() {
    if (_circuitOpenedAt == null) return false;

    final elapsed = DateTime.now().difference(_circuitOpenedAt!);
    if (elapsed > _circuitResetDuration) {
     
      print('Circuit breaker reset after ${elapsed.inSeconds}s');
      _failureCount = 0;
      _circuitOpenedAt = null;
      return false;
    }

    return true;
  }

  void _recordFailure() {
    _failureCount++;
    print('Failure count: $_failureCount/$_failureThreshold');

    if (_failureCount >= _failureThreshold) {
      _circuitOpenedAt = DateTime.now();
      print('Circuit breaker OPENED - blocking requests for ${_circuitResetDuration.inSeconds}s');
    }
  }

  void _recordSuccess() {
    if (_failureCount > 0) {
      print('Request succeeded - resetting failure count');
      _failureCount = 0;
      _circuitOpenedAt = null;
    }
  }

  @override
  Future<(RagResponse, bool)> getAnswer(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (_inFlightRequests.containsKey(normalizedQuery)) {
      print('Request already in flight for: "$query" - reusing');
      return _inFlightRequests[normalizedQuery]!;
    }

    final requestFuture = _executeGetAnswer(normalizedQuery);
    _inFlightRequests[normalizedQuery] = requestFuture;

    try {
      return await requestFuture;
    } finally {

      _inFlightRequests.remove(normalizedQuery);
    }
  }

  Future<(RagResponse, bool)> _executeGetAnswer(String query) async {
    print('RAG Query: "$query"');

    final cachedEntry = _cache.get(query);
    if (cachedEntry != null) {
      print('Found in cache!');
      final response = RagResponse(
        answer: cachedEntry.answer,
        sources: cachedEntry.sources,
      );
      return (response, true);
    }

    if (_isCircuitOpen()) {
      final timeUntilReset = _circuitResetDuration.inSeconds -
          DateTime.now().difference(_circuitOpenedAt!).inSeconds;
      print('Circuit breaker is OPEN - using cache or failing (reset in ${timeUntilReset}s)');
      throw Exception(
          'Service temporarily unavailable. Please try again in $timeUntilReset seconds.'
      );
    }

    return await _makeRequestWithRetry(query);
  }

  Future<(RagResponse, bool)> _makeRequestWithRetry(String query) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('API Request (attempt $attempt/$_maxRetries)...');

        final response = await _makeSingleRequest(query);

        _recordSuccess();
        return (response, false);

      } on TimeoutException catch (e) {
        lastException = Exception('Request timeout after ${_timeout.inSeconds}s');
        print('Timeout on attempt $attempt: $e');
        _recordFailure();

      } on http.ClientException catch (e) {
        lastException = Exception('Network error: ${e.message}');
        print('Network error on attempt $attempt: $e');
        _recordFailure();

      } catch (e) {
        final errorMsg = e.toString();

        if (errorMsg.contains('400') ||
            errorMsg.contains('401') ||
            errorMsg.contains('403') ||
            errorMsg.contains('404')) {
          print('Client error (no retry): $e');
          _recordFailure();
          rethrow;
        }

        lastException = e is Exception ? e : Exception(e.toString());
        print('Server error on attempt $attempt: $e');
        _recordFailure();
      }

      if (attempt < _maxRetries) {
        final delay = _initialRetryDelay * (1 << (attempt - 1));
        print('Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);
      }
    }

    print('All $_maxRetries attempts failed');
    print('Backend server is down - this is a BACKEND issue, not frontend');
    print('Contact backend team to fix server errors');

    final emergencyResponse = _getEmergencyResponse(query);
    if (emergencyResponse != null) {
      print('Using emergency fallback response');
      await _cache.put(query, emergencyResponse.answer, emergencyResponse.sources);
      return (emergencyResponse, false);
    }

    throw lastException ?? Exception('Failed after $_maxRetries attempts');
  }

  RagResponse? _getEmergencyResponse(String query) {
    final queryLower = query.toLowerCase();

    if (queryLower.contains('sismo') || queryLower.contains('terremoto')) {
      return RagResponse(
        answer: 'IMPORTANTE: El servidor está temporalmente fuera de servicio.\n\n'
            'Guía básica para sismos:\n'
            '1. DURANTE: Agacharse, cubrirse y agarrarse. Proteger cabeza y cuello.\n'
            '2. Alejarse de ventanas, espejos y objetos que puedan caer.\n'
            '3. NO usar elevadores.\n'
            '4. Si está afuera, alejarse de edificios, postes y cables.\n'
            '5. DESPUÉS: Verificar daños, estar alerta a réplicas.\n'
            '6. Seguir instrucciones de autoridades locales.\n\n'
            'Esta es información de emergencia básica. Cuando el servidor se restablezca, obtendrá información más detallada.',
        sources: ['Respuesta de emergencia - Sistema offline'],
      );
    }

    if (queryLower.contains('fuego') || queryLower.contains('incendio')) {
      return RagResponse(
        answer: 'IMPORTANTE: El servidor está temporalmente fuera de servicio.\n\n'
            'Guía básica para incendios:\n'
            '1. Activar alarma y alertar a otros.\n'
            '2. Evacuar inmediatamente por rutas seguras.\n'
            '3. Si hay humo, gatear cerca del suelo.\n'
            '4. NO usar elevadores.\n'
            '5. Cerrar puertas al salir (no con llave).\n'
            '6. Punto de encuentro establecido.\n'
            '7. NO regresar hasta que autoridades lo indiquen.\n\n'
            'Esta es información de emergencia básica. Cuando el servidor se restablezca, obtendrá información más detallada.',
        sources: ['Respuesta de emergencia - Sistema offline'],
      );
    }

    return null;
  }

  Future<RagResponse> _makeSingleRequest(String query) async {
    final url = Uri.parse('$_baseUrl$_chatEndpoint');
    final request = RagRequest(query: query);
    final requestBody = json.encode(request.toJson());

    print('POST $url');

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

    print('Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final ragResponse = RagResponse.fromJson(jsonResponse);

      print('Success! Answer: ${ragResponse.answer.length} chars');
      print('Sources: ${ragResponse.sources.length} items');

      await _cache.put(query, ragResponse.answer, ragResponse.sources);

      return ragResponse;
    } else {

      print(' Error ${response.statusCode}: ${response.body}');
      print(' This is a BACKEND SERVER ERROR');
      print(' Backend needs to be fixed - check:');
      print('   1. Server logs for Python exceptions');
      print('   2. Database connectivity');
      print('   3. Vector store connection');
      print('   4. API authentication/permissions');
      print('   5. Server resource limits (CPU/Memory)');

      throw Exception(
        'API Error ${response.statusCode}: ${response.reasonPhrase ?? "Internal Server Error"}',
      );
    }
  }

  @override
  Future<void> warmUp() async {
    print('Iniciando Wake-Up silencioso del servidor RAG...');

    try {
      final url = Uri.parse('$_baseUrl$_chatEndpoint');

      final requestBody = json.encode({
        "query": "ping_wakeup",
        "history": []
      });

      _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          _apiKeyHeader: _apiKey,
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 5)).then((_) {
        print('Servidor RAG despierto (respuesta recibida en background)');
      }).catchError((e) {
        print('Signal de wake-up enviado (resultado ignorado): $e');
      });

    } catch (e) {
      print('Error al intentar wake-up (no crítico): $e');
    }
  }


  @override
  Future<void> clearCache() async {
    await _cache.clear();
    print('RAG Cache cleared');
  }

  @override
  Future<int> getCacheSize() async {
    return _cache.size;
  }

  @override
  Future<List<RagCacheEntry>> getCacheHistory() async {
    return _cache.getAllEntries();
  }

  void resetCircuitBreaker() {
    _failureCount = 0;
    _circuitOpenedAt = null;
    print('Circuit breaker manually reset');
  }

  Map<String, dynamic> getCircuitBreakerState() {
    return {
      'isOpen': _isCircuitOpen(),
      'failureCount': _failureCount,
      'threshold': _failureThreshold,
      'openedAt': _circuitOpenedAt?.toIso8601String(),
    };
  }
}