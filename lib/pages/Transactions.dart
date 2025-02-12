import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/services/FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date

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
      backgroundColor: const Color(0xffF4F1EA),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                        Text("Transaction Date/Time"),
                        SizedBox(width: 145),
                        Text("Transaction ID"),
                        SizedBox(width: 130),
                        Text("Transaction Total"),
                        SizedBox(width: 80),
                        Text("Item Count"),
                        Spacer(),
                        Text("Details"),
                      ],
                    ),
                    const Divider(),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Transactions')
                            .orderBy('time', descending: true)
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
                                  int totalItems = data['totalItems'];

                                  String baristaUID = data['baristaUID'];

                                  Timestamp timestamp = data['time'];

                                  DateTime dateTime = timestamp
                                      .toDate(); // Convert Firestore timestamp to DateTime

                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(dateTime);

                                  if (baristaUID == user.email) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10.0, top: 10),
                                      child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color.fromARGB(255, 228,
                                                    228, 228), // Border color
                                                width: 1.0, // Border width
                                              ),
                                            ),
                                          ),
                                          child: Row(children: [
                                            SizedBox(
                                                width: 150,
                                                child: Center(
                                                    child:
                                                        Text(formattedDate))),
                                            const SizedBox(width: 50),
                                            SizedBox(
                                                width: 250,
                                                child: Center(
                                                    child:
                                                        Text(transactionID))),
                                            const SizedBox(width: 50),
                                            SizedBox(
                                                width: 100,
                                                child: Center(
                                                    child: Text(
                                                        "\$${transactionTotal}"))),
                                            const SizedBox(width: 70),
                                            SizedBox(
                                                width: 100,
                                                child: Center(
                                                    child: Text(totalItems
                                                        .toString()))),
                                            const Spacer(),
                                            IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          'Transaction Details',
                                                          style: CheersStyles
                                                              .alertDialogHeader,
                                                        ),
                                                        content: SizedBox(
                                                            height: 400,
                                                            width: 700,
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                    child:
                                                                        Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      'Barista UID',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                    Text(
                                                                        baristaUID),
                                                                    const SizedBox(
                                                                        height:
                                                                            15),
                                                                    const Text(
                                                                      'Transaction Total',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                    Text(
                                                                        "\$$transactionTotal"),
                                                                    const SizedBox(
                                                                        height:
                                                                            15),
                                                                    const Text(
                                                                      'Total Items',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                    Text(totalItems
                                                                        .toString()),
                                                                    const SizedBox(
                                                                        height:
                                                                            15),
                                                                    const SizedBox(
                                                                        height:
                                                                            15),
                                                                    const Text(
                                                                      'Transaction Date/Time',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                    Text(
                                                                        formattedDate),
                                                                    const SizedBox(
                                                                        height:
                                                                            15),
                                                                  ],
                                                                )),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const Text(
                                                                          "Item Details"),
                                                                      SizedBox(
                                                                        height:
                                                                            200, // Adjust height as needed
                                                                        child: ListView
                                                                            .builder(
                                                                          shrinkWrap:
                                                                              true, // Prevents infinite height issues
                                                                          itemCount:
                                                                              transactionItemList.length, // Ensure you define itemCount
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            return ListTile(
                                                                              title: Text(transactionItemList[index]['name']),
                                                                              subtitle: Text(transactionItemList[index]['id']),
                                                                              trailing: Text("${transactionItemList[index]['quantity']} x ${transactionItemList[index]['price']}"),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            )),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              // Close the dialog
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                              'Okay',
                                                              style: CheersStyles
                                                                  .alertTextButton,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(Icons.menu))
                                          ])),
                                    );
                                  } else {
                                    return Container();
                                  }
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
