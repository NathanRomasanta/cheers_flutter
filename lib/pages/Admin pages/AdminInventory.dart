import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cheers_flutter/services/FirestoreService.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Row(
            children: [
              Expanded(child: Text("Name")),
              Expanded(child: Text("Quantity")),
              Expanded(child: Text("Price")),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
              stream: firebaseService.getItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List itemList = snapshot.data!.docs;

                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: itemList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = itemList[index];
                        String docID = document.id;

                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String itemName = data['name'];
                        String itemQuantity = data['quantity'].toString();
                        String itemPrice = data['price'].toString();

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16), // Curved edges
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16), // Curved edges
                            ),
                            contentPadding: const EdgeInsets.all(20),
                            tileColor: Colors.white,
                            title: Row(
                              children: [
                                Expanded(child: Text(itemName)),
                                Expanded(child: Text(itemQuantity)),
                                Expanded(child: Text(itemPrice)),
                                IconButton(
                                    onPressed: () {
                                      firebaseService.deleteItem(docID);
                                    },
                                    icon: const Icon(Icons.delete))
                              ],
                            ),
                          ),
                        );
                      });
                } else {
                  return const Text("No Notes");
                }
              }),
        ],
      ),
    );
  }
}
