import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/items/Cocktails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class POSv2 extends StatefulWidget {
  const POSv2({super.key});

  @override
  State<POSv2> createState() => _POSv2State();
}

class _POSv2State extends State<POSv2> {
  navigateToCocktails() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CocktailsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            // Left section (3/5 of the screen)
            const Expanded(flex: 3, child: MenuPart()),

            // Divider
            Container(
              height: 650,
              width: 1,
              color: Colors.grey,
            ),
            const SizedBox(width: 10),
            // Right section (2/5 of the screen)
            const Expanded(flex: 2, child: CheckoutPart())
          ],
        ),
      ),
    );
  }
}

// Replace one of your grid buttons with this
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
          const SizedBox(height: 5),
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

class CheckoutPart extends StatefulWidget {
  const CheckoutPart({super.key});

  @override
  State<CheckoutPart> createState() => _CheckoutPartState();
}

class _CheckoutPartState extends State<CheckoutPart> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
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
                    height: 320,
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: const Text("Title"),
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
                                const Text('quantity'),
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
                                const Text("Total")
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

class MenuPart extends StatefulWidget {
  const MenuPart({super.key});

  @override
  State<MenuPart> createState() => _MenuPartState();
}

class _MenuPartState extends State<MenuPart> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        "title": "Favorites",
        "subtitle": "",
        "color": "B0D9F5",
        "icon": Icons.favorite,
        "onTap": () {
          showModalBottomSheet(
              context: context,
              builder: ((context) {
                return SizedBox(
                  height: 200,
                  child: const Text("Modal"),
                );
              }));
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
