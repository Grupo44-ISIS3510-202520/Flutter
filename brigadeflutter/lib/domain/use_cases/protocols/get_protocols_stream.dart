import 'package:meta/meta.dart';
import '../../../data/models/protocol_model.dart';
import '../../../data/repositories/protocol_repository.dart';

class GetProtocolsStream {
  final ProtocolRepository repository;
  GetProtocolsStream({required this.repository});

  Stream<List<ProtocolModel>> call() {
    return repository.getProtocolsStream();
  }
}
