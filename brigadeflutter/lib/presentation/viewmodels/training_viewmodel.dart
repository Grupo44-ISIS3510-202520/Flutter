import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../../data/entities/training_card.dart';
import '../../data/entities/training_progress.dart';
import '../../data/repositories/training_repository.dart';

enum UiStatus { initial, loading, ready, error }

class TrainingViewModel extends ChangeNotifier {
  TrainingViewModel({required TrainingRepository repo}) : _repo = repo;
  final TrainingRepository _repo;

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

    final box = await Hive.openBox('trainingsBox');

    try {
      final cachedCards = box.get('cards');
      final cachedProgress = box.get('progress');

      if (cachedCards != null && cachedProgress != null) {
        _cards = (cachedCards as List)
            .map(
              (c) => TrainingCard(
                id: c['id'] as String,
                title: c['title'] as String,
                subtitle: c['subtitle'] as String,
                imageUrl: c['imageUrl'] as String,
                cta: c['cta'] as String,
              ),
            )
            .toList();

        _progress = (cachedProgress as List)
            .map(
              (p) => TrainingProgress(
                id: p['id'] as String,
                label: p['label'] as String,
                percent: p['percent'] as int,
              ),
            )
            .toList();

        _status = UiStatus.ready;
        notifyListeners();
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _status = UiStatus.error;
        notifyListeners();
        return;
      }

      final cards = await _repo.getCards();
      final progress = await _repo.getProgress(uid);

      _cards = cards;
      _progress = progress;

      await box.put(
        'cards',
        cards
            .map(
              (c) => {
                'id': c.id,
                'title': c.title,
                'subtitle': c.subtitle,
                'imageUrl': c.imageUrl,
                'cta': c.cta,
              },
            )
            .toList(),
      );

      await box.put(
        'progress',
        progress
            .map((p) => {'id': p.id, 'label': p.label, 'percent': p.percent})
            .toList(),
      );

      await box.put('lastUpdated', DateTime.now().toIso8601String());

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

    final box = await Hive.openBox('trainingsBox');

    try {
      await _repo.start(uid, cardId);
      _progress = await _repo.getProgress(uid);

      await box.put(
        'progress',
        _progress
            .map((p) => {'id': p.id, 'label': p.label, 'percent': p.percent})
            .toList(),
      );
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
