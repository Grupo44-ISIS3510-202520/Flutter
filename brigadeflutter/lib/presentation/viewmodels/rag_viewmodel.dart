// presentation/viewmodels/rag_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/models/rag_model.dart';
import '../../data/repositories/rag_repository.dart';
import '../../domain/use_cases/get_rag_answer.dart';

class RagViewModel extends ChangeNotifier {
  final GetRagAnswer getRagAnswerUseCase;
  final RagRepository repository;

  RagViewModel({
    required this.getRagAnswerUseCase,
    required this.repository,
  }) {
    _initializeCache();
  }

  RagState _state = RagIdle();
  RagState get state => _state;

  int _cacheSize = 0;
  int get cacheSize => _cacheSize;

  List<RagCacheEntry> _cacheHistory = [];
  List<RagCacheEntry> get cacheHistory => _cacheHistory;

  StreamSubscription<RagState>? _subscription;

  Future<void> _initializeCache() async {
    await repository.initializeCache();
    await _updateCacheSize();
    await loadCacheHistory();
  }

  void askQuestion(String query) {
    _subscription?.cancel();

    _subscription = getRagAnswerUseCase(query).listen(
          (RagState newState) {
        _state = newState;
        notifyListeners();

        if (newState is RagSuccess) {
          _updateCacheSize();
          loadCacheHistory();
        }
      },
      onError: (dynamic error) {
        _state = RagError(error.toString());
        notifyListeners();
      },
    );
  }

  void clearState() {
    _state = RagIdle();
    notifyListeners();
  }

  Future<void> clearCache() async {
    await repository.clearCache();
    await _updateCacheSize();
    await loadCacheHistory();
  }

  Future<void> loadCacheHistory() async {
    _cacheHistory = await repository.getCacheHistory();
    notifyListeners();
  }

  void useCachedQuery(RagCacheEntry entry) {
    _state = RagSuccess(
      answer: entry.answer,
      sources: entry.sources,
      fromCache: true,
    );
    notifyListeners();
  }

  Future<void> _updateCacheSize() async {
    _cacheSize = await repository.getCacheSize();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}