import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order submitted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Ingredients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Drink Name'),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  price = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Select Ingredients'),
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
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Select Ingredient'),
            ),
            SizedBox(height: 20),
            Text('Selected Ingredients:'),
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
                            decoration: InputDecoration(labelText: 'Ounces'),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOrder,
              child: Text('Submit Order'),
            ),
          ],
        ),
      ),
    );
  }
}
