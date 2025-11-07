import '../../../data/models/protocol_model.dart';
import '../../../data/repositories/protocol_repository.dart';

class GetProtocolsStream {
  GetProtocolsStream({required this.repository});
  final ProtocolRepository repository;

  Stream<List<ProtocolModel>> call() {
    return repository.getProtocolsStream();
  }
}
