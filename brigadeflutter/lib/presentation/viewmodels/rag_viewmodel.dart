import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/rag_model.dart';
import '../../data/repositories/rag_repository.dart';

// State classes
abstract class RagState {}
class RagIdle extends RagState {}
class RagLoading extends RagState {}
class RagSuccess extends RagState {
  final String answer;
  final List<String> sources;
  final bool fromCache;
  RagSuccess(this.answer, this.sources, {this.fromCache = false});
}
class RagError extends RagState {
  final String message;
  RagError(this.message);
}

class RagViewModel extends ChangeNotifier {
  final RagRepository _repository;

  RagViewModel({required RagRepository repository}) : _repository = repository {
    _initializeCache();
  }

  // State
  RagState _state = RagIdle();
  int _cacheSize = 0;
  List<RagCacheEntry> _cacheHistory = [];

  // Debouncing
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 800);

  // Getters
  RagState get state => _state;
  int get cacheSize => _cacheSize;
  List<RagCacheEntry> get cacheHistory => _cacheHistory;

  // Initialize cache
  Future<void> _initializeCache() async {
    try {
      await _repository.initializeCache();
      await _updateCacheStats();
    } catch (e) {
      print('Failed to initialize cache: $e');
    }
  }

  // Update cache statistics
  Future<void> _updateCacheStats() async {
    try {
      _cacheSize = await _repository.getCacheSize();
      notifyListeners();
    } catch (e) {
      print('Failed to update cache stats: $e');
    }
  }

  // Ask question with debounce protection
  Future<void> askQuestion(String query) async {
    final trimmedQuery = query.trim();
    
    // Validation
    if (trimmedQuery.isEmpty) {
      _state = RagError('Please enter a question');
      notifyListeners();
      return;
    }

    if (_state is RagLoading) {
      print('Request already in progress - ignoring');
      return;
    }

    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    // Set loading state
    _state = RagLoading();
    notifyListeners();

    try {
      print('Sending query: "$trimmedQuery"');
      
      final result = await _repository.getAnswer(trimmedQuery);
      
      final response = result.$1;
      final fromCache = result.$2;

      _state = RagSuccess(
        response.answer,
        response.sources,
        fromCache: fromCache,
      );

      print('✅ Query completed (fromCache: $fromCache)');
      
      // Update cache stats
      await _updateCacheStats();
    } catch (e) {
      final errorMsg = _getUserFriendlyError(e);
      _state = RagError(errorMsg);
      print('Query failed: $errorMsg');
    } finally {
      notifyListeners();
    }
  }

  // Load cache history
  Future<void> loadCacheHistory() async {
    try {
      _cacheHistory = await _repository.getCacheHistory();
      notifyListeners();
    } catch (e) {
      print('Failed to load cache history: $e');
    }
  }

  // Use cached query
  void useCachedQuery(RagCacheEntry entry) {
    _state = RagSuccess(
      entry.answer,
      entry.sources,
      fromCache: true,
    );
    notifyListeners();
  }

  // Convert technical errors to user-friendly messages
  String _getUserFriendlyError(dynamic error) {
    final errorMsg = error.toString().toLowerCase();

    if (errorMsg.contains('timeout')) {
      return 'Request took too long. Please try again.';
    } else if (errorMsg.contains('network') || errorMsg.contains('connection')) {
      return 'No internet connection. Please check your network.';
    } else if (errorMsg.contains('temporarily unavailable')) {
      return error.toString().replaceFirst('Exception: ', '');
    } else if (errorMsg.contains('500') || errorMsg.contains('server error')) {
      return 'Server is experiencing issues. Please try again in a moment.';
    } else if (errorMsg.contains('401') || errorMsg.contains('403')) {
      return 'Authentication error. Please contact support.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  // Clear current response
  void clearResponse() {
    _state = RagIdle();
    notifyListeners();
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();
      await _updateCacheStats();
      _cacheHistory = [];
      print('Cache cleared');
      notifyListeners();
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}