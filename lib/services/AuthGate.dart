import 'package:cheers_flutter/pages/login.dart';
import 'package:cheers_flutter/services/RoleGate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Something Went Wrong!"),
            );
          } else if (snapshot.hasData) {
            return const RoleGate();
          } else {
            return const LoginScreen();
          }
        });
  }
}
