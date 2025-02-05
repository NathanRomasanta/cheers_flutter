// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/Payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  List<Map<String, dynamic>> checkout = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  String title = "";
  late Future<List<dynamic>> itemsFuture;

  @override
  void initState() {
    super.initState();
    itemsFuture = fetchCocktails();
    title = "Cocktails"; // Initially fetch items for the default category
  } // Future to store data

  double total = 0;
  Future<List<Map<String, dynamic>>> fetchItems() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Pos_Items').get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'price': doc['price'],
              'ingredients': doc['ingredients'],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchCocktails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('cocktails')
        .collection('cocktail_items')
        .get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'price': doc['price'],
              'ingredients': doc['ingredients'],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchWines() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('wines')
        .collection('wines_items')
        .get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'price': doc['price'],
              'ingredients': doc['ingredients'],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchStock() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Accounts')
        .doc(user.email)
        .collection('stock')
        .get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'] ?? '',
              'price': doc['price'],
              'ingredients': doc['ingredients'],
            })
        .toList();
  }

  void addToCheckout(Map<String, dynamic> item) {
    //final DocumentReference pos_Items = FirebaseFirestore.instance.collection('Accounts').doc(user.email).collection("stock");

    setState(() {
      final existingItem =
          checkout.firstWhere((i) => i['id'] == item['id'], orElse: () => {});
      if (existingItem.isNotEmpty) {
        existingItem['quantity'] += 1;

        total = total + (existingItem['price']);
      } else {
        checkout.add({...item, 'quantity': 1});
        total = total + (item['price']);
      }
    });
  }

  void testFunction() async {
    // Step 1: Reference Firestore stock collection
    CollectionReference<Map<String, dynamic>> stockCollection =
        FirebaseFirestore.instance
            .collection('Accounts')
            .doc(user.email)
            .collection('stock');

    // Step 2: Fetch data from the stock collection
    final snapshot = await stockCollection.get(); // Retrieve stock data
    final List<Map<String, dynamic>> stockList = snapshot.docs.map((doc) {
      return doc.data(); // Convert each document's data to a Map
    }).toList();

    // Step 3: Iterate over the checkout list and check stock
    bool isStockSufficient = true; // To track if stock is enough for all drinks

    List<Map<String, dynamic>> neededIngredients = [];

    print(checkout);

    for (var drink in checkout) {
      List ingredients = drink['ingredients'];

      int quantity = drink['quantity'];
      for (var ingredient in ingredients) {
        String ingredientName = ingredient['id'];
        bool isLiquor = ingredient['isLiquor'];
        int ounces = ingredient['ounces'] ?? 0;

        // Check if the ingredient is already in the neededIngredients list
        var existingIngredient = neededIngredients.firstWhere(
          (item) => item['id'] == ingredientName,
          orElse: () => {},
        );

        if (existingIngredient.isNotEmpty) {
          // If found, add ounces only if isLiquor is true
          if (isLiquor) {
            existingIngredient['ounces'] += ounces;
          }
        } else {
          neededIngredients.add({
            'id': ingredientName,
            'isLiquor': isLiquor,
            'ounces': isLiquor ? ounces * quantity : 0,
          });
        }
      }

      print(stockList);
    }

    for (var items in neededIngredients) {
      print(items);
    }

    for (var needed in neededIngredients) {
      double neededOunces =
          double.parse(needed['ounces'].toString()); // Ensure it's a double

      // Find matching item in stockList
      var stockItem = stockList.firstWhere(
        (item) =>
            item['id'].toString() ==
            needed['id'].toString(), // Ensure comparison is done as Strings
        orElse: () => {}, // Return an empty map if not found
      );

      if (stockItem.isNotEmpty) {
        if (needed['isLiquor'] == true) {
          // Ensure correct type conversion to double for ouncesPerBottle and runningCount
          double ouncesPerBottle =
              double.parse(stockItem['ouncesPerBottle'].toString());
          double runningCount =
              double.parse(stockItem['runningCount'].toString());

          double totalOunces = ouncesPerBottle * runningCount;

          if (neededOunces <= totalOunces) {
            stockItem['runningCount'] =
                ((runningCount * ouncesPerBottle) - neededOunces) /
                    ouncesPerBottle;

            try {
              await _firestore
                  .collection('Accounts')
                  .doc(user.email)
                  .collection("stock")
                  .doc(stockItem['id']
                      .toString()) // Ensure document ID is a string
                  .update({
                'runningCount': stockItem['runningCount'],
              });
              Fluttertoast.showToast(
                  msg: 'Transaction Done', gravity: ToastGravity.TOP);
            } catch (error) {
              Fluttertoast.showToast(
                  msg: error.toString(), gravity: ToastGravity.TOP);
            }
          } else {
            print('Not sufficient for ${needed['id']}');

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Insufficient Stock'),
                  content: Text('Stock Insufficient ${needed['name']}'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                      child: const Text('Okay'),
                    ),
                  ],
                );
              },
            );
          }
        }
      } else {
        print('No stock found for ${needed['id']}');

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Missing Stock'),
              content: Text('No stock found for ${needed['name']}'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('Okay'),
                ),
              ],
            );
          },
        );
        isStockSufficient = false; // Mark stock as insufficient
      }
    }

