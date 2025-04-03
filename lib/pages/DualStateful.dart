import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/Payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

late List<dynamic> itemsFuture;

late List<dynamic> cocktailItems;
late List<dynamic> wineItems;
late List<dynamic> beerItems;
late List<dynamic> foodItems;
late List<dynamic> favoriteItems;
List<Map<String, dynamic>> checkout = [];
final user = FirebaseAuth.instance.currentUser!;
double total = 0;
final GlobalKey<_RightSideWidgetState> _checkoutKey =
    GlobalKey<_RightSideWidgetState>();

class DualStatefulPage extends StatefulWidget {
  const DualStatefulPage({super.key});

  @override
  State<DualStatefulPage> createState() => _DualStatefulPageState();
}

class _DualStatefulPageState extends State<DualStatefulPage> {
  void addToCheckout(Map<String, dynamic> item) {
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
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => LeftSideWidget(),
              ),
            ),
          ),
          Container(
            height: 650,
            width: 1.5,
            color: Colors.grey.shade300,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => RightSideWidget(key: _checkoutKey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildGridItem({
  required String title,
  required String subtitle,
  required Color color,
  IconData? icon,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap, // Clickable function
    child: Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 30, color: Colors.black54), // Show icon
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildItemGrid({
  required String title,
  required String subtitle,
  required Color color,
  IconData? icon,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap, // Clickable function
    child: Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 30, color: Colors.black54), // Show icon
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
        ],
      ),
    ),
  );
}

class LeftSideWidget extends StatefulWidget {
  const LeftSideWidget({super.key});

  @override
  _LeftSideWidgetState createState() => _LeftSideWidgetState();
}

class _LeftSideWidgetState extends State<LeftSideWidget> {
  //fetching of items

  Future<void> fetchFavorites() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Accounts')
        .doc(user.email)
        .collection('Favorites')
        .get();
    setState(() {
      favoriteItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'price': doc['price'],
                'ingredients': doc['ingredients'],
              })
          .toList();
    });
  }

  Future<void> fetchCocktails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('cocktails')
        .collection('cocktail_items')
        .get();
    setState(() {
      cocktailItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'price': doc['price'],
                'ingredients': doc['ingredients'],
              })
          .toList();
    });
  }

  Future<void> fetchWines() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('wines')
        .collection('wine_items')
        .get();
    setState(() {
      wineItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'price': doc['price'],
                'ingredients': doc['ingredients'],
              })
          .toList();
    });
  }

  Future<void> fetchFood() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('food')
        .collection('food_items')
        .get();
    setState(() {
      foodItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'price': doc['price'],
                'ingredients': doc['ingredients'],
              })
          .toList();
    });
  }

  Future<void> fetchBeers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('beers')
        .collection('beer_items')
        .get();
    setState(() {
      beerItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'price': doc['price'],
                'ingredients': doc['ingredients'],
              })
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCocktails();
    fetchBeers();
    fetchWines();
    fetchFood();
    fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        "title": "Favorites",
        "subtitle": "Tried, True & Tasty",
        "color": "FFD1B3",
        "icon": Icons.favorite,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const Favorites(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      {
        "title": "Cocktails",
        "subtitle": "Shaken, Stirred & Sassy",
        "color": "FDCFA1",
        "icon": Icons.local_bar,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const Cocktails(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
      },
      {
        "title": "Wines",
        "subtitle": "Sip Happens, Enjoy!",
        "color": "FFB997",
        "icon": Icons.wine_bar,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const Wines(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      {
        "title": "Beers",
        "subtitle": "Hops & Happiness",
        "color": "FBC4AB",
        "icon": Icons.sports_bar,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const Beers(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      {
        "title": "Food",
        "subtitle": "Fork It Over!",
        "color": "FFDAB9",
        "icon": Icons.fastfood,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const Food(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Menu",
            style: CheersStyles.menuTitle,
          ),
        ), // Add a title here
        // Optional: Centers the title
        // Customize as needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: MasonryGridView.count(
          crossAxisCount: 2, // Two columns
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildGridItem(
              title: item["title"],
              subtitle: item["subtitle"],
              color: Color(int.parse("0xFF${item['color']}")),
              icon: item["icon"],
              onTap: item["onTap"], // Pass function
            );
          },
        ),
      ),
    );
  }
}

class RightSideWidget extends StatefulWidget {
  const RightSideWidget({Key? key}) : super(key: key);

