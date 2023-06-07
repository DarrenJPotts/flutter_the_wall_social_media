import 'package:flutter/material.dart';
import 'package:the_wall/screens/login_screen.dart';
import 'package:the_wall/screens/register_screen.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool _showLoginScreen = true;

  void _togglePages() {
    setState(() {
      _showLoginScreen = !_showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLoginScreen
        ? LoginScreen(onTap: _togglePages)
        : RegisterScreen(onTap: _togglePages);
  }
}
