import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/protocol_model.dart';
import '../../domain/use_cases/protocols/get_protocols_stream.dart';
import '../../domain/use_cases/protocols/is_protocol_new.dart';
import '../../domain/use_cases/protocols/mark_protocol_as_read.dart';

class ProtocolsViewModel extends ChangeNotifier {
  final GetProtocolsStream getProtocolsStream;
  final IsProtocolNew isProtocolNew;
  final MarkProtocolAsRead markProtocolAsRead;

  List<ProtocolModel> _all = [];
  String _searchQuery = '';
  bool isLoading = true;

  StreamSubscription<List<ProtocolModel>>? _subscription;

  ProtocolsViewModel({
    required this.getProtocolsStream,
    required this.isProtocolNew,
    required this.markProtocolAsRead,
  });

  void init() {
    _subscription?.cancel();
    isLoading = true;
    notifyListeners();

    _subscription = getProtocolsStream().listen((list) {
      _all = list;
      isLoading = false;
      notifyListeners();
    }, onError: (err) {

      isLoading = false;
      notifyListeners();
    });
  }

  void disposeViewModel() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  List<ProtocolModel> get filtered {
    if (_searchQuery.isEmpty) return _all;
    final q = _searchQuery.toLowerCase();
    return _all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  void onSearchChanged(String q) {
    _searchQuery = q.trim();
    notifyListeners();
  }

  Future<void> markAsRead(String name, String version) async {
    await markProtocolAsRead(name, version);
    notifyListeners();
  }

  Future<bool> checkIsNew(String name, String version) async {
    return await isProtocolNew(name, version);
  }
}