  @override
  _RightSideWidgetState createState() => _RightSideWidgetState();
}

class _RightSideWidgetState extends State<RightSideWidget> {
  void rebuildCheckout() {
    setState(() {});
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
      checkStock();
    }
  }

  void checkStock() async {
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
      addToTransactions();
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

  void addToTransactions() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    DateTime now = DateTime.now();
    String currentDateString = "";

    // Define the opening and closing times for the day (9 AM to 4 AM)
    DateTime startOfDay =
        DateTime(now.year, now.month, now.day, 9); // 9 AM today
    DateTime endOfDay =
        startOfDay.add(const Duration(hours: 19)); // 4 AM the next day

    // If the current time is after 9 AM but before 4 AM, use the current day
    // If the current time is between 4 AM and 9 AM, use the previous day
    if (now.isAfter(startOfDay) && now.isBefore(endOfDay)) {
      currentDateString =
          DateFormat('MMMM-dd-yyyy').format(startOfDay); // Today's date
    } else if (now.isAfter(endOfDay) || now.isBefore(startOfDay)) {
      currentDateString = DateFormat('MMMM-dd-yyyy').format(
          startOfDay.subtract(const Duration(days: 1))); // Previous day's date
    }

    // Get base date part (without yyyy)
    String baseDatePart = DateFormat('MMMM-dd').format(
        now.isAfter(startOfDay) && now.isBefore(endOfDay)
            ? startOfDay
            : startOfDay.subtract(const Duration(days: 1)));

    // Reference to the transactions collection using the date
    CollectionReference transactionsCollection = db
        .collection('transactions')
        .doc(user.email)
        .collection(currentDateString);

    DocumentReference datesDocRef = db
        .collection('transactions')
        .doc(user.email)
        .collection('dates')
        .doc(currentDateString);

    // Get the count of documents in this collection
    QuerySnapshot transactionDocs = await transactionsCollection.get();
    int docCount =
        transactionDocs.docs.length + 1; // Add 1 for the new transaction

    // Format the document number with leading zero if less than 10
    String docNumberFormatted = docCount < 10 ? '0$docCount' : '$docCount';

    // Create the document ID with the format Month-Day-Number
    String documentID = '$baseDatePart-$docNumberFormatted';

    int? totalItems = 0;

    for (var items in checkout) {
      print(items['ingredients']);
    }

    for (var items in checkout) {
      totalItems = items['quantity'] + totalItems;
    }

    try {
      // Use the custom documentID instead of letting Firestore generate an ID
      await transactionsCollection.doc(documentID).set({
        'time': Timestamp.now(),
        'baristaUID': user.email,
        'total': total,
        'items': checkout,
        'totalItems': totalItems,
        'isVoided': false,
        'id': documentID
      });

      DocumentSnapshot dateDoc = await datesDocRef.get();
      // If the date document doesn't exist, create it
      if (!dateDoc.exists) {
        await datesDocRef.set({
          'date': currentDateString,
          'timestamp': Timestamp.now(),
          'transactionCount': 1
        });
      } else {
        // If it exists, update the transaction count
        await datesDocRef.update({'transactionCount': FieldValue.increment(1)});
      }

      Fluttertoast.showToast(
          msg: 'Transaction Done', gravity: ToastGravity.TOP);
      setState(() {
        checkout.clear();
        totalItems = 0;
        total = 0;

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PaymentScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0); // Start from bottom
              const end = Offset.zero;
              const curve = Curves.fastOutSlowIn;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
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

  void addToCheckout(Map<String, dynamic> item) {
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 20, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Checkout",
                          style: CheersStyles.h3ss,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                textStyle: WidgetStateProperty.all(
                                    const TextStyle(
                                        fontFamily: "Product Sans")),
                                minimumSize:
                                    WidgetStateProperty.all(const Size(40, 40)),
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.white),
                                padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16)),
                                backgroundColor: WidgetStateProperty.all(
                                    const Color(0xffFF6E1F)),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
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
                    height: 400,
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: checkout.length,
                        itemBuilder: (context, index) {
                          final item = checkout[index];
                          return ListTile(
                            title: Text(
                              item['name'],
                              style: const TextStyle(fontSize: 15),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(0xffFF6E1F),
                                  ),
                                  onPressed: () => removeFromCheckout(item),
                                ),
                                Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xffFF6E1F),
                                  ),
                                  onPressed: () => addToCheckout(item),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "\$${(item['price'] * item['quantity'])}",
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(),
                  Container(
                    decoration: const BoxDecoration(color: Color(0xffF1F1F1)),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: CheersStyles.h4s,
                        ),
                        Text(
                          "\$${total.toStringAsFixed(2)}",
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
    );
  }
}

