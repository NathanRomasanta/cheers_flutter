import 'package:cheers_flutter/design/design.dart';
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
        body: Row(children: [
      // Left half: Placeholder for the picture
      Expanded(
        flex: 1,
        child: Container(
          color: Colors.grey[300], // Light grey background for placeholder
          child: Center(
            child: Text(
              'Picture Placeholder',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
          ),
        ),
      ),

      // Right half: Login form
      Expanded(
        flex: 1,
        child: Container(
          height: double.infinity,
          color: Colors.white, // Ensure the entire right half is white
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Text('Welcome to Cheers!', style: CheersStyles.h1s),
                  const SizedBox(height: 24),
                  TextField(decoration: CheersStyles.inputBoxMain),
                  const SizedBox(height: 16),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Handle login logic here
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Handle forgot password logic here
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ]));
  }
}
