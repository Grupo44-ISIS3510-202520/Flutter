import '../../../data/repositories/protocol_repository.dart';

class MarkProtocolAsRead {
  MarkProtocolAsRead({required this.repository});
  final ProtocolRepository repository;

  Future<void> call(String name, String version) async {
    await repository.markAsRead(name, version);
  }
}
