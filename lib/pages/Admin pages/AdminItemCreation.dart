import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminItemCreation extends StatefulWidget {
  const AdminItemCreation({super.key});

  @override
  State<AdminItemCreation> createState() => _AdminItemCreationState();
}

class _AdminItemCreationState extends State<AdminItemCreation> {
  final itemNameController = TextEditingController();
  final itemPriceController = TextEditingController();
  final itemQuantityController = TextEditingController();

  Future createItem() async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Account Creation'),
            content: const Text(
                'Creating accounts would log out the current account, continue?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection("Items").add({
                    'name': itemNameController.text.trim(),
                    'price': itemPriceController.text.trim(),
                    'quantity': itemQuantityController.text.trim(),
                  });
                  Fluttertoast.showToast(
                      msg: "Item Created!", gravity: ToastGravity.TOP);
                  itemNameController.clear();
                  itemPriceController.clear();
                  itemQuantityController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: e.message.toString(), gravity: ToastGravity.TOP);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Name"),
            controller: itemNameController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Price"),
            controller: itemPriceController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Quantity"),
            controller: itemQuantityController,
          ),
          ElevatedButton(
              onPressed: () {
                createItem();
              },
              child: const Text("Create Item")),
          ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(msg: "Test", gravity: ToastGravity.TOP);
              },
              child: const Text("Flutter Toast")),
        ],
      )),
    );
  }
}
