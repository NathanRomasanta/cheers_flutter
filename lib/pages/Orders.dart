// ignore_for_file: use_build_context_synchronously

import 'package:cheers_flutter/design/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          'ingredients': selectedIngredients,
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Order Submitted'),
              content: const Text('Order Submitted to Admin!'),
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

        selectedIngredients.clear();
      } catch (error) {
        Fluttertoast.showToast(
            msg: error.toString(), gravity: ToastGravity.TOP);
      }
    }
  }

  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transactions",
                  style: CheersStyles.h1s,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: CheersStyles.buttonMain,
                      onPressed: () {
                        _submitOrder();
                      },
                      child: const Text("Submit Order")),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: CheersStyles.buttonMain,
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
                  const SizedBox(
                    height: 50,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                    itemCount: selectedIngredients.length,
                    itemBuilder: (context, index) {
                      var ingredient = selectedIngredients[index];
                      return ListTile(
                        title: Text('${ingredient['name']}'),
                        subtitle: ingredient['isLiquor']
                            ? TextField(
                                decoration: const InputDecoration(
                                    labelText: 'Quantity'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _updateQuantity(ingredient['id'],
                                      int.tryParse(value) ?? 0);
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ]),
          ]),
    ));
  }
}
