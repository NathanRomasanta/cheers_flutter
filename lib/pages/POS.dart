// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/Payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  List<Map<String, dynamic>> checkout = [];
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

  Future<List<Map<String, dynamic>>> fetchFood() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('food')
        .collection('food_items')
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

  Future<List<Map<String, dynamic>>> fetchBeer() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('beers')
        .collection('beer_items')
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
        .collection('wine_items')
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
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference<Map<String, dynamic>> stockCollection =
        firestore.collection('Accounts').doc(user.email).collection('stock');

    // Fetch stock data
    final snapshot = await stockCollection.get();
    Map<String, Map<String, dynamic>> stockMap = {
      for (var doc in snapshot.docs) doc.id: doc.data()
    };

    // Needed ingredients map
    Map<String, Map<String, dynamic>> neededIngredients = {};

    for (var drink in checkout) {
      List ingredients = drink['ingredients'];
      int quantity = drink['quantity'];

      for (var ingredient in ingredients) {
        String ingredientId = ingredient['id'];
        String ingredientName = ingredient['name'];
        bool isLiquor = ingredient['isLiquor'];
        int ounces = ingredient['ounces'] ?? 0;

        if (neededIngredients.containsKey(ingredientId)) {
          if (isLiquor) {
            neededIngredients[ingredientId]!['ounces'] += ounces * quantity;
          } else {
            neededIngredients[ingredientId]!['quantity'] += quantity;
          }
        } else {
          neededIngredients[ingredientId] = {
            'id': ingredientId,
            'name': ingredientName,
            'isLiquor': isLiquor,
            'ounces': isLiquor ? ounces * quantity : 0,
            'quantity':
                isLiquor ? 0 : quantity, // Track quantity for non-liquor
          };
        }
      }
    }

    bool isStockSufficient = true;
    List<String> insufficientStockItems = [];

    WriteBatch batch = firestore.batch();

    for (var needed in neededIngredients.values) {
      if (stockMap.containsKey(needed['id'])) {
        var stockItem = stockMap[needed['id']]!;

        if (needed['isLiquor']) {
          // Handling liquor stock update
          double ouncesPerBottle =
              double.parse(stockItem['ouncesPerBottle'].toString());
          double runningCount =
              double.parse(stockItem['runningCount'].toString());

          double totalOunces = ouncesPerBottle * runningCount;
          double neededOunces = double.parse(needed['ounces'].toString());

          if (neededOunces <= totalOunces) {
            stockItem['runningCount'] =
                ((runningCount * ouncesPerBottle) - neededOunces) /
                    ouncesPerBottle;

            batch.update(stockCollection.doc(needed['id']), {
              'runningCount': stockItem['runningCount'],
            });
          } else {
            isStockSufficient = false;
            insufficientStockItems.add(needed['name']);
          }
        } else {
          // Handling non-liquor stock update
          int currentStock = int.parse(stockItem['runningCount'].toString());
          int neededQuantity = int.parse(needed['quantity'].toString());

          if (neededQuantity <= currentStock) {
            stockItem['runningCount'] = currentStock - neededQuantity;

            batch.update(stockCollection.doc(needed['id']), {
              'runningCount': stockItem['runningCount'],
            });
          } else {
            isStockSufficient = false;
            insufficientStockItems.add(needed['name']);
          }
        }
      } else {
        isStockSufficient = false;
        insufficientStockItems.add(needed['name']);
      }
    }

    if (isStockSufficient) {
      await batch.commit();
      Fluttertoast.showToast(
          msg: 'Transaction Done', gravity: ToastGravity.TOP);
      _addToTransactions();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Insufficient Stock'),
            content: Text(
                'Not enough stock for: ${insufficientStockItems.join(", ")}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Okay'),
              ),
            ],
          );
        },
      );
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
    final FirebaseFirestore db = FirebaseFirestore.instance;
    DateTime now = DateTime.now();

    String currentDateString = "";

    // Define the opening and closing times for the day (9 AM to 4 AM)
    DateTime startOfDay =
        DateTime(now.year, now.month, now.day, 9); // 9 AM today
    DateTime endOfDay =
        startOfDay.add(const Duration(hours: 19)); // 4 AM the next day

    // If the current time is after 9 AM but before 4 AM, use the current day (March 12)
    // If the current time is between 4 AM and 9 AM, use the previous day (March 11)
    if (now.isAfter(startOfDay) && now.isBefore(endOfDay)) {
      currentDateString =
          DateFormat('MMMM-dd-yyyy').format(startOfDay); // Today's date
    } else if (now.isAfter(endOfDay) || now.isBefore(startOfDay)) {
      currentDateString = DateFormat('MMMM-dd-yyyy')
          .format(startOfDay.add(const Duration(days: 1))); // Next day's date
    }

    CollectionReference transactions =
        db.collection('baristas').doc(user.email).collection(currentDateString);

    int? totalItems = 0;

    for (var items in checkout) {
      print(items['ingredients']);
    }

    for (var items in checkout) {
      totalItems = items['quantity'] + totalItems;
    }
    try {
      await transactions.add({
        'time': Timestamp.now(),
        'baristaUID': user.email,
        'total': total,
        'items': checkout,
        'totalItems': totalItems
      });
      Fluttertoast.showToast(
          msg: 'Transaction Done', gravity: ToastGravity.TOP);
      setState(() {
        checkout.clear();
        totalItems = 0;
        total = 0;

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 5);
    return Scaffold(
      backgroundColor: const Color(0xffF4F1EA),
      body: ListView(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  "Register",
                  style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Product Sans'),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize:
                            WidgetStateProperty.all(const Size(120, 50)),
                        backgroundColor:
                            WidgetStateProperty.all(const Color(0xffFF6E1F)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ))),
                    onPressed: () {},
                    child: const Text(
                      "Close Till",
                      style: TextStyle(fontSize: 15),
                    )),
              ),
              const SizedBox(
                width: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(user.email.toString(), style: CheersStyles.h7s),
              ),
              const SizedBox(
                width: 30,
              ),
            ],
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
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    style: ButtonStyle(
                                        minimumSize: WidgetStateProperty.all(
                                            const Size(150, 50)),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color(0xffF0886F)),
                                        shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ))),
                                    onPressed: () {
                                      setState(() {
                                        itemsFuture = fetchCocktails();
                                        title = "Favorites";
                                      });
                                    },
                                    child: const Text("Favorites")),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        minimumSize: WidgetStateProperty.all(
                                            const Size(150, 50)),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color(0xffF0886F)),
                                        shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ))),
                                    onPressed: () {
                                      setState(() {
                                        itemsFuture = fetchCocktails();
                                        title = "Cocktails";
                                      });
                                    },
                                    child: const Text("Cocktails")),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        minimumSize: WidgetStateProperty.all(
                                            const Size(150, 50)),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color(0xffF0886F)),
                                        shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ))),
                                    onPressed: () {
                                      setState(() {
                                        itemsFuture = fetchWines();
                                        title = "Wines";
                                      });
                                    },
                                    child: const Text("Wines")),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        minimumSize: WidgetStateProperty.all(
                                            const Size(150, 50)),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color(0xffF0886F)),
                                        shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ))),
                                    onPressed: () {
                                      setState(() {
                                        itemsFuture = fetchBeer();
                                        title = "Beers";
                                      });
                                    },
                                    child: const Text("Beers")),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        minimumSize: WidgetStateProperty.all(
                                            const Size(150, 50)),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color(0xffF0886F)),
                                        shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ))),
                                    onPressed: () {
                                      setState(() {
                                        itemsFuture = fetchFood();
                                        title = "Food";
                                      });
                                    },
                                    child: const Text("Food")),
                              ]),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Color(0xffF8F8F8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title & Search Box in a Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        title,
                                        style: CheersStyles.h3ss,
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        height: 40,
                                        width:
                                            200, // Adjust the width of the search box
                                        child: TextField(
                                          textAlignVertical:
                                              TextAlignVertical.bottom,
                                          onChanged: (query) {
                                            setState(() {});
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Search...",
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // GridView for Items
                                  FutureBuilder(
                                      future: itemsFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
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
                                              childAspectRatio: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? 2.0
                                                  : 1.8, // Increase this value
                                            ),
                                            itemCount: items.length,
                                            itemBuilder: (context, index) {
                                              final item = items[index];
                                              return Card(
                                                color: const Color(0xffF19A6F),
                                                child: InkWell(
                                                  onTap: () =>
                                                      addToCheckout(item),
                                                  child: ListTile(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
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
                                            textStyle: WidgetStateProperty.all(
                                                const TextStyle(
                                                    fontFamily:
                                                        "Product Sans")),
                                            minimumSize: WidgetStateProperty.all(
                                                const Size(40, 40)),
                                            foregroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.white),
                                            padding: WidgetStateProperty.all(
                                                const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 16)),
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    const Color(0xffFF6E1F)),
                                            shape:
                                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
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
      ),
    );
  }
}
