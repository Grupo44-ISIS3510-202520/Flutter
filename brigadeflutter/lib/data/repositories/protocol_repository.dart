import '../models/protocol_model.dart';

abstract class ProtocolRepository {
  Stream<List<ProtocolModel>> getProtocolsStream();
  Future<void> markAsRead(String name, String version);
  Future<bool> isNew(String name, String version);
}
