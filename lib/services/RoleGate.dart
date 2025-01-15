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
            default:
              return checkRoles(snapshot.data!);
          }
        },
      ),
    );
  }

  checkRoles(DocumentSnapshot snapshot) {
    if (snapshot['Admin'] == true) {
      return const AdminNavigator();
    } else {
      return const NavigatorGate();
    }
  }
}
