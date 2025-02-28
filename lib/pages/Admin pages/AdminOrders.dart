import 'package:cheers_flutter/services/FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class InventoryOrders extends StatefulWidget {
  const InventoryOrders({super.key});

  @override
  State<InventoryOrders> createState() => _InventoryOrdersState();
}

class _InventoryOrdersState extends State<InventoryOrders> {
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final FirebaseService firebaseService = FirebaseService();

  Future<void> fulfillOrder(
      String baristaEmail, List<dynamic> orderList, String orderDocID) async {
    try {
      // Access the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get the document in the "Accounts" collection for the barista email
      DocumentReference baristaDoc =
          firestore.collection('Accounts').doc(baristaEmail);

      CollectionReference stockCollection = baristaDoc.collection('stock');

      CollectionReference cashoutCollection = firestore
          .collection('Cashout')
          .doc(baristaEmail)
          .collection("Date")
          .doc(formattedDate)
          .collection("Requests");

      // Process each ingredient in the order list
      for (var ingredient in orderList) {
        String ingredientId = ingredient['id'] ??
            DateTime.now().toString(); // Unique ID if missing
        String ingredientName = ingredient['name'] ?? 'Unknown';
        int ingredientQuantity = ingredient['quantity'] ?? 1;
        bool isLiquor = ingredient['isLiquor'] ?? false;
        int ouncesPerBottle = ingredient['ouncesPerBottle'];

        // Check if the ingredient already exists in the stock collection
        DocumentSnapshot existingIngredient =
            await stockCollection.doc(ingredientId).get();

        if (existingIngredient.exists) {
          // If the document exists, update the quantity
          Map<String, dynamic> existingData =
              existingIngredient.data() as Map<String, dynamic>;
          int existingQuantity = existingData['quantity'] ?? 0;

          // Update only the `quantity`, and increment `running count` for liquors
          await stockCollection.doc(ingredientId).update({
            'quantity': existingQuantity + ingredientQuantity,
            if (isLiquor)
              'running count':
                  (existingData['running count'] ?? 0) + ingredientQuantity,
          });
        } else {
          // If the document does not exist, create a new document
          if (isLiquor) {
            stockCollection.doc(ingredientId).set({
              'id': ingredientId,
              'name': ingredientName,
              'quantity': ingredientQuantity,
              'runningCount': ingredientQuantity,
              'ouncesPerBottle': ouncesPerBottle,
            });
          } else {
            stockCollection.doc(ingredientId).set({
              'id': ingredientId,
              'name': ingredientName,
              'quantity': ingredientQuantity,
              'runningCount': 1,
              'ouncesPerBottle': 1,
            });

            cashoutCollection.doc(ingredientId).set({
              'id': ingredientId,
              'name': ingredientName,
              'quantity': ingredientQuantity,
              'runningCount': 1,
              'ouncesPerBottle': 1,
            });
          }
        }
      }

      cashoutCollection.doc().set({
        'id': baristaEmail,
        'items': orderList,
      });

      Fluttertoast.showToast(msg: "Order fulfilled successfully!");

      await firestore.collection('Orders').doc(orderDocID).delete();
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to fulfill order: $e");
    }
  }

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
                      stream: firebaseService.getOrdersStream(),
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
                              String itemName = data['baristaUID'];

                              List<dynamic> orderList =
                                  data['ingredients']; // List of dictionaries
                              int itemQuantity = orderList.length;
                              String itemPrice = data['id'].toString();

                              return Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(
                                          255, 228, 228, 228), // Border color
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
                                      Expanded(
                                          child: Text(itemQuantity.toString())),
                                      Expanded(child: Text(itemPrice)),
                                      IconButton(
                                        onPressed: () {
                                          firebaseService.deleteItem(docID);
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Show the dialog box
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Order Details"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Barista: $itemName"),
                                              const SizedBox(height: 10),
                                              const Text("Ingredients:"),
                                              const SizedBox(height: 5),
                                              ...orderList.map((ingredient) {
                                                // Extract name and substitute default value for quantity if missing
                                                String ingredientName =
                                                    ingredient['name'] ??
                                                        "Unknown";
                                                int ingredientQuantity =
                                                    ingredient['quantity'] ?? 1;
                                                return Text(
                                                    "- $ingredientName (x$ingredientQuantity)");
                                              }).toList(),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                fulfillOrder(
                                                    itemName, orderList, docID);
                                                Navigator.of(context).pop();
                                              },
                                              child:
                                                  const Text("Fulfill Order"),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        } else {
                          return const Text("No Notes");
                        }
                      },
                    )
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
