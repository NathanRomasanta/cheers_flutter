import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
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
          child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog(context);
        },
        child: const Text("Logout"),
      )),
    );
  }
}
