import 'package:cheers_flutter/design/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xffFF6E1F)),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(100, 40)),
                  backgroundColor: MaterialStateProperty.all(Color(0xffFF6E1F)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ))),
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
    final user = FirebaseAuth.instance.currentUser!;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("Accounts")
          .doc(user.email)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              color: Colors.white,
            );
          default:
            return settingsPage(snapshot.data!);
        }
      },
    );
  }

  Scaffold settingsPage(DocumentSnapshot snapshot) {
    return Scaffold(
        backgroundColor: const Color(0xfffff6ea),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: CheersStyles.h1s,
              ),
              SizedBox(
                width: 500,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        "Account",
                        style: CheersStyles.h2s,
                      ),
                      ListTile(
                        subtitle: const Text("First Name & Last Name"),
                        leading: const Icon(
                          Icons.account_circle_rounded,
                          size: 35,
                        ),
                        title: Text(
                          snapshot['firstName'] + " " + snapshot['lastName'],
                          style: TextStyle(fontFamily: 'Product Sans'),
                        ),
                      ),
                      ListTile(
                        subtitle: const Text("Email"),
                        leading: const Icon(
                          Icons.email_rounded,
                          size: 35,
                        ),
                        title: Text(
                          snapshot['email'],
                          style: const TextStyle(fontFamily: 'Product Sans'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Settings",
                        style: CheersStyles.h2s,
                      ),
                      ListTile(
                        subtitle: const Text("Change your favorites"),
                        leading: const Icon(
                          Icons.stars_rounded,
                          size: 35,
                        ),
                        title: const Text(
                          "Favorites",
                          style: TextStyle(fontFamily: 'Product Sans'),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 70),
                      ElevatedButton(
                        style: CheersStyles.buttonMain,
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
