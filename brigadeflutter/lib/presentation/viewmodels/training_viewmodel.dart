import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../data/entities/training_card.dart';
import '../../data/entities/training_progress.dart';
import '../../data/repositories/training_repository.dart';



enum UiStatus { initial, loading, ready, error }

class TrainingViewModel extends ChangeNotifier {
  final TrainingRepository _repo;
  final FirebaseAnalytics _analytics;

  TrainingViewModel({
    required TrainingRepository repo,
    FirebaseAnalytics? analytics,
  })  : _repo = repo,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  UiStatus _status = UiStatus.initial;
  List<TrainingCard> _cards = [];
  List<TrainingProgress> _progress = [];
  bool _submitting = false;

  UiStatus get status => _status;
  List<TrainingCard> get cards => _cards;
  List<TrainingProgress> get progress => _progress;
  bool get submitting => _submitting;

  /// Carga inicial de datos: tarjetas y progreso.
  Future<void> load() async {
    _status = UiStatus.loading;
    notifyListeners();

    try {
      _cards = await _repo.getCards();
      _progress = await _repo.getProgress();

      final pending = _progress.where((p) => p.percent < 100).toList();
      if (pending.isNotEmpty) {
        await _analytics.logEvent(
          name: 'certificate_pending_viewed',
          parameters: {
            'pending_count': pending.length,
            'pending_labels': pending.map((p) => p.label).join(", "),
          },
        );
      }

      _status = UiStatus.ready;
    } catch (e, st) {
      debugPrint("Error en TrainingViewModel.load(): $e\n$st");
      _status = UiStatus.error;
    }

    notifyListeners();
  }

  Future<void> onCtaPressed(String cardId) async {
    _submitting = true;
    notifyListeners();

    try {
      await _repo.start(cardId);
      _progress = await _repo.getProgress();

      for (final p in _progress) {
        if (p.percent == 100) {
          await _analytics.logEvent(
            name: 'certificate_completed',
            parameters: {
              'certificate_id': cardId,
              'certificate_label': p.label,
            },
          );
        }
      }
    } catch (e, st) {
      debugPrint("Error en TrainingViewModel.onCtaPressed(): $e\n$st");
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Certificados pendientes (<100%)
  List<TrainingProgress> get pendingCertificates =>
      _progress.where((p) => p.percent < 100).toList();

  /// Certificados completados (100%)
  List<TrainingProgress> get completedCertificates =>
      _progress.where((p) => p.percent == 100).toList();
}
