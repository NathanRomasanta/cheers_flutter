import 'package:cheers_flutter/design/design.dart';
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
  final ouncePerBottleController = TextEditingController();
  final itemQuantityController = TextEditingController();
  final itemIDController = TextEditingController();

  bool isLiquor = false;

  Future createItem() async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Item Creation'),
            content: const Text('Are you sure you want to create this item?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isLiquor == false) {
                    //anything else that's not a liquor
                    FirebaseFirestore.instance
                        .collection("Items")
                        .doc(itemIDController.text.trim())
                        .set({
                      'name': itemNameController.text.trim(),
                      'id': itemIDController.text.trim(),
                      'isLiquor': false,
                      'ouncesPerBottle': 1,
                      'quantity': 1
                    });
                  } else {
                    //liquor item add
                    FirebaseFirestore.instance
                        .collection("Items")
                        .doc(itemIDController.text.trim())
                        .set({
                      'name': itemNameController.text.trim(),
                      'id': itemIDController.text.trim(),
                      'quantity': int.parse(itemQuantityController.text.trim()),
                      'ouncesPerBottle':
                          int.parse(ouncePerBottleController.text.trim()),
                      'isLiquor': true
                    });
                  }
                  Fluttertoast.showToast(
                      msg: "Item Created!", gravity: ToastGravity.TOP);

                  itemNameController.clear();
                  itemIDController.clear();
                  itemQuantityController.clear();
                  ouncePerBottleController.clear();
                  setState(() {
                    isLiquor = false;
                  });
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
        backgroundColor: const Color(0xffF4F1EA),
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Inventory Item Creation", style: CheersStyles.h1s),
                const SizedBox(height: 15),
                const Text(
                  "Item Name",
                  style: CheersStyles.inputBoxLabels,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 500,
                  child: TextField(
                    decoration: CheersStyles.inputBox,
                    controller: itemNameController,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Item ID",
                  style: CheersStyles.inputBoxLabels,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 400,
                  child: TextField(
                    decoration: CheersStyles.inputBox,
                    controller: itemIDController,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Is it a liquor",
                  style: CheersStyles.inputBoxLabels,
                ),
                Row(
                  children: [
                    const Text(
                      "Yes",
                      style: CheersStyles.inputBoxLabels,
                    ),
                    Checkbox(
                      activeColor: Colors.orange,
                      value: isLiquor,
                      onChanged: (value) {
                        setState(() {
                          isLiquor = value!;
                        });
                      },
                    ),
                  ],
                ),
                if (isLiquor) ...[
                  Row(
                    children: [
                      const Text(
                        "Starting Quantity(Bottle)",
                        style: CheersStyles.inputBoxLabels,
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: CheersStyles.inputBox,
                          controller: itemQuantityController,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        "Ounce per bottle",
                        style: CheersStyles.inputBoxLabels,
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: CheersStyles.inputBox,
                          controller: ouncePerBottleController,
                        ),
                      ),
                    ],
                  )
                ],
                const SizedBox(height: 15),
                ElevatedButton(
                    style: CheersStyles.buttonMain,
                    onPressed: () {
                      createItem();
                    },
                    child: const Text("Create Item")),
              ],
            ),
          ),
        ));
  }
}
