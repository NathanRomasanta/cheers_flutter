import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BarStock extends StatefulWidget {
  const BarStock({super.key});

  @override
  State<BarStock> createState() => _BarStockState();
}

class _BarStockState extends State<BarStock> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 20,
        ),
        ElevatedButton(onPressed: () {}, child: Text("Order more stock")),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Accounts')
                .doc(user.email)
                .collection('stock')
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
                      String docID = document.id;

                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String itemName = data['itemName'];
                      String itemQuantity = data['quantity'].toString();
                      bool isLiquor = data['isLiquor'];

                      if (isLiquor == true) {
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(
                                    255, 228, 228, 228), // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(5),
                            tileColor: Colors.white,
                            title: Row(
                              children: [
                                Expanded(child: Text(itemName)),
                                Expanded(child: Text(itemQuantity)),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.delete))
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(
                                    255, 228, 228, 228), // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(5),
                            tileColor: Colors.white,
                            title: Row(
                              children: [
                                Expanded(child: Text(itemName)),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.delete))
                              ],
                            ),
                          ),
                        );
                      }
                    });
              } else {
                return const Text("No Notes");
              }
            })
      ]),
    );
  }
}
