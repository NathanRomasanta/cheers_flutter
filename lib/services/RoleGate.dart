import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminNavigator.dart';
import 'package:cheers_flutter/pages/Navigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RoleGate extends StatefulWidget {
  const RoleGate({super.key});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Accounts")
            .doc(user.email)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const SpinKitFoldingCube(
                size: 140,
                color: Colors.white,
              );
            case ConnectionState.active:
              return checkRoles(snapshot.data!);
            case ConnectionState.done:
              return checkRoles(snapshot.data!);
            default:
              return checkRoles(snapshot.data!);
          }
        },
      ),
    );
  }

  checkRoles(DocumentSnapshot snapshot) {
    if (snapshot['accountType'] == "Bar Manager") {
      return const AdminNavigator();
    } else if (snapshot['accountType'] == "Barista") {
      return const NavigatorGate();
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                size: 100,
              ),
              const SizedBox(height: 15),
              const Text(
                  "Your account does not fit the use case for the Flutter System"),
              const Text("Please logout and use a proper account"),
              const SizedBox(height: 15),
              ElevatedButton(
                  style: CheersStyles.buttonMain,
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  child: const Text("Logout"))
            ],
          ),
        ),
      );
    }
  }
}
