// ignore_for_file: use_build_context_synchronously

import 'package:cheers_flutter/design/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StockOrder extends StatefulWidget {
  const StockOrder({super.key});

  @override
  State<StockOrder> createState() => _StockOrderState();
}

class _StockOrderState extends State<StockOrder> {
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
  }

  void deleteItem(int index) {
    setState(() {
      selectedIngredients.removeAt(index);
    });
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
    if (selectedIngredients.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Order is Empty'),
            content: const Text('Order cannot be empty!'),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      try {
        await _firestore.collection('Orders').add({
          'baristaUID': user.email,
          'status': "Pending",
          'ingredients': selectedIngredients,
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Order Submitted',
                style: CheersStyles.alertDialogHeader,
              ),
              content: const Text('Order Submitted to Admin!'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: CheersStyles.alertTextButton,
                  ),
                ),
              ],
            );
          },
        );

        setState(() {
          selectedIngredients.clear();
        });
      } catch (error) {
        Fluttertoast.showToast(
            msg: error.toString(), gravity: ToastGravity.TOP);

        AlertDialog(
          title: const Text('Order Error'),
          content: const Text('Order not submitted'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      }
    }
  }

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 5);
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order Stock",
                  style: CheersStyles.h1s,
                ),
              ],
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text(
                        "Current Barista:",
                        style: CheersStyles.h7s,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(user.email.toString(), style: CheersStyles.h7s),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          style: CheersStyles.buttonMain,
                          onPressed: () {
                            _submitOrder();
                          },
                          child: const Text("Submit Order")),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: const Color(0xffF8F8F8),
                        ),
                        child: SizedBox(
                          height: 500,
                          width: 400,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Order Slip',
                                  style: CheersStyles.h3ss,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 400,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    // Prevents nested scrolling issues
                                    itemCount: selectedIngredients.length,
                                    itemBuilder: (context, index) {
                                      var ingredient =
                                          selectedIngredients[index];
                                      return Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Color.fromARGB(255, 221,
                                                  221, 221), // Underline color
                                              width: 1.0, // Underline thickness
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Row(
                                            children: [
                                              Text('${ingredient['name']}'),
                                              const SizedBox(width: 15),
                                              SizedBox(
                                                  width: 100,
                                                  child: TextField(
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText:
                                                                'Quantity'),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    onChanged: (value) {
                                                      _updateQuantity(
                                                          ingredient['id'],
                                                          int.tryParse(value) ??
                                                              0);
                                                    },
                                                  ))
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              deleteItem(index);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: const Color(0xffF8F8F8),
                        ),
                        child: SizedBox(
                          height: 500,
                          width: 700,
                          child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Inventory Options',
                                    style: CheersStyles.h3ss,
                                  ),
                                  Expanded(
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(8),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio:
                                            MediaQuery.of(context).size.width <
                                                    600
                                                ? 2.0
                                                : 1.8, // Increase this value
                                      ),
                                      itemCount: ingredients.length,
                                      itemBuilder: (context, index) {
                                        final item = ingredients[index];
                                        return Card(
                                          color: const Color(0xffF19A6F),
                                          child: InkWell(
                                            onTap: () =>
                                                _selectIngredient(item),
                                            child: ListTile(
                                              title: Text(
                                                item['name'],
                                                style: const TextStyle(
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ]),
          ]),
    ));
  }
}
