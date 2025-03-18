import 'package:cheers_flutter/design/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

late List<dynamic> itemsFuture;

late List<dynamic> cocktailItems;
late List<dynamic> wineItems;
late List<dynamic> beerItems;
late List<dynamic> foodItems;
List<Map<String, dynamic>> checkout = [];
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
  @override
  _LeftSideWidgetState createState() => _LeftSideWidgetState();
}

class _LeftSideWidgetState extends State<LeftSideWidget> {
  //fetching of items
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
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        "title": "Favorites",
        "subtitle": "",
        "color": "B0D9F5",
        "icon": Icons.favorite,
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
        }
      },
      {
        "title": "Cocktails",
        "subtitle": "",
        "color": "B0D9F5",
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
        "subtitle": "",
        "color": "A8E6CF",
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
        "subtitle": "",
        "color": "F8E7A2",
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
        "subtitle": "",
        "color": "F8E7A2",
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
                                textStyle: MaterialStateProperty.all(
                                    const TextStyle(
                                        fontFamily: "Product Sans")),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(40, 40)),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xffFF6E1F)),
                                shape: MaterialStateProperty.all<
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
                            title: Text(item['name']),
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
                                Text('${item['quantity']}'),
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
                                Text("\$${(item['price'] * item['quantity'])}")
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: CheersStyles.h4s,
                        ),
                        Text(
                          "Total",
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
                onPressed: () {},
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
