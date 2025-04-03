import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminCreation extends StatefulWidget {
  const AdminCreation({super.key});

  @override
  State<AdminCreation> createState() => _AdminCreationState();
}

class _AdminCreationState extends State<AdminCreation> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool isAdmin = false;

  Future createAccount() async {
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
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim());
                  await FirebaseFirestore.instance
                      .collection("Accounts")
                      .doc(emailController.text.trim())
                      .set({
                    'firstName': emailController.text.trim(),
                    'lastName': lastNameController.text.trim(),
                    'email': emailController.text.trim(),
                    'password': passwordController.text.trim(),
                    "Admin": isAdmin,
                    'stock': {},
                    'transactions': {}
                  });
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Account Creation'),
      TextField(
        decoration: const InputDecoration(labelText: "First Name"),
        controller: firstNameController,
      ),
      TextField(
        decoration: const InputDecoration(labelText: "Last Name"),
        controller: lastNameController,
      ),
      TextField(
        decoration: const InputDecoration(labelText: "Email"),
        controller: emailController,
      ),
      TextField(
        decoration: const InputDecoration(labelText: "Password"),
        controller: passwordController,
      ),
      Checkbox(
        value: isAdmin,
        onChanged: (value) {
          setState(() {
            isAdmin = value!;
          });
        },
      ),
      ElevatedButton(
          onPressed: () {
            createAccount();
          },
          child: const Text("Create Account"))
    ]));
  }
}
