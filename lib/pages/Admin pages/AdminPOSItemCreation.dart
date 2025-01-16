// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class POSItemCreationScreen extends StatefulWidget {
  const POSItemCreationScreen({super.key});

  @override
  State<POSItemCreationScreen> createState() => _POSItemCreationScreenState();
}

class _POSItemCreationScreenState extends State<POSItemCreationScreen> {
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
  void _updateOunces(String id, String ounces) {
    setState(() {
      selectedIngredients = selectedIngredients.map((ingredient) {
        if (ingredient['id'] == id) {
          ingredient['ounces'] = ounces;
        }
        return ingredient;
      }).toList();
    });
  }

  // Submit selected ingredients to Firestore
  void _submitOrder() async {
    try {
      await _firestore.collection('Pos_Items').add({
        'name': name,
        'price': price,
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
      appBar: AppBar(
        title: const Text('Select Ingredients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Drink Name'),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  price = value;
                });
              },
            ),
            const SizedBox(height: 20),
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
                          title: Text(
                              '${ingredient['name']} - \$${ingredient['price']}'),
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
              child: const Text('Select Ingredient'),
            ),
            const SizedBox(height: 20),
            const Text('Selected Ingredients:'),
            Expanded(
              child: ListView.builder(
                itemCount: selectedIngredients.length,
                itemBuilder: (context, index) {
                  var ingredient = selectedIngredients[index];
                  return ListTile(
                    title: Text(
                        '${ingredient['name']} - \$${ingredient['price']}'),
                    subtitle: ingredient['isLiquor']
                        ? TextField(
                            decoration:
                                const InputDecoration(labelText: 'Ounces'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _updateOunces(ingredient['id'], value);
                            },
                          )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOrder,
              child: const Text('Submit Order'),
            ),
          ],
        ),
      ),
    );
  }
}
