import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/protocols_firestore_dao.dart';
import '../models/protocol_model.dart';
import '../repositories/protocol_repository.dart';

class ProtocolRepositoryImpl implements ProtocolRepository {
  final ProtocolsFirestoreDao dao;
  final SharedPreferences prefs;

  ProtocolRepositoryImpl({
    required this.dao,
    required this.prefs,
  });

  @override
  Stream<List<ProtocolModel>> getProtocolsStream() {
    return dao.watchProtocols();
  }

  String _keyFor(String name) => 'last_seen_$name';

  @override
  Future<void> markAsRead(String name, String version) async {
    await prefs.setString(_keyFor(name), version);
  }

  @override
  Future<bool> isNew(String name, String version) async {
    final seen = prefs.getString(_keyFor(name));
    return seen == null || seen != version;
  }
}
