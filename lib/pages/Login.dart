import 'package:cheers_flutter/design/design.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  void initState() {
    super.initState();
    // Set the app to full-screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

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
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[300], // Light grey background for placeholder
          child: Center(
            child: Image.asset(
              alignment: Alignment.centerLeft,
              'lib/assets/images/Stampede_Picture.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ), // Display the image
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
                    height: 120,
                  ),
                  const Text('Welcome to Cheers!', style: CheersStyles.h1s),
                  const SizedBox(height: 10),
                  const Text('Login to your account', style: CheersStyles.h2s),
                  const SizedBox(height: 24),
                  const Text(
                    "Email",
                    style: CheersStyles.inputBoxLabels,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                      controller: emailController,
                      decoration: CheersStyles.inputBoxMain),
                  const SizedBox(height: 16),
                  const Text(
                    "Password",
                    style: CheersStyles.inputBoxLabels,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: CheersStyles.inputBoxMain),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      login();
                    },
                    style: CheersStyles.buttonMain,
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
