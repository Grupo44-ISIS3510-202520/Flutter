import '../../../data/repositories/protocol_repository.dart';

class IsProtocolNew {
  IsProtocolNew({required this.repository});
  final ProtocolRepository repository;

  Future<bool> call(String name, String version) async {
    return await repository.isNew(name, version);
  }
}
