import '../../../data/repositories/protocol_repository.dart';

class MarkProtocolAsRead {
  final ProtocolRepository repository;
  MarkProtocolAsRead({required this.repository});

  Future<void> call(String name, String version) async {
    await repository.markAsRead(name, version);
  }
}
