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
      backgroundColor: const Color(0xffFFFDFA),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Items",
              style: TextStyle(fontSize: 30),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: const Color(0xffF8F8F8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text("Item Name"),
                        Text("Stock"),
                        Text("Price")
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
                                  String itemQuantity =
                                      data['quantity'].toString();
                                  String itemPrice = data['id'].toString();

                                  return Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(255, 228, 228,
                                              228), // Border color
                                          width: 1.0, // Border width
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(5),
                                      tileColor: Colors.white,
                                      title: Row(
                                        children: [
                                          Expanded(child: Text(itemName)),
                                          Expanded(child: Text(itemQuantity)),
                                          Expanded(child: Text(itemPrice)),
                                          IconButton(
                                              onPressed: () {
                                                firebaseService
                                                    .deleteItem(docID);
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
