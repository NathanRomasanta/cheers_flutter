import 'package:cheers_flutter/design/design.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
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
                // Perform logout action
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Close the dialog
                // Call the logout method
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text("Email"),
          ElevatedButton(
            style: CheersStyles.buttonMain,
            onPressed: () {
              _showLogoutDialog(context);
            },
            child: const Text("Logout"),
          ),
        ],
      )),
    );
  }
}
