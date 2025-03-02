import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/Orders.dart';
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

    // ignore: avoid_print
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F1EA),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Stock",
                  style: CheersStyles.h1s,
                ),
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
                      children: [
                        Text("Item Name/ID"),
                        SizedBox(width: 145),
                        Text("Stock Count"),
                        SizedBox(width: 120),
                        Text("Ounces/Bottle"),
                        SizedBox(width: 90),
                        Text("Status"),
                        Spacer(),
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
                                  String itemID = data['id'];
                                  int itemQuantity =
                                      data['runningCount'].truncate();
                                  String ouncesPerBottle =
                                      data['ouncesPerBottle'].toString();

                                  bool isLiquor = data['isLiquor'];

                                  String ouncesLeft =
                                      ((data['ouncesPerBottle'] *
                                                  data['runningCount']) %
                                              data['ouncesPerBottle'])
                                          .round()
                                          .toString();

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color.fromARGB(255, 228, 228,
                                                228), // Border color
                                            width: 1.0, // Border width
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(itemName),
                                                Text(
                                                  itemID,
                                                  style: const TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 120),
                                          SizedBox(
                                            width: 200,
                                            child: Center(
                                              child: Text(isLiquor
                                                  ? "${itemQuantity.toString()} bottles and $ouncesLeft ounces left"
                                                  : itemQuantity.toString()),
                                            ),
                                          ),
                                          const SizedBox(width: 75),
                                          SizedBox(
                                              width: 50,
                                              child: Center(
                                                child: Text(isLiquor
                                                    ? ouncesPerBottle
                                                    : "N/A"),
                                              )),
                                          const SizedBox(width: 30),
                                          SizedBox(
                                            width: 200,
                                            child: Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: (itemQuantity < 5
                                                      ? Colors.red
                                                      : Colors.green),
                                                  // Default green if not liquor
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  (itemQuantity < 5
                                                      ? 'Low Stock'
                                                      : 'In Stock'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Stock Details',
                                                        style: CheersStyles
                                                            .alertDialogHeader,
                                                      ),
                                                      content: SizedBox(
                                                          height: 300,
                                                          width: 250,
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        itemName),
                                                                    const Text(
                                                                      "Item Name",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        itemID),
                                                                    const Text(
                                                                      "Item ID",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(isLiquor
                                                                        ? "${itemQuantity.toString()} bottles and $ouncesLeft ounces left"
                                                                        : 'In Stock'),
                                                                    const Text(
                                                                      "Item Quantity",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        ouncesPerBottle),
                                                                    const Text(
                                                                      "Ounces/bottle",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 20),
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: isLiquor
                                                                        ? (itemQuantity <
                                                                                5
                                                                            ? Colors
                                                                                .red
                                                                            : Colors
                                                                                .green)
                                                                        : Colors
                                                                            .green, // Default green if not liquor
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child: Text(
                                                                    isLiquor
                                                                        ? (itemQuantity <
                                                                                5
                                                                            ? 'Low Stock'
                                                                            : 'In Stock')
                                                                        : 'In Stock',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ])),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            // Close the dialog
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            'Okay',
                                                            style: CheersStyles
                                                                .alertTextButton,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.menu))
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
