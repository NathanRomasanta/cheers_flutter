import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BarStock extends StatefulWidget {
  const BarStock({super.key});

  @override
  State<BarStock> createState() => _BarStockState();
}

class _BarStockState extends State<BarStock> {
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
          'quantity': doc['quantity']
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

  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
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
                          _updateQuantity(ingredient['id'], int.parse(value));
                        },
                      )
                    : null,
              );
            },
          ),
        ),
      ]),
    );
  }
}
