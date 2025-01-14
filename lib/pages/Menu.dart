import 'package:cheers_flutter/services/FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class POSPage extends StatefulWidget {
  @override
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  List<Map<String, dynamic>> checkout = [];

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Pos_Items').get();
    return snapshot.docs
        .map((doc) => {
              'name': doc['name'],
              'price': doc['price'],
            })
        .toList();
  }

  void addToCheckout(Map<String, dynamic> item) {
    setState(() {
      final existingItem =
          checkout.firstWhere((i) => i['id'] == item['id'], orElse: () => {});
      if (existingItem.isNotEmpty) {
        existingItem['quantity'] += 1;
      } else {
        checkout.add({...item, 'quantity': 1});
      }
    });
  }

  void removeFromCheckout(Map<String, dynamic> item) {
    setState(() {
      final existingItem =
          checkout.firstWhere((i) => i['id'] == item['id'], orElse: () => {});
      if (existingItem.isNotEmpty && existingItem['quantity'] > 1) {
        existingItem['quantity'] -= 1;
      } else {
        checkout.removeWhere((i) => i['id'] == item['id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS System'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () => setState(() => checkout.clear()),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data!;
          return Row(
            children: [
              // Items List
              Expanded(
                flex: 3,
                child: GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      color: Colors.orange[100],
                      child: InkWell(
                        onTap: () => addToCheckout(item),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['name'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('\$${item['price']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Checkout Section
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: checkout.length,
                        itemBuilder: (context, index) {
                          final item = checkout[index];
                          return ListTile(
                            title: Text(item['name']),
                            subtitle: Text(
                                'Quantity: ${item['quantity']} - \$${(int.parse(item['price']) * item['quantity'])}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () => removeFromCheckout(item),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () => addToCheckout(item),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Payment Process
                        },
                        child: Text('Send to Payment Pad'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
