import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/protocol.dart';

class ProtocolModel extends Protocol {
  ProtocolModel({
    required super.id,
    required super.name,
    required super.url,
    required super.version,
    super.lastUpdate,
  });

  factory ProtocolModel.fromDocument(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
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
