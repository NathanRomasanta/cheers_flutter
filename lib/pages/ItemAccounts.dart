import 'package:cheers_flutter/design/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ItemAccounts extends StatefulWidget {
  const ItemAccounts({super.key});

  @override
  State<ItemAccounts> createState() => _ItemAccountsState();
}

class _ItemAccountsState extends State<ItemAccounts> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _controllers2 = {};
  final Map<String, TextEditingController> _controllers3 = {};
  final Map<String, TextEditingController> _controllers4 = {};
  final Map<String, TextEditingController> _controllers5 = {};
  final Map<String, TextEditingController> _controllers6 = {};

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() {
    for (var controller in [
      ..._controllers.values,
      ..._controllers2.values,
      ..._controllers3.values
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);

    try {
      QuerySnapshot snapshot = await _firestore.collection('Items').get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;

        _controllers[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');
        _controllers2[id] =
            TextEditingController(text: data['open_lbs']?.toString() ?? '0');
        _controllers3[id] =
            TextEditingController(text: data['open_oz']?.toString() ?? '0');

        _controllers4[id] =
            TextEditingController(text: data['close_count']?.toString() ?? '0');
        _controllers5[id] =
            TextEditingController(text: data['close_lbs']?.toString() ?? '0');
        _controllers6[id] =
            TextEditingController(text: data['close_oz']?.toString() ?? '0');

        return {
          'id': id,
          'name': data['name'] ?? 'Unnamed Item',
          ...data,
        };
      }).toList();

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  Future<void> _setOpeningAccounts() async {
    try {
      for (var item in _items) {
        final id = item['id'];
        final name = item['name'];
        await _firestore
            .collection('Cashout')
            .doc(user.email)
            .collection("Date")
            .doc(formattedDate)
            .collection("Stock")
            .doc(id)
            .set({
          'itemID': id,
          'name': name,
          'open_count': int.tryParse(_controllers[id]!.text) ?? 0,
          'open_lbs': double.tryParse(_controllers2[id]!.text) ?? 0.0,
          'open_oz': double.tryParse(_controllers3[id]!.text) ?? 0.0,
          'updatedBy': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _controllers.forEach((key, controller) => controller.clear());
      _controllers2.forEach((key, controller) => controller.clear());
      _controllers3.forEach((key, controller) => controller.clear());
      _controllers4.forEach((key, controller) => controller.clear());
      _controllers5.forEach((key, controller) => controller.clear());
      _controllers6.forEach((key, controller) => controller.clear());
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop(); // Close only the dialog
    } catch (e) {}
  }

  Future<void> _setClosingAccounts() async {
    try {
      for (var item in _items) {
        final id = item['id'];
        final name = item['name'];
        await _firestore
            .collection('Cashout')
            .doc(user.email)
            .collection("Date")
            .doc(formattedDate)
            .collection("Stock")
            .doc(id)
            .set({
          'itemID': id,
          'name': name,
          'close_count': int.tryParse(_controllers4[id]!.text) ?? 0,
          'close_lbs': double.tryParse(_controllers5[id]!.text) ?? 0.0,
          'close_oz': double.tryParse(_controllers6[id]!.text) ?? 0.0,
          'updatedBy': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _controllers.forEach((key, controller) => controller.clear());
      _controllers2.forEach((key, controller) => controller.clear());
      _controllers3.forEach((key, controller) => controller.clear());
      _controllers4.forEach((key, controller) => controller.clear());
      _controllers5.forEach((key, controller) => controller.clear());
      _controllers6.forEach((key, controller) => controller.clear());
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop(); // Close only the dialog
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showOpeningAccountsDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Transaction Details',
              style: CheersStyles.alertDialogHeader),
          content: SizedBox(
            height: 400,
            width: 700,
            child: Column(
              children: [
                const Text('Select the opening accounts'),
                SizedBox(
                  height: 300,
                  width: 500,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final id = item['id'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text(item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 2,
                                child: TextField(
                                    controller: _controllers[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 2,
                                child: TextField(
                                    controller: _controllers2[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 2,
                                child: TextField(
                                    controller: _controllers3[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: _setOpeningAccounts, child: const Text("Set"))
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showClosingAccountsDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Closing Accounts',
              style: CheersStyles.alertDialogHeader),
          content: SizedBox(
            height: 400,
            width: 700,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set the closing accounts amounts'),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text(
                      "Item Name",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 130),
                    Text(
                      "Closing count",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 25),
                    Text(
                      "Closing lbs",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 30),
                    Text(
                      "Closing oz",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  width: 500,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final id = item['id'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: TextField(
                                    controller: _controllers4[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: TextField(
                                    controller: _controllers5[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: TextField(
                                    controller: _controllers6[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 300,
                    ),
                    ElevatedButton(
                        style: CheersStyles.buttonMain,
                        onPressed: _setClosingAccounts,
                        child: const Text("Set")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: CheersStyles.buttonMain,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: const Text("Close"))
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff6ea),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Opening & Closing Accounts", style: CheersStyles.h1s),
            const SizedBox(height: 50),
            Row(children: [
              const Text("Current Barista:", style: CheersStyles.h7s),
              const SizedBox(width: 15),
              Text(user.email.toString(), style: CheersStyles.h7s),
            ]),
            const SizedBox(height: 10),
            const Text("Opening Accounts", style: CheersStyles.h2s),
            ListTile(
              subtitle: const Text("Set opening accounts"),
              title: const Text("Set opening accounts for current Barista"),
              leading: const Icon(Icons.email_rounded, size: 35),
              trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TextFields(),
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
                  }),
            ),
            const Text("Closing Accounts", style: CheersStyles.h2s),
            ListTile(
              subtitle: const Text("Set closing accounts"),
              title: const Text("Set closing accounts for current Barista"),
              leading: const Icon(Icons.email_rounded, size: 35),
              trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: _showClosingAccountsDialog),
            ),
          ],
        ),
      ),
    );
  }
}

class TextFields extends StatefulWidget {
  const TextFields({super.key});

  @override
  State<TextFields> createState() => _TextFieldsState();
}

class _TextFieldsState extends State<TextFields> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "Opening Accounts",
          style: CheersStyles.posTitleStyle, // Set text color to black
        ),
      ),
    );
  }
}
