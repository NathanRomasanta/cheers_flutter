import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference Pos_Items =
      FirebaseFirestore.instance.collection('Pos_Items');

  final CollectionReference items =
      FirebaseFirestore.instance.collection('Items');

  final CollectionReference orders =
      FirebaseFirestore.instance.collection("Orders");

  Stream<QuerySnapshot> getPosItemsStream() {
    final posItemsStream = Pos_Items.snapshots();
    return posItemsStream;
  }

  Stream<QuerySnapshot> getItemsStream() {
    final itemsStream = items.snapshots();
    return itemsStream;
  }

  Stream<QuerySnapshot> getStock() {
    final stockStream = items.snapshots();
    return stockStream;
  }

  Stream<QuerySnapshot> getOrdersStream() {
    final ordersStream = orders.snapshots();
    return ordersStream;
  }

  Future<void> deleteItem(String docID) {
    return items.doc(docID).delete();
  }
}
