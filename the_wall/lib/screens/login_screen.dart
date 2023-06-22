import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/widgets/button.dart';
import 'package:the_wall/widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onTap});

  final Function() onTap;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  // Login user
  void _login() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text);

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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                Text(
                  "Welcome back, you've been missed!",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 25),
                AppTextField(
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: "Email",
                    obscureText: false),
                const SizedBox(height: 10),
                AppTextField(
                    controller: _passwordTextController,
                    hintText: "Password",
                    obscureText: true),
                const SizedBox(height: 25),
                AppButton(
                  text: "Sign in",
                  onTap: _login,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        " Register now",
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
    );
  }
}