// Step 4: Proceed to the next steps if stock is sufficient
    if (isStockSufficient) {
      _addToTransactions(); // Define what happens next in your workflow
    }
  }

// Helper function to send notifications
  void sendNotification(String message) {
    print("Notification: $message");
    // Add your actual notification logic here (e.g., Firebase Cloud Messaging)
  }

  void checkIfEmpty() {
    if (checkout.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Checkout is Empty'),
            content: const Text('No items in checkout!'),
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
      testFunction();
    }
  }

  void _addToTransactions() async {
    CollectionReference<Map<String, dynamic>> stockCollection =
        FirebaseFirestore.instance
            .collection('Accounts')
            .doc(user.email)
            .collection('stock');

    final snapshot = await stockCollection.get();

    final List<Map<String, dynamic>> stockList = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    for (var items in checkout) {
      print(items['ingredients']);
    }
    try {
      await _firestore
          .collection('Accounts')
          .doc(user.email)
          .collection("transactions")
          .add({
        'time': Timestamp.now(),
        'baristaUID': user.email,
        'total': total,
        'items': checkout,
      });
      Fluttertoast.showToast(
          msg: 'Transaction Done', gravity: ToastGravity.TOP);
      setState(() {
        checkout.clear();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentScreen()),
        );
      });
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString(), gravity: ToastGravity.TOP);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          );
        },
      );
    }
  }

  void removeFromCheckout(Map<String, dynamic> item) {
    setState(() {
      final existingItem =
          checkout.firstWhere((i) => i['id'] == item['id'], orElse: () => {});
      if (existingItem.isNotEmpty && existingItem['quantity'] > 1) {
        existingItem['quantity'] -= 1;
        total = total - (existingItem['price']);
      } else {
        checkout.removeWhere((i) => i['id'] == item['id']);

        total = total - (item['price']);
      }
    });
  }

  void _filterItems(String query) {
    setState(() {});
  }

  @override
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 5);
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
          height: screenWidth < 600
              ? 800
              : 600, // Adjust height for smaller screens
          child: Row(
            children: [
              // Items List
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Add any widget here before the Container

                      // Add spacing if needed

                      // The existing Container wrapped in Expanded
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Color(0xffF8F8F8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title & Search Box in a Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      title,
                                      style: CheersStyles.h3ss,
                                    ),
                                    SizedBox(
                                      width:
                                          200, // Adjust the width of the search box
                                      child: TextField(
                                        onChanged: (query) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Search...",
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // GridView for Items
                                FutureBuilder(
                                    future: itemsFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }
                                      final items = snapshot.data!;
                                      return Expanded(
                                        child: GridView.builder(
                                          padding: const EdgeInsets.all(8),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            childAspectRatio:
                                                MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        600
                                                    ? 1.5
                                                    : 1.2,
                                          ),
                                          itemCount:
                                              items.length, // Use filtered list
                                          itemBuilder: (context, index) {
                                            final item = items[index];
                                            return Card(
                                              color: const Color(0xffF19A6F),
                                              child: InkWell(
                                                onTap: () =>
                                                    addToCheckout(item),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                              .size
                                                              .width <
                                                          600
                                                      ? 150
                                                      : 200, // Fixed height based on screen size
                                                  child: ListTile(
                                                    minVerticalPadding: 10,
                                                    title: Text(
                                                      item['name'],
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      '\$${item['price']}',
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    })
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Container(
                        height: 120,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Your button action here
                                  print("Container button tapped!");
                                },
                                borderRadius: BorderRadius.circular(
                                    20), // Optional: Matches Container's border radius
                                child: Container(
                                  width: 130,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF8F8F8), // Button color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Tap Me",
                                      style: TextStyle(
                                        color: const Color(0xffF19A6F),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Your button action here
                                  setState(() {
                                    itemsFuture = fetchCocktails();
                                    title = "Cocktails";
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                    20), // Optional: Matches Container's border radius
                                child: Container(
                                  width: 130,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF8F8F8), // Button color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Cocktails",
                                      style: TextStyle(
                                        color: const Color(0xffF19A6F),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Your button action here
                                  setState(() {
                                    itemsFuture = fetchWines();
                                    title = "Wines";
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                    20), // Optional: Matches Container's border radius
                                child: Container(
                                  width: 130,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF8F8F8), // Button color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Wine",
                                      style: TextStyle(
                                        color: const Color(0xffF19A6F),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Your button action here
                                  print("Container button tapped!");
                                },
                                borderRadius: BorderRadius.circular(
                                    20), // Optional: Matches Container's border radius
                                child: Container(
                                  width: 130,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF8F8F8), // Button color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Tap Me",
                                      style: TextStyle(
                                        color: const Color(0xffF19A6F),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Your button action here
                                  print("Container button tapped!");
                                },
                                borderRadius: BorderRadius.circular(
                                    20), // Optional: Matches Container's border radius
                                child: Container(
                                  width: 130,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF8F8F8), // Button color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Tap Me",
                                      style: TextStyle(
                                        color: const Color(0xffF19A6F),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      )
                    ],
                  ),
                ),
              ),

              // Checkout Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 20, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Color(0xffF8F8F8)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20, bottom: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Checkout",
                                    style: CheersStyles.h3ss,
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          textStyle: MaterialStateProperty.all(
                                              const TextStyle(
                                                  fontFamily: "Product Sans")),
                                          minimumSize: MaterialStateProperty.all(
                                              const Size(40, 40)),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                  horizontal: 32,
                                                  vertical: 16)),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xffFF6E1F)),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ))),
                                      onPressed: () {
                                        setState(() {
                                          checkout.clear();
                                        });
                                      },
                                      child: const Text("Void"))
                                ],
                              ),
                            ),
                            Container(
                                height: 40,
                                color: const Color(0xffF1F1F1),
                                child: const ListTile(
                                  leading: Text(
                                    "Name",
                                    style: CheersStyles.h5s,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "QTY",
                                        style: CheersStyles.h5s,
                                      ),
                                      SizedBox(
                                        width: 40,
                                      ),
                                      Text(
                                        "Price",
                                        style: CheersStyles.h5s,
                                      ),
                                    ],
                                  ),
                                )),
                            SizedBox(
                              height: 320,
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: checkout.length,
                                  itemBuilder: (context, index) {
                                    final item = checkout[index];
                                    return ListTile(
                                      title: Text(item['name']),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Color(0xffFF6E1F),
                                            ),
                                            onPressed: () =>
                                                removeFromCheckout(item),
                                          ),
                                          Text('${item['quantity']}'),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Color(0xffFF6E1F),
                                            ),
                                            onPressed: () =>
                                                addToCheckout(item),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                              "\$${(item['price'] * item['quantity'])}")
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Divider(),
                            Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20)),
                                  color: Color(0xffF1F1F1)),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total",
                                    style: CheersStyles.h4s,
                                  ),
                                  Text(
                                    total.toString(),
                                    style: CheersStyles.h4s,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50,
                        width: screenWidth < 600
                            ? 300
                            : 1000, // Adjust button width for smaller screens
                        child: ElevatedButton(
                          onPressed: () {
                            checkIfEmpty();
                          },
                          style: CheersStyles.buttonMain,
                          child: const Text(
                            'Send to Payment Pad',
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
