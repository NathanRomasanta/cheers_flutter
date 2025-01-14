import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference Pos_Items =
      FirebaseFirestore.instance.collection('Pos_Items');

  final CollectionReference items =
      FirebaseFirestore.instance.collection('Items');

  Stream<QuerySnapshot> getPosItemsStream() {
    final posItemsStream = Pos_Items.snapshots();
    return posItemsStream;
  }

  Stream<QuerySnapshot> getItemsStream() {
    final itemsStream = items.snapshots();
    return itemsStream;
  }

  Future<void> deleteItem(String docID) {
    return items.doc(docID).delete();
  }
}
