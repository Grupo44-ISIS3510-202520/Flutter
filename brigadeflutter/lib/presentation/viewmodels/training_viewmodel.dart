import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/entities/training_card.dart';
import '../../data/entities/training_progress.dart';
import '../../data/repositories/training_repository.dart';

enum UiStatus { initial, loading, ready, error }

class TrainingViewModel extends ChangeNotifier {
  final TrainingRepository _repo;

  TrainingViewModel({required TrainingRepository repo}) : _repo = repo;

  UiStatus _status = UiStatus.initial;
  List<TrainingCard> _cards = [];
  List<TrainingProgress> _progress = [];
  bool _submitting = false;

  UiStatus get status => _status;
  List<TrainingCard> get cards => _cards;
  List<TrainingProgress> get progress => _progress;
  bool get submitting => _submitting;

  Future<void> load() async {
    _status = UiStatus.loading;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _status = UiStatus.error;
        notifyListeners();
        return;
      }

      _cards = await _repo.getCards();
      _progress = await _repo.getProgress(uid); 
      _status = UiStatus.ready;
    } catch (e, st) {
      debugPrint('Training load error: $e\n$st');
      _status = UiStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> onCtaPressed(String cardId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _submitting = true;
    notifyListeners();

    try {
      await _repo.start(uid, cardId); 
      _progress = await _repo.getProgress(uid); 
    } catch (e, st) {
      debugPrint('Training start error: $e\n$st');
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  List<TrainingProgress> get pendingCertificates =>
      _progress.where((p) => p.percent < 100).toList();

  List<TrainingProgress> get completedCertificates =>
      _progress.where((p) => p.percent == 100).toList();
}