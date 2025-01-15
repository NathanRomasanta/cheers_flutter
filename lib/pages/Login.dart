import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future login() async {
    showDialog(
        context: context,
        builder: (context) => const SpinKitFoldingCube(
              size: 140,
              color: Colors.white,
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: e.message.toString(), gravity: ToastGravity.TOP);
      Navigator.of(context).pop();
    }
    //navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        TextField(
          decoration: const InputDecoration(labelText: "Email"),
          controller: emailController,
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Password"),
          controller: passwordController,
        ),
        ElevatedButton(
            onPressed: () {
              login();
            },
            child: const Text("Login"))
      ]),
    );
  }
}