class Cocktails extends StatefulWidget {
  const Cocktails({super.key});

  @override
  State<Cocktails> createState() => _CocktailsState();
}

class _CocktailsState extends State<Cocktails> {
  @override
  Widget build(BuildContext context) {
    addToCheckout(Map<String, dynamic> item) {
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

      _checkoutKey.currentState?.rebuildCheckout();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "Cocktails",
          style: CheersStyles.posTitleStyle, // Set text color to black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: MasonryGridView.count(
          crossAxisCount: 4, // Two columns
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: cocktailItems.length,
          itemBuilder: (context, index) {
            final item = cocktailItems[index];
            return _buildItemGrid(
              onTap: () => addToCheckout(
                  item), // Pass a reference, not call it immediately
              title: item["name"],
              subtitle: '\$${item['price']}',
              color: const Color(0xffF19A6F),
            );
          },
        ),
      ),
    );
  }
}

class Beers extends StatefulWidget {
  const Beers({super.key});

  @override
  State<Beers> createState() => _BeersState();
}

class _BeersState extends State<Beers> {
  @override
  Widget build(BuildContext context) {
    addToCheckout(Map<String, dynamic> item) {
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

      _checkoutKey.currentState?.rebuildCheckout();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "Beers",
          style: CheersStyles.posTitleStyle, // Set text color to black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: MasonryGridView.count(
          crossAxisCount: 4, // Two columns
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: beerItems.length,
          itemBuilder: (context, index) {
            final item = beerItems[index];
            return _buildItemGrid(
              onTap: () => addToCheckout(item),
              title: item["name"],
              subtitle: '\$${item['price']}',
              color: const Color(0xffF19A6F),

              // Pass function
            );
          },
        ),
      ),
    );
  }
}

class Wines extends StatefulWidget {
  const Wines({super.key});

  @override
  State<Wines> createState() => _WinesState();
}

class _WinesState extends State<Wines> {
  @override
  Widget build(BuildContext context) {
    addToCheckout(Map<String, dynamic> item) {
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

      _checkoutKey.currentState?.rebuildCheckout();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "Wines",
          style: CheersStyles.posTitleStyle, // Set text color to black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: MasonryGridView.count(
          crossAxisCount: 4, // Two columns
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: wineItems.length,
          itemBuilder: (context, index) {
            final item = wineItems[index];
            return _buildItemGrid(
              onTap: () => addToCheckout(item),
              title: item["name"],
              subtitle: '\$${item['price']}',
              color: const Color(0xffF19A6F),

              // Pass function
            );
          },
        ),
      ),
    );
  }
}

class Food extends StatefulWidget {
  const Food({super.key});

  @override
  State<Food> createState() => _FoodState();
}

class _FoodState extends State<Food> {
  @override
  Widget build(BuildContext context) {
    addToCheckout(Map<String, dynamic> item) {
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

      _checkoutKey.currentState?.rebuildCheckout();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "Food",
          style: CheersStyles.posTitleStyle, // Set text color to black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: MasonryGridView.count(
          crossAxisCount: 4, // Two columns
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: foodItems.length,
          itemBuilder: (context, index) {
            final item = foodItems[index];
            return _buildItemGrid(
              onTap: () => addToCheckout(item),
              title: item["name"],
              subtitle: '\$${item['price']}',
              color: const Color(0xffF19A6F),

              // Pass function
            );
          },
        ),
      ),
    );
  }
}

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  Widget build(BuildContext context) {
    addToCheckout(Map<String, dynamic> item) {
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

      _checkoutKey.currentState?.rebuildCheckout();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "Favorites",
          style: CheersStyles.posTitleStyle, // Set text color to black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: MasonryGridView.count(
          crossAxisCount: 4, // Two columns
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: favoriteItems.length,
          itemBuilder: (context, index) {
            final item = favoriteItems[index];
            return _buildItemGrid(
              onTap: () => addToCheckout(item),
              title: item["name"],
              subtitle: '\$${item['price']}',
              color: const Color(0xffF19A6F),

              // Pass function
            );
          },
        ),
      ),
    );
  }
}
