import 'package:cheers_flutter/design/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xffFF6E1F)),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(100, 40)),
                  backgroundColor:
                      WidgetStateProperty.all(const Color(0xffFF6E1F)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ))),
              onPressed: () {
                // Perform logout action
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Close the dialog
                // Call the logout method
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("Accounts")
          .doc(user.email)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              color: Colors.white,
            );
          default:
            return settingsPage(snapshot.data!);
        }
      },
    );
  }

  Scaffold settingsPage(DocumentSnapshot snapshot) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: CheersStyles.pageTitle,
              ),
              SizedBox(
                width: 500,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        "Account",
                        style: CheersStyles.h2s,
                      ),
                      ListTile(
                        subtitle: const Text("First Name & Last Name"),
                        leading: const Icon(
                          Icons.account_circle_rounded,
                          size: 35,
                        ),
                        title: Text(
                          snapshot['firstName'] + " " + snapshot['lastName'],
                          style: const TextStyle(fontFamily: 'Product Sans'),
                        ),
                      ),
                      ListTile(
                        subtitle: const Text("Email"),
                        leading: const Icon(
                          Icons.email_rounded,
                          size: 35,
                        ),
                        title: Text(
                          snapshot['email'],
                          style: const TextStyle(fontFamily: 'Product Sans'),
                        ),
                      ),
                      ListTile(
                        subtitle: const Text("Change your password"),
                        leading: const Icon(
                          Icons.lock,
                          size: 35,
                        ),
                        title: const Text(
                          "Password",
                          style: TextStyle(fontFamily: 'Product Sans'),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Preferences",
                        style: CheersStyles.h2s,
                      ),
                      ListTile(
                        subtitle: const Text("Change your favorites"),
                        leading: const Icon(
                          Icons.stars_rounded,
                          size: 35,
                        ),
                        title: const Text(
                          "Favorites",
                          style: TextStyle(fontFamily: 'Product Sans'),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const Favorites(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin =
                                      Offset(0.0, 1.0); // Start from bottom
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
                        ),
                      ),
                      const SizedBox(height: 70),
                      ElevatedButton(
                        style: CheersStyles.buttonMain,
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<dynamic> _items = [];
  List<dynamic> _selectedItems = [];
  bool _isExpanded = false;
  final user = FirebaseAuth.instance.currentUser!;
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Pos_Items')
        .doc('cocktails')
        .collection('cocktail_items')
        .get();
    setState(() {
      _items = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'price': doc['price'],
                'ingredients': doc['ingredients'],
              })
          .toList();
    });

    print(_items);
  }

  void _toggleSelection(Map<String, dynamic> item) {
    setState(() {
      if (_selectedItems
          .any((selectedItem) => selectedItem['id'] == item['id'])) {
        _selectedItems
            .removeWhere((selectedItem) => selectedItem['id'] == item['id']);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _saveSelectedItems() async {
    CollectionReference targetCollection = FirebaseFirestore.instance
        .collection('Accounts')
        .doc(user.email)
        .collection("Favorites");
    for (var item in _selectedItems) {
      await targetCollection.add({
        'id': item['id'],
        'name': item['name'],
        'price': item['price'].toString(),
        'ingredients': item['ingredients'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Change Favorites"),
            Expanded(
              child: SingleChildScrollView(
                child: ExpansionTile(
                  title: const Text('Select Items'),
                  initiallyExpanded: _isExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() => _isExpanded = expanded);
                  },
                  children: _items.map((item) {
                    return CheckboxListTile(
                      title: Text(item['name'] ?? 'Unnamed Item'),
                      value: _selectedItems.any(
                          (selectedItem) => selectedItem['id'] == item['id']),
                      onChanged: (_) => _toggleSelection(item),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedItems.isEmpty ? null : _saveSelectedItems,
              child: Text('Save Selected Items'),
            ),
          ],
        ),
      ),
    );
  }
}
