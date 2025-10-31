import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/protocol.dart';

class ProtocolModel extends Protocol {
  ProtocolModel({
    required String id,
    required String name,
    required String url,
    required String version,
    DateTime? lastUpdate,
  }) : super(id: id, name: name, url: url, version: version, lastUpdate: lastUpdate);

  factory ProtocolModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['lastUpdate'];
    DateTime? lastUpdate;
    if (ts is Timestamp) {
      lastUpdate = ts.toDate();
    } else if (ts is String) {
      lastUpdate = DateTime.tryParse(ts);
    }

    return ProtocolModel(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      url: (data['url'] ?? '').toString(),
      version: (data['version'] ?? '').toString(),
      lastUpdate: lastUpdate,
    );
  }
}
