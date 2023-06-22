import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/widgets/button.dart';
import 'package:the_wall/widgets/text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onTap});

  final Function() onTap;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmPasswordTextController = TextEditingController();

  // Sign up user
  void _signUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (_passwordTextController.text != _confirmPasswordTextController.text) {
      // pop loading circle
      Navigator.pop(context);
      // show error to user
      _displayAlert("Passwords do not match");
      return;
    }

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailTextController.text,
              password: _passwordTextController.text);

      FirebaseFirestore.instance.collection("Users").doc(user.user!.email).set({
        'username': _emailTextController.text.split('@')[0],
        'bio': 'Empty bio..'
      });

      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      _displayAlert(e.message!);
    }
  }

  void _displayAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  Text(
                    "Lets create an account for you",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 25),
                  AppTextField(
                      controller: _emailTextController,
                      hintText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false),
                  const SizedBox(height: 10),
                  AppTextField(
                      controller: _passwordTextController,
                      hintText: "Password",
                      obscureText: true),
                  const SizedBox(height: 10),
                  AppTextField(
                      controller: _confirmPasswordTextController,
                      hintText: "Confirm Password",
                      obscureText: true),
                  const SizedBox(height: 25),
                  AppButton(
                    text: "Sign up",
                    onTap: _signUp,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          " Login now",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
