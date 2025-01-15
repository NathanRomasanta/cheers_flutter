import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
              'id': doc.id,
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data!;
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  "Order",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Product Sans'),
                ),
              ),
              SizedBox(
                height: 600,
                width: 700,
                child: Row(
                  children: [
                    // Items List
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Color(0xffF8F8F8)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Card(
                                  color: const Color(0xffF19A6F),
                                  child: InkWell(
                                    onTap: () => addToCheckout(item),
                                    child: Padding(
                                      padding: const EdgeInsets.all(13.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'],
                                              style: const TextStyle(
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          const SizedBox(height: 8),
                                          Text(
                                            '\$${item['price']}',
                                            style: const TextStyle(
                                                fontFamily: 'Product Sans',
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
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
                                        onPressed: () =>
                                            removeFromCheckout(item),
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
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle Payment Process
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(
                                    0xffFF6E1F), // Button background color
                                foregroundColor: Colors.white, // Text color
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(30), // Curved edges
                                ),
                              ),
                              child: const Text(
                                'Send to Payment Pad',
                                style: TextStyle(fontFamily: 'Product Sans'),
                              ),
                            ),
                          ),
                        ],
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
