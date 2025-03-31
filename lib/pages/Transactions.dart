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
  List<String> dropdownItems = [];
  String? selectedValue;
  final user = FirebaseAuth.instance.currentUser!;
  List<String> collectionNames = [];
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchDropdownItems();
  }

  Future<void> fetchDropdownItems() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.email)
          .collection('dates')
          .get();
      List<String> items =
          snapshot.docs.map((doc) => doc['date'].toString()).toList();
      setState(() {
        dropdownItems = items;
      });
    } catch (e) {
      print('Error fetching dropdown items: $e');
    }
  }

  final FirebaseService firebaseService = FirebaseService();

  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  String name = '';
  String price = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: const Color(0xffFfffff),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Recent Transactions",
                          style: CheersStyles.pageTitle,
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedValue,
                              hint: const Text('Select date'),
                              isExpanded: true,
                              items: dropdownItems.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      children: [
                        Text(
                          "Transaction Date/Time",
                          style: CheersStyles.tableHeaders,
                        ),
                        SizedBox(width: 145),
                        Text(
                          "Transaction ID",
                          style: CheersStyles.tableHeaders,
                        ),
                        SizedBox(width: 130),
                        Text(
                          "Transaction Total",
                          style: CheersStyles.tableHeaders,
                        ),
                        SizedBox(width: 80),
                        Text(
                          "Item Count",
                          style: CheersStyles.tableHeaders,
                        ),
                        Spacer(),
                        Text(
                          "Details",
                          style: CheersStyles.tableHeaders,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 228, 228, 228),
                      thickness: 1.5,
                    ),
                    SizedBox(
                      height: 520,
                      width: 1150,
                      child: selectedValue == null
                          ? const Center(
                              child:
                                  Text("Select an option to see transactions"))
                          : SingleChildScrollView(
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('transactions')
                                      .doc(user.email)
                                      .collection(selectedValue!)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                          child: Text("No transactions found"));
                                    }
                                    if (snapshot.hasData) {
                                      var itemList = snapshot.data!.docs
                                          .where((doc) =>
                                              !(doc['isVoided'] ?? false))
                                          .toList();

                                      return ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: itemList.length,
                                          itemBuilder: (context, index) {
                                            DocumentSnapshot document =
                                                itemList[index];

                                            Map<String, dynamic> data = document
                                                .data() as Map<String, dynamic>;

                                            List transactionItemList =
                                                data['items'];
                                            String transactionID = document.id;
                                            double transactionTotal =
                                                data['total'];
                                            int totalItems = data['totalItems'];

                                            String baristaUID =
                                                data['baristaUID'];

                                            Timestamp timestamp = data['time'];

                                            DateTime dateTime = timestamp
                                                .toDate(); // Convert Firestore timestamp to DateTime

                                            String formattedDate = DateFormat(
                                                    'yyyy-MM-dd HH:mm:ss')
                                                .format(dateTime);

                                            String id = data['id'];

                                            if (baristaUID == user.email) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0, top: 10),
                                                child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Color.fromARGB(
                                                              255,
                                                              228,
                                                              228,
                                                              228), // Border color
                                                          width:
                                                              1.0, // Border width
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(children: [
                                                      SizedBox(
                                                          width: 150,
                                                          child: Center(
                                                              child: Text(
                                                            formattedDate,
                                                            style: CheersStyles
                                                                .tableItems,
                                                          ))),
                                                      const SizedBox(width: 60),
                                                      SizedBox(
                                                          width: 250,
                                                          child: Center(
                                                              child: Text(
                                                            transactionID,
                                                            style: CheersStyles
                                                                .tableItems,
                                                          ))),
                                                      const SizedBox(width: 50),
                                                      SizedBox(
                                                          width: 100,
                                                          child: Center(
                                                              child: Text(
                                                            "\$$transactionTotal",
                                                            style: CheersStyles
                                                                .tableItems,
                                                          ))),
                                                      const SizedBox(width: 70),
                                                      SizedBox(
                                                          width: 100,
                                                          child: Center(
                                                              child: Text(
                                                            totalItems
                                                                .toString(),
                                                            style: CheersStyles
                                                                .tableItems,
                                                          ))),
                                                      const Spacer(),
                                                      IconButton(
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  title:
                                                                      const Text(
                                                                    'Transaction Details',
                                                                    style: CheersStyles
                                                                        .alertDialogHeader,
                                                                  ),
                                                                  content: Container(
                                                                      color: Colors.white,
                                                                      height: 400,
                                                                      width: 700,
                                                                      child: Row(
                                                                        children: [
                                                                          Expanded(
                                                                              child: Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              const Text(
                                                                                'Barista UID',
                                                                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                                                              ),
                                                                              Text(baristaUID),
                                                                              const SizedBox(height: 15),
                                                                              const Text(
                                                                                'Transaction Total',
                                                                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                                                              ),
                                                                              Text("\$$transactionTotal"),
                                                                              const SizedBox(height: 15),
                                                                              const Text(
                                                                                'Total Items',
                                                                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                                                              ),
                                                                              Text(totalItems.toString()),
                                                                              const SizedBox(height: 15),
                                                                              const SizedBox(height: 15),
                                                                              const Text(
                                                                                'Transaction Date/Time',
                                                                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                                                              ),
                                                                              Text(formattedDate),
                                                                              const SizedBox(height: 15),
                                                                            ],
                                                                          )),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Text("Item Details"),
                                                                                SizedBox(
                                                                                  height: 200, // Adjust height as needed
                                                                                  child: ListView.builder(
                                                                                    shrinkWrap: true, // Prevents infinite height issues
                                                                                    itemCount: transactionItemList.length, // Ensure you define itemCount
                                                                                    itemBuilder: (context, index) {
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
                                                                      onPressed:
                                                                          () {
                                                                        // Close the dialog
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return AlertDialog(
                                                                                backgroundColor: Colors.white,
                                                                                content: Container(
                                                                                    color: Colors.white,
                                                                                    height: 180,
                                                                                    width: 400,
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                            child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            const Text(
                                                                                              "Please Enter your Pin",
                                                                                              style: CheersStyles.alertDialogHeader,
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              height: 20,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 240,
                                                                                              child: TextField(
                                                                                                controller: _controller,
                                                                                                keyboardType: TextInputType.number,
                                                                                                textAlign: TextAlign.center,
                                                                                                maxLength: 6,
                                                                                                decoration: const InputDecoration(
                                                                                                  counterText: '',
                                                                                                  border: OutlineInputBorder(
                                                                                                    borderSide: BorderSide(color: Colors.orange, width: 2),
                                                                                                  ),
                                                                                                  enabledBorder: OutlineInputBorder(
                                                                                                    borderSide: BorderSide(color: Colors.orange, width: 2),
                                                                                                  ),
                                                                                                  focusedBorder: OutlineInputBorder(
                                                                                                    borderSide: BorderSide(color: Colors.orange, width: 2),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(height: 10),
                                                                                            ElevatedButton(
                                                                                              style: CheersStyles.buttonMain,
                                                                                              onPressed: () {
                                                                                                if (_controller.text == "112369") {
                                                                                                  print(id);
                                                                                                  FirebaseFirestore.instance.collection('transactions').doc(user.email).collection(selectedValue!).doc(id).update({
                                                                                                    'isVoided': true,
                                                                                                  });
                                                                                                  _controller.clear();
                                                                                                  Navigator.pop(context);
                                                                                                  Navigator.pop(context);
                                                                                                  showDialog(
                                                                                                    context: context,
                                                                                                    builder: (context) => AlertDialog(
                                                                                                      backgroundColor: Colors.white,
                                                                                                      title: const Text("Voided Transaction"),
                                                                                                      content: const Text("Transaction successfully voided!"),
                                                                                                      actions: [
                                                                                                        TextButton(
                                                                                                          onPressed: () => Navigator.pop(context),
                                                                                                          child: const Text("OK"),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  );
                                                                                                } else {
                                                                                                  Navigator.pop(context);
                                                                                                  showDialog(
                                                                                                    context: context,
                                                                                                    builder: (context) => AlertDialog(
                                                                                                      backgroundColor: Colors.white,
                                                                                                      title: const Text("Incorrect PIN"),
                                                                                                      content: const Text("The PIN you entered is incorrect."),
                                                                                                      actions: [
                                                                                                        TextButton(
                                                                                                          onPressed: () => Navigator.pop(context),
                                                                                                          child: const Text("OK"),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  );
                                                                                                }
                                                                                              },
                                                                                              child: const Text("Submit"),
                                                                                            ),
                                                                                          ],
                                                                                        )),
                                                                                      ],
                                                                                    )),
                                                                              );
                                                                            });
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Void Transaction',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Product Sans',
                                                                          color:
                                                                              Colors.red,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        // Close the dialog
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          const Text(
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
                                                          icon: const Icon(
                                                              Icons.menu))
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
                            ),
                    ),
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
