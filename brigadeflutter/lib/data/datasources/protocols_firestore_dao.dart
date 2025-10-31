import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/protocol_model.dart';

class ProtocolsFirestoreDao {
  final FirebaseFirestore firestore;
  ProtocolsFirestoreDao({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ProtocolModel>> watchProtocols() {
    final col = firestore.collection('protocols-and-manuals').orderBy('lastUpdate', descending: true);
    return col.snapshots().map((qs) => qs.docs.map((d) => ProtocolModel.fromDocument(d)).toList());
  }

  Future<List<ProtocolModel>> getProtocolsOnce() async {
    final qs = await firestore.collection('protocols-and-manuals').orderBy('lastUpdate', descending: true).get();
    return qs.docs.map((d) => ProtocolModel.fromDocument(d)).toList();
  }
}
