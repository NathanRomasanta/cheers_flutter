// ignore: file_names
import 'package:cheers_flutter/design/design.dart';
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
  double total = 0;
  String selectedOption = 'Cocktails';

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
  void _updateOunces(String id, int ounces) {
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
  void _addNewItem() async {
    if (selectedOption == "Cocktails") {
      try {
        await _firestore
            .collection('Pos_Items')
            .doc('cocktails')
            .collection('cocktail_items')
            .add({
          'name': name,
          'price': int.parse(price),
          'ingredients': selectedIngredients,
        });
        Fluttertoast.showToast(
            msg: 'POS Item Created', gravity: ToastGravity.TOP);
      } catch (error) {
        Fluttertoast.showToast(
            msg: error.toString(), gravity: ToastGravity.TOP);
      }
    } else if (selectedOption == "Wines") {
      try {
        await _firestore
            .collection('Pos_Items')
            .doc('wines')
            .collection('wine_items')
            .add({
          'name': name,
          'price': int.parse(price),
          'ingredients': selectedIngredients,
        });
        Fluttertoast.showToast(
            msg: 'POS Item Created', gravity: ToastGravity.TOP);
      } catch (error) {
        Fluttertoast.showToast(
            msg: error.toString(), gravity: ToastGravity.TOP);
      }
    } else if (selectedOption == "Beers") {
      try {
        await _firestore
            .collection('Pos_Items')
            .doc('beers')
            .collection('beer_items')
            .add({
          'name': name,
          'price': int.parse(price),
          'ingredients': selectedIngredients,
        });
        Fluttertoast.showToast(
            msg: 'POS Item Created', gravity: ToastGravity.TOP);
      } catch (error) {
        Fluttertoast.showToast(
            msg: error.toString(), gravity: ToastGravity.TOP);
      }
    } else if (selectedOption == "Food") {
      try {
        await _firestore
            .collection('Pos_Items')
            .doc('food')
            .collection('food_items')
            .add({
          'name': name,
          'price': int.parse(price),
          'ingredients': selectedIngredients,
        });
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('POS Item Created!'),
              content: const Text('POS Item successfully created!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Color(0xffFF6E1F)),
                  ),
                ),
              ],
            );
          },
        );

        setState(() {
          selectedIngredients.clear();
          name = '';
          price = '';
        });
      } catch (error) {
        Fluttertoast.showToast(
            msg: error.toString(), gravity: ToastGravity.TOP);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default selected option
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("POS Item Creation", style: CheersStyles.h1s),
              const SizedBox(height: 15),
              const Text(
                "Item Name",
                style: CheersStyles.inputBoxLabels,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 500,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Drink Name'),
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
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
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: ingredients.map((ingredient) {
                            return ListTile(
                              title: Text(
                                  '${ingredient['name']} - \$${ingredient['price']}'),
                              onTap: () => _selectIngredient(ingredient),
                            );
                          }).toList(),
                        ),
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
              DropdownButton<String>(
                value: selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue!;
                  });
                },
                items: <String>['Cocktails', 'Wines', 'Beers', 'Food']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const Text('Selected Ingredients:'),
              SizedBox(
                height: 200, // Adjust height as needed
                child: ListView.builder(
                  shrinkWrap: true,
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
                                _updateOunces(
                                    ingredient['id'], int.parse(value));
                              },
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addNewItem,
                child: const Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
