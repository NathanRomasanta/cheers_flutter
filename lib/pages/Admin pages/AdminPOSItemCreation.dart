import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class POSItemCreationScreen extends StatefulWidget {
  const POSItemCreationScreen({super.key});

  @override
  State<POSItemCreationScreen> createState() => _POSItemCreationScreenState();
}

class _POSItemCreationScreenState extends State<POSItemCreationScreen> {
  Map<String, int> selectedItems = {};
  Future<List<String>> fetchItemsFromFirestore() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('Items') // Collection containing items
        .get();

    // Map the data into a list of item names
    return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  void _showItemSelectionDialog() async {
    List<String> items = await fetchItemsFromFirestore();
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select an Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              children: items.map((item) {
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      // Initialize quantity for new item if not already in selectedItems
                      if (!selectedItems.containsKey(item)) {
                        selectedItems[item] = 1; // Default quantity is 1
                      }
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Increase or decrease the quantity of a selected item
  void _updateQuantity(String item, int change) {
    setState(() {
      if (selectedItems.containsKey(item)) {
        selectedItems[item] = (selectedItems[item]! + change)
            .clamp(1, 100); // Ensure quantity is between 1 and 100
      }
    });
  }

  // Push the new POS item to Firestore
  void _createNewPOSItem() async {
    // Create a new POS item with the selected ingredients and their quantities
    await FirebaseFirestore.instance.collection('Pos_Items').add({
      'name': itemNameController.text.trim(),
      'id': itemIDController.text.trim(),
      'price': itemPriceController.text.trim(),
      'ingredients': selectedItems.entries
          .map((e) => {'name': e.key, 'quantity': e.value})
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('POS item created successfully!'),
    ));

    // Clear the selected items for the next creation
    setState(() {
      selectedItems.clear();
    });
  }

  final itemNameController = TextEditingController();
  final itemPriceController = TextEditingController();
  final itemIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Item Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Name"),
                controller: itemNameController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Price"),
                controller: itemPriceController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "ID"),
                controller: itemIDController,
              ),
              const Text(
                'Selected Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (selectedItems.isEmpty)
                const Text('No ingredients selected.')
              else
                Column(
                  children: selectedItems.keys.map((item) {
                    return ListTile(
                      title: Text('$item (x${selectedItems[item]})'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _updateQuantity(item, -1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _updateQuantity(item, 1),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showItemSelectionDialog,
                child: const Text('Select Ingredient'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createNewPOSItem,
                child: const Text('Create New POS Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
