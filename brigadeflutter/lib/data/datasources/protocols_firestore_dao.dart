import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/protocol_model.dart';

class ProtocolsFirestoreDao {
  ProtocolsFirestoreDao({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore firestore;

  Stream<List<ProtocolModel>> watchProtocols() {
    final Query<Map<String, dynamic>> col = firestore.collection('protocols-and-manuals').orderBy('lastUpdate', descending: true);
    return col.snapshots().map((QuerySnapshot<Map<String, dynamic>> qs) => qs.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) => ProtocolModel.fromDocument(d)).toList());
  }

  Future<List<ProtocolModel>> getProtocolsOnce() async {
    final QuerySnapshot<Map<String, dynamic>> qs = await firestore.collection('protocols-and-manuals').orderBy('lastUpdate', descending: true).get();
    return qs.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) => ProtocolModel.fromDocument(d)).toList();
  }
}
