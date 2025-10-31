import '../../../data/repositories/protocol_repository.dart';

class IsProtocolNew {
  final ProtocolRepository repository;
  IsProtocolNew({required this.repository});

  Future<bool> call(String name, String version) async {
    return await repository.isNew(name, version);
  }
}
