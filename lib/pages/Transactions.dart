import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/services/FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseService firebaseService = FirebaseService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  String name = '';
  String price = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFDFA),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transactions",
                  style: CheersStyles.h1s,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: const Color(0xffF8F8F8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text("Transaction ID"),
                        SizedBox(width: 235),
                        Text("Transaction Date"),
                        SizedBox(width: 220),
                        Text("Total"),
                        SizedBox(width: 290),
                        Text("Details"),
                      ],
                    ),
                    const Divider(),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Accounts')
                            .doc(user.email)
                            .collection('transactions')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List itemList = snapshot.data!.docs;

                            return ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: itemList.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot document = itemList[index];

                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;

                                  List transactionItemList = data['items'];
                                  String transactionID = document.id;
                                  double transactionTotal = data['total'];
                                  Timestamp transactionDate = data['time'];

                                  return Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(255, 228, 228,
                                              228), // Border color
                                          width: 1.0, // Border width
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(5),
                                      tileColor: Colors.white,
                                      title: Row(
                                        children: [
                                          Expanded(child: Text(transactionID)),
                                          Expanded(
                                              child: Text(
                                                  transactionDate.toString())),
                                          Expanded(
                                              child: Text(
                                                  transactionTotal.toString())),
                                          IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Transaction Details'),
                                                      content: SizedBox(
                                                        height: 300,
                                                        width: 300,
                                                        child: ListView.builder(
                                                          itemCount:
                                                              transactionItemList
                                                                  .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return Card(
                                                              elevation:
                                                                  3, // Adds a subtle shadow
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          8),
                                                              child: ListTile(
                                                                leading: Text(transactionItemList[
                                                                            index]
                                                                        [
                                                                        "quantity"]
                                                                    .toString()),
                                                                title: Text(
                                                                  transactionItemList[
                                                                          index]
                                                                      ["name"],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                trailing: Text((transactionItemList[index]
                                                                            [
                                                                            "quantity"] *
                                                                        transactionItemList[index]
                                                                            [
                                                                            "price"])
                                                                    .toString()),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            // Close the dialog
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Okay'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.menu))
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            return const Text("No Stock");
                          }
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
