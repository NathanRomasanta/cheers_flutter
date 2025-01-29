import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/Stock.dart';
import 'package:cheers_flutter/services/FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseService firebaseService = FirebaseService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  String name = '';
  String price = '';

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  // Fetch ingredients from Firestore
  void _fetchIngredients() async {
    QuerySnapshot querySnapshot = await _firestore.collection('Items').get();
    setState(() {
      ingredients = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'isLiquor': doc['isLiquor'],
          'quantity': doc['quantity'],
          'ouncesPerBottle': doc['ouncesPerBottle']
        };
      }).toList();
    });
  }

  // Handle ingredient selection
  void _selectIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      selectedIngredients.add(ingredient);
    });

    print(selectedIngredients);
  }

  // Handle ounces input for liquor ingredients
  void _updateQuantity(String id, int quantity) {
    setState(() {
      selectedIngredients = selectedIngredients.map((ingredient) {
        if (ingredient['id'] == id) {
          ingredient['quantity'] = quantity;
        }
        return ingredient;
      }).toList();
    });
  }

  // Submit selected ingredients to Firestore
  void _submitOrder() async {
    try {
      await _firestore.collection('Orders').add({
        'baristaUID': user.email,
        'ingredients': selectedIngredients,
      });
      Fluttertoast.showToast(
          msg: 'POS Item Created', gravity: ToastGravity.TOP);
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString(), gravity: ToastGravity.TOP);
    }
  }

  void showTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            height: MediaQuery.of(context).size.height *
                0.8, // 60% of screen height
            padding: EdgeInsets.all(16),
            child: Column(children: [
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    _submitOrder();
                  },
                  child: const Text("Clear Form")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close")),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Select Ingredients'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: ingredients.map((ingredient) {
                            return ListTile(
                              title: Text('${ingredient['name']}'),
                              onTap: () => _selectIngredient(ingredient),
                            );
                          }).toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Order more stock")),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedIngredients.length,
                  itemBuilder: (context, index) {
                    var ingredient = selectedIngredients[index];
                    return ListTile(
                      title: Text('${ingredient['name']}'),
                      subtitle: ingredient['isLiquor']
                          ? TextField(
                              decoration:
                                  const InputDecoration(labelText: 'quantity'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _updateQuantity(
                                    ingredient['id'], int.parse(value));
                              },
                            )
                          : null,
                    );
                  },
                ),
              ),
            ]),
          ),
        );
      },
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Stock",
                  style: CheersStyles.h1s,
                ),
                ElevatedButton(
                  onPressed: () {
                    showTableDialog(context);
                  },
                  style: CheersStyles.buttonMain,
                  child: const Text("Order"),
                )
              ],
            ),
            const SizedBox(height: 20),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Item Name"),
                        Text("Quantity"),
                        Text("Item ID"),
                        Text("Ounces/Bottle"),
                        Text("Action"),
                      ],
                    ),
                    const Divider(),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Accounts')
                            .doc(user.email)
                            .collection('stock')
                            .snapshots(),
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
                                      data['runningCount'].toString();
                                  String ouncesPerBottle =
                                      data['ouncesPerBottle'].toString();
                                  String itemPrice =
                                      data['id'].toString() ?? "";

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
                                          Expanded(
                                              child: Text(ouncesPerBottle)),
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
                            return const Text("No Stock");
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
