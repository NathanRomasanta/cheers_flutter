import 'package:cheers_flutter/design/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

late List<dynamic> itemsFuture;

class DualStatefulPage extends StatelessWidget {
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
                builder: (context) => RightSideWidget(),
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
          Spacer(),
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
  Future<void> fetchCocktails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('cocktails')
        .collection('cocktail_items')
        .get();
    setState(() {
      itemsFuture = snapshot.docs
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
            MaterialPageRoute(builder: (context) => Cocktails()),
          );
        }
      },
      {
        "title": "Cocktails",
        "subtitle": "",
        "color": "B0D9F5",
        "icon": Icons.local_bar,
        "onTap": () => print("Cocktails tapped"),
      },
      {
        "title": "Wines",
        "subtitle": "",
        "color": "A8E6CF",
        "icon": Icons.wine_bar,
        "onTap": () => print("Wines tapped"),
      },
      {
        "title": "Beers",
        "subtitle": "",
        "color": "F8E7A2",
        "icon": Icons.sports_bar,
        "onTap": () => print("Beers tapped"),
      },
      {
        "title": "Food",
        "subtitle": "",
        "color": "F8E7A2",
        "icon": Icons.fastfood,
        "onTap": () => print("Food tapped"),
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
  @override
  _RightSideWidgetState createState() => _RightSideWidgetState();
}

class _RightSideWidgetState extends State<RightSideWidget> {
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
                              setState(() {});
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
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text("Title"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(0xffFF6E1F),
                                  ),
                                  onPressed: () {},
                                ),
                                Text('quantity'),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xffFF6E1F),
                                  ),
                                  onPressed: () {},
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text("Total")
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "Cocktails",
          style: TextStyle(color: Colors.black), // Set text color to black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: MasonryGridView.count(
          crossAxisCount: 4, // Two columns
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: itemsFuture.length,
          itemBuilder: (context, index) {
            final item = itemsFuture[index];
            return _buildItemGrid(
              title: item["name"],
              subtitle: '\$${item['price']}',
              color: Color(0xffF19A6F),

              // Pass function
            );
          },
        ),
      ),
    );
  }
}
