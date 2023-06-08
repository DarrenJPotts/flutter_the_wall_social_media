import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          // profile picture
          Icon(
            Icons.person,
            size: 72,
          )

          // user email

          // user details
        ],
      ),
    );
  }
}
